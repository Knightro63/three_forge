import './bone_classifier.dart';
import 'package:three_js_core/three_js_core.dart';

enum SmoothingType {
  torso,
  limb,
  extremity,
  standard,
}

class BoundaryPair {
  final int vertexA;
  final int vertexB;
  final int boneA;
  final int boneB;
  final SmoothingType smoothingType;

  BoundaryPair({
    required this.vertexA,
    required this.vertexB,
    required this.boneA,
    required this.boneB,
    required this.smoothingType,
  });
}

/// Smooths skin weight boundaries between bone influences using vertex adjacency.
/// Applies different smoothing strategies based on bone category:
/// - Torso: wider multi-ring gradient for voluminous areas
/// - Limbs: directional smoothing toward child bone only
/// - Extremities: no smoothing — hands/fingers/feet/toes stay rigid
class WeightSmoother {
  final BufferGeometry geometry;
  final List<Bone> bones;
  final BoneClassifier classifier;

  WeightSmoother(this.geometry, this.bones)
      : classifier = BoneClassifier(bones);

  int geometryVertexCount() {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return 0;
    return positionAttribute.array.length ~/ 3;
  }

  /// Smooths skin weights at bone boundaries with category-aware behavior.
  /// - Torso boundaries get multi-ring gradient smoothing (3 rings, tapering weights)
  /// - Limb boundaries get directional child-only smoothing
  /// - Other boundaries get standard single-ring 50/50 blending
  void smoothBoneWeightBoundaries(List<int> skinIndices, List<double> skinWeights) {
    final adjacency = buildVertexAdjacency();
    final positionToIndices = buildPositionMap();

    // Pass 1: Identify all boundary vertex pairs and classify them
    final boundaryPairs = findBoundaryPairs(skinIndices, skinWeights, adjacency);

    // Pass 2: Apply torso multi-ring smoothing
    applyTorsoSmoothing(skinIndices, skinWeights, adjacency, positionToIndices, boundaryPairs);

    // Pass 3: Apply limb directional smoothing
    applyLimbSmoothing(skinIndices, skinWeights, positionToIndices, boundaryPairs);

    // Pass 4: Apply standard smoothing for remaining boundaries
    applyStandardSmoothing(skinIndices, skinWeights, positionToIndices, boundaryPairs);

    // Pass 5: Extremity boundaries — intentionally left untouched (no smoothing)
    applyExtremitySmoothing(boundaryPairs);
  }

  List<BoundaryPair> findBoundaryPairs(
    List<int> skinIndices,
    List<double> skinWeights,
    List<Set<int>> adjacency,
  ) {
    final int vertexCount = geometryVertexCount();
    final Set<String> visited = {};
    final List<BoundaryPair> pairs = [];

    for (int i = 0; i < vertexCount; i++) {
      final int offsetA = i * 4;
      final int boneA = skinIndices[offsetA];
      final double weightA = skinWeights[offsetA];
      if (weightA != 1.0) continue;

      for (final int j in adjacency[i]) {
        final int offsetB = j * 4;
        final int boneB = skinIndices[offsetB];
        final double weightB = skinWeights[offsetB];
        if (boneA == boneB || weightB != 1.0) continue;

        final String key = i < j ? '$i,$j' : '$j,$i';
        if (visited.contains(key)) continue;
        visited.add(key);

        SmoothingType smoothingType = SmoothingType.standard;
        if (classifier.isTorsoBoundary(boneA.toInt(), boneB.toInt())) {
          smoothingType = SmoothingType.torso;
        } else if (classifier.isLimbBoundary(boneA.toInt(), boneB.toInt())) {
          smoothingType = SmoothingType.limb;
        } else if (classifier.isExtremityBoundary(boneA.toInt(), boneB.toInt())) {
          smoothingType = SmoothingType.extremity;
        }

        pairs.add(BoundaryPair(
          vertexA: i,
          vertexB: j,
          boneA: boneA.toInt(),
          boneB: boneB.toInt(),
          smoothingType: smoothingType,
        ));
      }
    }
    return pairs;
  }

