import './bone_classifier.dart';
import '../src/utilities.dart';
import 'package:three_js_math/three_js_math.dart';
import 'package:three_js_core/three_js_core.dart';

/// Reassigns "parent-side" vertices away from extremity bones.
///
/// Extremity bones (fingers, toes) are short, so the closest-midpoint weight
/// assignment can grab vertices that actually sit *behind* the bone's start
/// joint — e.g. knuckle/palm vertices getting pulled onto a finger bone. When
/// that finger bends, those vertices deform along with it, which looks wrong.
///
/// For each vertex owned by an extremity bone, this checks whether the vertex
/// lies on the parent side of the bone's start joint (a negative projection
/// along the bone's axis toward its child). If so, the vertex is reassigned to
/// the bone's parent, so the knuckle stays with the hand instead of the finger.
class ExtremityWeightCorrector {
  final BufferGeometry geometry;
  final List<Bone> bones;
  final BoneClassifier classifier;
  final Map<Bone, int> boneToIndex = {};

  ExtremityWeightCorrector(this.geometry, this.bones)
      : classifier = BoneClassifier(bones) {
    for (int idx = 0; idx < bones.length; idx++) {
      boneToIndex[bones[idx]] = idx;
    }
  }

  /// Walks every vertex assigned to an extremity bone and reassigns it to the
  /// bone's parent when it sits behind the bone's start joint.
  /// Modifies skin_indices in place. Runs before smoothing so the corrected
  /// assignments are what the smoother sees.
  void applyExtremityWeightCorrection(List<int> skinIndices, List<double> skinWeights) {
    // In Dart three_js, access buffer arrays via attributes['position'].array
    final positionAttribute = geometry.attributes['position'] as Float32BufferAttribute?;
    if (positionAttribute == null) return;
    
    final int vertexCount = positionAttribute.array.length ~/ 3;

    /// Cache the bone axis (start joint + direction toward child) for each
    /// extremity bone so we don't recompute it per vertex.
    final boneAxes = buildExtremityBoneAxes();

    for (int i = 0; i < vertexCount; i++) {
      final int offset = i * 4;
      final int boneIndex = skinIndices[offset].toInt();
      final axis = boneAxes[boneIndex];

      if (axis == null) continue; // not an extremity bone (or has no valid parent)

      final vertexPosition = Vector3().fromBuffer(positionAttribute, i);
      final toVertex = vertexPosition.sub(axis.head);

      /// Negative projection means the vertex is behind the start joint, on the
      /// parent's side of the bone — reassign it to the parent.
      if (toVertex.dot(axis.direction) < 0) {
        skinIndices[offset] = axis.parentIndex;
      }
    }
  }

  /// Builds, for each extremity bone that has a parent bone in our list, the
  /// start-joint position, the axis pointing toward its child, and the parent
  /// bone index. Leaf extremity bones (no child) fall back to the direction
  /// coming from the parent joint.
  Map<int, ExtremityBoneAxis> buildExtremityBoneAxes() {
    final Map<int, ExtremityBoneAxis> axes = {};

    for (int idx = 0; idx < bones.length; idx++) {
      final bone = bones[idx];
      if (classifier.getCategory(idx) != BoneCategory.extremity) continue;

      final parent = bone.parent;
      if (parent == null) continue;
      if (parent is! Bone) continue;

      final parentIndex = boneToIndex[parent];
      if (parentIndex == null) continue; // parent isn't a skinning bone (e.g. armature root)

      final head = Utility.worldPositionFromObject(bone);

      /// Axis points from the start joint toward the child (down the finger).
      /// For leaf bones with no child, use the direction away from the parent.
      Vector3 direction;
      if (bone.children.isNotEmpty) {
        final childHead = Utility.worldPositionFromObject(bone.children[0]);
        direction = Utility.directionBetweenPoints(head, childHead);
      } else {
        final parentHead = Utility.worldPositionFromObject(parent);
        direction = Utility.directionBetweenPoints(parentHead, head);
      }

      axes[idx] = ExtremityBoneAxis(
        head: head,
        direction: direction,
        parentIndex: parentIndex,
      );
    }

    return axes;
  }
}

/// Private structural helper model to represent map value pairs in Dart 
/// without relying on loose/untyped JS inline anonymous maps.
class ExtremityBoneAxis {
  final Vector3 head;
  final Vector3 direction;
  final int parentIndex;

  ExtremityBoneAxis({
    required this.head,
    required this.direction,
    required this.parentIndex,
  });
}
