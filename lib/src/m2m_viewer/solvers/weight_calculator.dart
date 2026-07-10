import '../src/skeleton_type.dart';
import '../src/rig_config.dart';
import '../src/utilities.dart';
import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_math/three_js_math.dart';

/// Handles the core bone-to-vertex weight calculation logic.
/// Determines which bone each vertex is closest to using midpoint-to-child distances,
/// with special handling for hip/pelvis regions.
class WeightCalculator {
  final List<Bone> bones;
  final BufferGeometry geometry;
  final SkeletonType? skeletonType;
  
  List<Vector3> cachedMedianChildBonePositions = [];
  final Map<Bone, int> boneObjectToIndex = {};
  double distanceToBottomOfPositionTrackingBone = 0.0;
  
  // Each index will be a bone index. The value will be a list of vertex indices that belong to that bone
  final List<List<int>> bonesVertexSegmentation = [];
  
  // Bone indices that should never receive vertex weights: the root (global
  // transform only) and leaf/orientation bones (finger/toe/tail tips, etc.)
  final Set<int> skippedBoneIndices = {};

  WeightCalculator(this.bones, this.geometry, this.skeletonType);

  /// Pre-computes cached values needed for weight calculations.
  /// Must be called before calculateMedianBoneWeights.
  void initializeCaches() {
    cachedMedianChildBonePositions = bones.map((b) => midpointToChild(b)).toList();
    
    for (int idx = 0; idx < bones.length; idx++) {
      boneObjectToIndex[bones[idx]] = idx;
    }

    // The root bone is only for global transform changes, and leaf/orientation
    // bones exist only to orient their parent — neither should be assigned any
    // vertices. Compute the skip set once instead of checking names per vertex.
    for (int idx = 0; idx < bones.length; idx++) {
      final b = bones[idx];
      if (b.name == 'root' || Utility.isLeafBone(b)) {
        skippedBoneIndices.add(idx);
      }
    }
    
    distanceToBottomOfPositionTrackingBone = calculateDistanceToBottomOfPositionTrackingBone();
  }

  List<Vector3> getCachedMedianChildBonePositions() {
    return cachedMedianChildBonePositions;
  }

  /// Assigns the closest bone to each vertex.
  /// Modifies the skinIndices and skinWeights arrays in place.
  void calculateMedianBoneWeights(List<int> skinIndices, List<double> skinWeights) {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return;

    final int vertexCount = positionAttribute.array.length ~/ 3;

    // Expand the segmentation list dimension dynamically to fit indices safely
    while (bonesVertexSegmentation.length < bones.length) {
      bonesVertexSegmentation.add([]);
    }

    for (int i = 0; i < vertexCount; i++) {
      final vertexPosition = Vector3().fromBuffer(positionAttribute, i);
      double closestBoneDistance = 1000.0; // arbitrary large number to start with
      int closestBoneIndex = 0;

      for (int idx = 0; idx < bones.length; idx++) {
        final bone = bones[idx];
        
        // Skip the root bone (global transform only) and leaf/orientation bones.
        // See skippedBoneIndices, computed once in initializeCaches.
        if (skippedBoneIndices.contains(idx)) {
          continue;
      }

        // Hip bones should have custom logic for distance. If the distance is too far away we should ignore it
        // This will help with hips when left/right legs could be closer than knee bones
        if (skeletonType == SkeletonType.human && (bone.name.contains('hips') || bone.name.contains('pelvis'))) {
          // If the intersection point is lower than the vertex position, that means the vertex is below
          // the hips area, and is part of the left or right leg...ignore that result
          if (distanceToBottomOfPositionTrackingBone < vertexPosition.y) {
            continue; // This vertex is below our crotch area, so it cannot be part of our hips
          }
        }

        final double distance = cachedMedianChildBonePositions[idx].distanceTo(vertexPosition);
        if (distance < closestBoneDistance) {
          closestBoneDistance = distance;
          closestBoneIndex = idx;
        }
      }

      bonesVertexSegmentation[closestBoneIndex].add(i);

      // Assign to final weights. Closest bone is always 100% weight
      skinIndices.addAll([closestBoneIndex, 0, 0, 0]);
      skinWeights.addAll([1.0, 0.0, 0.0, 0.0]);
    }
  }

  Vector3 midpointToChild(Bone bone) {
    final bonePosition = Utility.worldPositionFromObject(bone);
    if (bone.children.isEmpty || bone.children[0] is! Bone) {
      return bonePosition.clone();
    }
    
    // Assume first child is the relevant one
    final child = bone.children[0] as Bone;
    final childPosition = Utility.worldPositionFromObject(child);
    return Vector3().lerpVectors(bonePosition, childPosition, 0.5);
  }

  // Every vertex checks to see if it is below the hips area,
  // so do this calculation once and cache it for the lookup later
  double calculateDistanceToBottomOfPositionTrackingBone() {
    final rigConfig = skeletonType == null?null:RigConfig.bySkeletonType(skeletonType!);
    final String positionTrackingBoneName = rigConfig?.positionTrackingBoneName ?? 'UNKNOWN POSITION BONE';
    
    Bone? positionTrackingBoneObject;
    try {
      positionTrackingBoneObject = bones.firstWhere((b) {
        return b.name.toLowerCase().contains(positionTrackingBoneName.toLowerCase());
      });
    } catch (_) {
      positionTrackingBoneObject = null;
    }

    if (positionTrackingBoneObject == null) {
      throw Exception('Position tracking bone not found');
    }

    final int boneIndex = bones.indexWhere((b) => b == positionTrackingBoneObject);
    final bonePosition = cachedMedianChildBonePositions[boneIndex];
    final Vector3? intersectionPoint = castIntersectionRayDownFromBone(positionTrackingBoneObject);
    
    // Get the distance from the bone point to the intersection point
    double distanceToBottom = intersectionPoint?.distanceTo(bonePosition) ?? 0.0;
    distanceToBottom *= 1.1; // buffer zone to make sure to include vertices at intersection
    
    return distanceToBottom;
  }

  Vector3? castIntersectionRayDownFromBone(Bone bone) {
    final raycaster = Raycaster();
    
    // Set the ray's origin to the bone's world position
    final int boneIndex = bones.indexWhere((b) => b == bone);
    final bonePosition = cachedMedianChildBonePositions[boneIndex];
    
    // Direction is straight down to find the pelvis "gap"
    raycaster.set(bonePosition, Vector3(0, -1, 0));

    // Create a temporary mesh from geometry for raycasting
    final tempMesh = Mesh(geometry, MeshBasicMaterial());
    if (tempMesh.material != null) {
      tempMesh.material!.side = DoubleSide;
    }

    // Perform the intersection test
    const bool recursiveCheckChildObjects = false;
    final intersections = raycaster.intersectObject(tempMesh, recursiveCheckChildObjects);
    
    if (intersections.isNotEmpty) {
      // Return the position of the first intersection
      return intersections[0].point;
    }

    // Return null if no intersection is found
    return null;
  }
}