  void applyTorsoSmoothing(
    List<int> skinIndices,
    List<double> skinWeights,
    List<Set<int>> adjacency,
    Map<String, List<int>> positionToIndices,
    List<BoundaryPair> pairs,
  ) {
    final torsoPairs = pairs.where((p) => p.smoothingType == SmoothingType.torso).toList();
    if (torsoPairs.isEmpty) return;

    final Set<int> boundaryVertices = {};
    for (final pair in torsoPairs) {
      boundaryVertices.add(pair.vertexA);
      boundaryVertices.add(pair.vertexB);
    }

    final ringWeights = [0.5, 0.25, 0.10];
    final Set<int> processed = {};
    Set<int> currentRingVertices = {};

    for (final pair in torsoPairs) {
      blendVertexPair(skinIndices, skinWeights, positionToIndices, pair.vertexA, pair.vertexB, pair.boneA, pair.boneB, ringWeights[0]);
      processed.add(pair.vertexA);
      processed.add(pair.vertexB);
      currentRingVertices.add(pair.vertexA);
      currentRingVertices.add(pair.vertexB);
    }

    for (int ring = 1; ring < ringWeights.length; ring++) {
      final Set<int> nextRingVertices = {};
      final double secondaryWeight = ringWeights[ring];

      for (final int vertexIdx in currentRingVertices) {
        final int offset = vertexIdx * 4;
        final int primaryBone = skinIndices[offset];

        for (final int neighbor in adjacency[vertexIdx]) {
          if (processed.contains(neighbor)) continue;
          final int neighborOffset = neighbor * 4;
          final int neighborBone = skinIndices[neighborOffset];

          if (neighborBone != primaryBone) continue;
          if (skinWeights[neighborOffset] != 1.0) continue;

          final int otherBone = findNeighborBoneFromBoundary(vertexIdx, skinIndices, primaryBone.toInt());
          if (otherBone == -1) continue;

          final shared = getSharedVertices(neighbor, positionToIndices);
          for (final int idx in shared) {
            final int off = idx * 4;
            skinIndices[off + 0] = neighborBone;
            skinIndices[off + 1] = otherBone;
            skinWeights[off + 0] = 1.0 - secondaryWeight;
            skinWeights[off + 1] = secondaryWeight;
            skinIndices[off + 2] = 0;
            skinIndices[off + 3] = 0;
            skinWeights[off + 2] = 0;
            skinWeights[off + 3] = 0;
          }
          processed.add(neighbor);
          nextRingVertices.add(neighbor);
        }
      }
      currentRingVertices = nextRingVertices;
    }
  }
  void applyLimbSmoothing(
    List<int> skinIndices,
    List<double> skinWeights,
    Map<String, List<int>> positionToIndices,
    List<BoundaryPair> pairs,
  ) {
    final limbPairs = pairs.where((p) => p.smoothingType == SmoothingType.limb).toList();

    for (final pair in limbPairs) {
      final bool aIsParent = isParentOf(pair.boneA, pair.boneB);
      final bool bIsParent = isParentOf(pair.boneB, pair.boneA);

      if (aIsParent) {
        blendSingleSide(skinIndices, skinWeights, positionToIndices, pair.vertexB, pair.boneB, pair.boneA, 0.5);
      } else if (bIsParent) {
        blendSingleSide(skinIndices, skinWeights, positionToIndices, pair.vertexA, pair.boneA, pair.boneB, 0.5);
      } else {
        blendVertexPair(skinIndices, skinWeights, positionToIndices, pair.vertexA, pair.vertexB, pair.boneA, pair.boneB, 0.5);
      }
    }
  }

  void applyExtremitySmoothing(List<BoundaryPair> pairs) {
    // no-op by design; extremity↔extremity boundaries receive no blending
  }

  void applyStandardSmoothing(
    List<int> skinIndices,
    List<double> skinWeights,
    Map<String, List<int>> positionToIndices,
    List<BoundaryPair> pairs,
  ) {
    final standardPairs = pairs.where((p) => p.smoothingType == SmoothingType.standard).toList();
    for (final pair in standardPairs) {
      blendVertexPair(skinIndices, skinWeights, positionToIndices, pair.vertexA, pair.vertexB, pair.boneA, pair.boneB, 0.5);
    }
  }

