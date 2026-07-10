import 'package:three_js_math/three_js_math.dart';
import 'package:three_js_core/three_js_core.dart';

/// HeadWeightCorrector
/// Handles post-processing correction of vertex weights for "chibi" style characters
/// where large heads might incorrectly get weighted to arm bones instead of head bones.
///
/// This class will reassign vertices that are:
/// 1. Above a specified height threshold (preview plane height)
/// 2. Currently assigned to arm bones
/// 3. Should be assigned to the head bone instead
class HeadWeightCorrector {
  final BufferGeometry geometry;
  final List<Bone> bonesMasterData;
  final double previewPlaneHeight;

  HeadWeightCorrector(
    this.geometry,
    this.bonesMasterData,
    this.previewPlaneHeight,
  );

  /// Apply head weight correction to the skin indices and weights
  /// [skinIndices] Array of bone indices for each vertex (4 per vertex)
  /// [skinWeights] Array of bone weights for each vertex (4 per vertex)
  void applyHeadWeightCorrection(List<int> skinIndices, List<double> skinWeights) {
    final headBoneIndex = findHeadBoneIndex();
    if (headBoneIndex == -1) {
      return;
    } // Head weight correction skipped: DEF-head bone not found

    final armBoneIndices = findArmBoneIndices();
    if (armBoneIndices.isEmpty) {
      return;
    } // Head weight correction skipped: No arm bones found

    correctVertexWeights(skinIndices, skinWeights, headBoneIndex, armBoneIndices);
  }

  /// Find the index of the head bone (looking for "DEF-head" or similar)
  int findHeadBoneIndex() {
    // we only have this head corrector for humans right now, but
    // maybe add a more robust way in case it ever expands to other skeleton types
    final headBoneNames = ['DEF-head', 'head', 'Head', 'HEAD'];
    
    for (int i = 0; i < bonesMasterData.length; i++) {
      final boneName = bonesMasterData[i].name;
      // Check for exact matches first
      if (headBoneNames.contains(boneName)) {
        return i;
      }
      
      // Check for partial matches (case-insensitive)
      final lowerBoneName = boneName.toLowerCase();
      if (headBoneNames.any((name) => lowerBoneName.contains(name.toLowerCase()))) {
        return i;
      }
    }
    return -1; // Head bone not found
  }

  /// Find the indices of arm bones (looking for arm, shoulder, hand bones)
  List<int> findArmBoneIndices() {
    final armBoneKeywords = [
      'arm', 'shoulder', 'hand', 'finger', 'thumb', 'elbow', 'forearm',
      'upperarm', 'thumb', 'index', 'middle', 'ring', 'pinky'
    ];
    final List<int> armBoneIndices = [];
    
    for (int i = 0; i < bonesMasterData.length; i++) {
      final boneName = bonesMasterData[i].name.toLowerCase();
      // Check if bone name contains any arm-related keywords
      if (armBoneKeywords.any((keyword) => boneName.contains(keyword))) {
        armBoneIndices.add(i);
      }
    }
    return armBoneIndices;
  }

  /// Correct vertex weights for vertices above the height threshold
  int correctVertexWeights(
    List<int> skinIndices,
    List<double> skinWeights,
    int headBoneIndex,
    List<int> armBoneIndices,
  ) {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return 0;

    final int vertexCount = positionAttribute.array.length ~/ 3;
    int correctedCount = 0;

    for (int i = 0; i < vertexCount; i++) {
      final vertexPosition = Vector3().fromBuffer(positionAttribute, i);
      
      // Skip vertices below the height threshold
      if (vertexPosition.y <= previewPlaneHeight) {
        continue;
      }

      final int offset = i * 4; // each vertex has 4 slots for skinning weights and indices
      
      // Check if this vertex is primarily assigned to an arm bone
      final primaryBoneIndex = skinIndices[offset].toInt();
      final primaryWeight = skinWeights[offset];

      // If the primary bone is an arm bone and has significant weight, reassign to head
      // Reassign to head bone with 100% weight
      if (armBoneIndices.contains(primaryBoneIndex) && primaryWeight > 0.5) {
        skinIndices[offset] = headBoneIndex;
        skinIndices[offset + 1] = 0;
        skinIndices[offset + 2] = 0;
        skinIndices[offset + 3] = 0;
        
        skinWeights[offset] = 1.0;
        skinWeights[offset + 1] = 0.0;
        skinWeights[offset + 2] = 0.0;
        skinWeights[offset + 3] = 0.0;
        
        correctedCount++;
        continue;
      }

      // Also check secondary bones for arm assignments
      for (int j = 0; j < 4; j++) {
        final boneIndex = skinIndices[offset + j].toInt();
        final weight = skinWeights[offset + j];

        // If any arm bone has significant influence, reduce it and increase head influence
        if (armBoneIndices.contains(boneIndex) && weight > 0.3) {
          // Find if head is already in the influences
          int headSlot = -1;
          for (int k = 0; k < 4; k++) {
            if (skinIndices[offset + k].toInt() == headBoneIndex) {
              headSlot = k;
              break;
            }
          }

          // If head isn't already influencing, replace this arm bone with head
          if (headSlot == -1) {
            skinIndices[offset + j] = headBoneIndex; // Keep the same weight for smooth transition
          } else {
            // Head is already influencing, transfer this arm bone's weight to head
            skinWeights[offset + headSlot] += weight;
            skinWeights[offset + j] = 0.0;
            skinIndices[offset + j] = 0;
          }
          correctedCount++;
        }
      }

      // Normalize weights to ensure they sum to 1.0 since we changed them
      normalizeVertexWeights(skinWeights, offset);
    }
    return correctedCount;
  }

  /// Normalize weights for a single vertex to ensure they sum to 1.0
  void normalizeVertexWeights(List<double> skinWeights, int offset) {
    final totalWeight = skinWeights[offset] +
        skinWeights[offset + 1] +
        skinWeights[offset + 2] +
        skinWeights[offset + 3];
        
    if (totalWeight > 0) {
      skinWeights[offset] /= totalWeight;
      skinWeights[offset + 1] /= totalWeight;
      skinWeights[offset + 2] /= totalWeight;
      skinWeights[offset + 3] /= totalWeight;
    }
  }
}