  void blendVertexPair(
    List<int> skinIndices,
    List<double> skinWeights,
    Map<String, List<int>> positionToIndices,
    int vertexA,
    int vertexB,
    int boneA,
    int boneB,
    double secondaryWeight,
  ) {
    final double primaryWeight = 1.0 - secondaryWeight;
    final sharedA = getSharedVertices(vertexA, positionToIndices);

    for (final int idx in sharedA) {
      final int off = idx * 4;
      skinIndices[off + 0] = boneA;
      skinIndices[off + 1] = boneB;
      skinWeights[off + 0] = primaryWeight;
      skinWeights[off + 1] = secondaryWeight;
      skinIndices[off + 2] = 0;
      skinIndices[off + 3] = 0;
      skinWeights[off + 2] = 0;
      skinWeights[off + 3] = 0;
    }

    final sharedB = getSharedVertices(vertexB, positionToIndices);
    for (final int idx in sharedB) {
      final int off = idx * 4;
      skinIndices[off + 0] = boneB;
      skinIndices[off + 1] = boneA;
      skinWeights[off + 0] = primaryWeight;
      skinWeights[off + 1] = secondaryWeight;
      skinIndices[off + 2] = 0;
      skinIndices[off + 3] = 0;
      skinWeights[off + 2] = 0;
      skinWeights[off + 3] = 0;
    }
  }

  void blendSingleSide(
    List<int> skinIndices,
    List<double> skinWeights,
    Map<String, List<int>> positionToIndices,
    int vertex,
    int primaryBone,
    int secondaryBone,
    double secondaryWeight,
  ) {
    final double primaryWeight = 1.0 - secondaryWeight;
    final shared = getSharedVertices(vertex, positionToIndices);

    for (final int idx in shared) {
      final int off = idx * 4;
      skinIndices[off + 0] = primaryBone;
      skinIndices[off + 1] = secondaryBone;
      skinWeights[off + 0] = primaryWeight;
      skinWeights[off + 1] = secondaryWeight;
      skinIndices[off + 2] = 0;
      skinIndices[off + 3] = 0;
      skinWeights[off + 2] = 0;
      skinWeights[off + 3] = 0;
    }
  }

  bool isParentOf(int parentIndex, int childIndex) {
    if (parentIndex >= bones.length || childIndex >= bones.length) return false;
    final parentBone = bones[parentIndex];
    final childBone = bones[childIndex];
    return childBone.parent == parentBone;
  }

  int findNeighborBoneFromBoundary(int vertexIdx, List<int> skinIndices, int primaryBone) {
    final int offset = vertexIdx * 4;
    final int secondaryBone = skinIndices[offset + 1].toInt();
    if (secondaryBone != primaryBone && secondaryBone != 0) {
      return secondaryBone;
    }
    return -1;
  }

  List<int> getSharedVertices(int vertex, Map<String, List<int>> positionToIndices) {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return [vertex];
    
    final double x = positionAttribute.getX(vertex)!.toDouble();
    final double y = positionAttribute.getY(vertex)!.toDouble();
    final double z = positionAttribute.getZ(vertex)!.toDouble();
    final String key = '${x.toStringAsFixed(6)},${y.toStringAsFixed(6)},${z.toStringAsFixed(6)}';
    return positionToIndices[key] ?? [vertex];
  }

  Map<String, List<int>> buildPositionMap() {
    final int vertexCount = geometryVertexCount();
    final Map<String, List<int>> positionToIndices = {};
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return positionToIndices;

    for (int i = 0; i < vertexCount; i++) {
      final double x = positionAttribute.getX(i)!.toDouble();
      final double y = positionAttribute.getY(i)!.toDouble();
      final double z = positionAttribute.getZ(i)!.toDouble();
      final String key = '${x.toStringAsFixed(6)},${y.toStringAsFixed(6)},${z.toStringAsFixed(6)}';

      if (!positionToIndices.containsKey(key)) {
        positionToIndices[key] = [];
      }
      positionToIndices[key]!.add(i);
    }
    return positionToIndices;
  }

  List<Set<int>> buildVertexAdjacency() {
    final int vertexCount = geometryVertexCount();
    final List<Set<int>> adjacency = List.generate(vertexCount, (_) => <int>{});
    final indexAttribute = geometry.index;
    if (indexAttribute == null) return adjacency;

    final indices = indexAttribute.array;
    for (int i = 0; i < indices.length; i += 3) {
      final int a = indices[i].toInt();
      final int b = indices[i + 1].toInt();
      final int c = indices[i + 2].toInt();

      adjacency[a].add(b);
      adjacency[a].add(c);
      adjacency[b].add(a);
      adjacency[b].add(c);
      adjacency[c].add(a);
      adjacency[c].add(b);
    }
    return adjacency;
  }
}
