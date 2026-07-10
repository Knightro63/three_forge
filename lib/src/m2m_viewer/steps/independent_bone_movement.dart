import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_math/three_js_math.dart';

class SnapshotItem {
  final Vector3 pos;
  final Quaternion rot;

  SnapshotItem({required this.pos, required this.rot});
}

/// Encapsulates the "Move Bone Independently" feature for the Edit Skeleton step.
///
/// When enabled, moving a bone will not drag its children along with it. Instead,
/// each direct bone-child's world position is snapshotted at the start of a drag,
/// and then re-expressed in the (moving) parent's local frame every frame so that
/// the children appear stationary in world space.
///
/// If mirror mode is also active the same behaviour is applied to the mirror bone's
/// children so that both sides of the skeleton stay in sync.
class IndependentBoneMovement {
  bool enabledValue = false;
  final Map<String, Vector3> childrenInitialWorldPositions = {};
  final Map<String, Quaternion> childrenInitialWorldRotations = {};
  final Map<String, Vector3> restBoneWorldPositions = {};
  final Map<String, Quaternion> restBoneWorldRotations = {};

  bool isEnabled() {
    return enabledValue;
  }

  void setEnabled(bool value) {
    enabledValue = value;
  }

  /// Capture the initial (rest) world-space transforms for all bones.
  /// This should be called once when a fresh editable skeleton is created.
  void setRestPose(Skeleton skeleton) {
    restBoneWorldPositions.clear();
    restBoneWorldRotations.clear();
    
    for (int i = 0; i < skeleton.bones.length; i++) {
      final bone = skeleton.bones[i];
      final worldPos = Vector3();
      final worldRot = Quaternion();
      bone.getWorldPosition(worldPos);
      bone.getWorldQuaternion(worldRot);
      restBoneWorldPositions[bone.uuid] = worldPos.clone();
      restBoneWorldRotations[bone.uuid] = worldRot.clone();
    }
  }

  /// Snapshot the world-space position and rotation of each direct bone child
  /// at drag start. Clears any previously stored transforms first.
  /// When mirror mode is also active, pass the mirror bone as the second argument
  /// so its children are tracked in the same pass.
  void recordDragStart(Bone bone, [Bone? mirrorBone]) {
    childrenInitialWorldPositions.clear();
    childrenInitialWorldRotations.clear();
    snapshotDirectChildren(bone);
    
    if (mirrorBone != null) {
      snapshotDirectChildren(mirrorBone);
    }
  }

  /// Re-pin the direct children of a bone to their snapshotted world transforms.
  /// Call this every frame while the bone is being dragged.
  /// When mirror mode is also active, pass the mirror bone as the second argument
  /// so its children are pinned in the same call.
  void apply(Bone bone, [Bone? mirrorBone]) {
    applyToBone(bone);
    if (mirrorBone != null) {
      applyToBone(mirrorBone);
    }
  }

  /// At drag end, update rotation data for the moved bone AND its parent bone.
  ///
  /// When you translate a bone (e.g. elbow), two rotations change:
  /// 1. The PARENT bone (e.g. upper arm) — because the direction from parent
  /// to the moved child has changed.
  /// 2. The moved bone itself — because the direction from it to its own
  /// children has changed (children were pinned in place).
  ///
  /// After each rotation update the affected bone's children are re-pinned so
  /// their world-space transforms are preserved.
  void finalizeDrop(Bone bone, [Bone? mirrorBone]) {
    finalizeBoneWithParent(bone);
    if (mirrorBone != null) {
      finalizeBoneWithParent(mirrorBone);
    }
  }

  void finalizeBoneWithParent(Bone bone) {
    // Snapshot world transforms of the moved bone and its children
    // These are the "ground truth" we want to preserve through rotation updates
    final Map<String, SnapshotItem> snapshot = {};
    snapshotBoneAndChildren(bone, snapshot);

    // - Step 1: Update the PARENT bone's rotation --------------
    // The parent-to-child direction changed because the child was translated.
    final dynamic parentNode = bone.parent;
    final Bone? parentBone = (parentNode != null && isBone(parentNode)) ? parentNode as Bone : null;
    
    if (parentBone != null) {
      // Also snapshot siblings so they can be re-pinned after parent rotates
      for (int i = 0; i < parentBone.children.length; i++) {
        final sibling = parentBone.children[i];
        if (sibling == bone || !isBone(sibling)) {
          continue;
        }
        snapshotBoneAndChildren(sibling as Bone, snapshot);
      }
      finalizeBoneRotationFromRestPose(parentBone);
      // Re-pin ALL parent children (moved bone + siblings) to their snapshots
      repinChildrenFromSnapshot(parentBone, snapshot);
    }

    // - Step 2: Update the MOVED bone's rotation ---------------
    // The bone-to-child direction changed because children were pinned in place.
    finalizeBoneRotationFromRestPose(bone);
    // Re-pin the moved bone's children to their snapshots
    repinChildrenFromSnapshot(bone, snapshot);
  }
  void snapshotBoneAndChildren(Bone bone, Map<String, SnapshotItem> out) {
    final pos = Vector3();
    final rot = Quaternion();
    bone.getWorldPosition(pos);
    bone.getWorldQuaternion(rot);
    out[bone.uuid] = SnapshotItem(pos: pos.clone(), rot: rot.clone());

    for (int i = 0; i < bone.children.length; i++) {
      final child = bone.children[i];
      if (!isBone(child)) {
        continue;
      }
      final childPos = Vector3();
      final childRot = Quaternion();
      child.getWorldPosition(childPos);
      child.getWorldQuaternion(childRot);
      out[child.uuid] = SnapshotItem(pos: childPos.clone(), rot: childRot.clone());
    }
  }

  void repinChildrenFromSnapshot(Bone bone, Map<String, SnapshotItem> snapshot) {
    final boneWorldRot = Quaternion();
    bone.getWorldQuaternion(boneWorldRot);
    final invBoneWorldRot = boneWorldRot.clone().invert();

    for (int i = 0; i < bone.children.length; i++) {
      final childNode = bone.children[i];
      if (!isBone(childNode)) {
        continue;
      }
      final child = childNode as Bone;
      final snap = snapshot[child.uuid];
      if (snap == null) {
        continue;
      }

      final localPos = snap.pos.clone();
      bone.worldToLocal(localPos);
      child.position.setFrom(localPos);
      
      final localRot = invBoneWorldRot.clone().multiply(snap.rot);
      child.quaternion.setFrom(localRot);
      child.updateWorldMatrix(true, true);
    }
  }

  void snapshotDirectChildren(Bone bone) {
    for (int i = 0; i < bone.children.length; i++) {
      final child = bone.children[i];
      if (!isBone(child)) {
        continue;
      }
      final worldPos = Vector3();
      final worldRot = Quaternion();
      child.getWorldPosition(worldPos);
      child.getWorldQuaternion(worldRot);
      childrenInitialWorldPositions[child.uuid] = worldPos.clone();
      childrenInitialWorldRotations[child.uuid] = worldRot.clone();
    }
  }

  void applyToBone(Bone bone) {
    final parentWorldRotation = Quaternion();
    bone.getWorldQuaternion(parentWorldRotation);
    final inverseParentWorldRotation = parentWorldRotation.clone().invert();

    for (int i = 0; i < bone.children.length; i++) {
      final childNode = bone.children[i];
      if (!isBone(childNode)) {
        continue;
      }
      final child = childNode as Bone;
      final initialWorldPos = childrenInitialWorldPositions[child.uuid];
      final initialWorldRot = childrenInitialWorldRotations[child.uuid];
      if (initialWorldPos == null) {
        continue;
      }

      final localPos = initialWorldPos.clone();
      bone.worldToLocal(localPos);
      child.position.setFrom(localPos);

      if (initialWorldRot != null) {
        final localRot = inverseParentWorldRotation.clone().multiply(initialWorldRot);
        child.quaternion.setFrom(localRot);
      }
      child.updateWorldMatrix(true, true);
    }
  }

  void finalizeBoneRotationFromRestPose(Bone bone) {
    final restWorldRotation = restBoneWorldRotations[bone.uuid];
    final restDirection = averageChildDirectionFromRestPose(bone);
    final currentDirection = averageChildDirectionFromCurrentPose(bone);

    if (restWorldRotation == null || restDirection == null || currentDirection == null) {
      return;
    }

    final worldRotationDelta = Quaternion().setFromUnitVectors(restDirection, currentDirection);
    final targetWorldRotation = worldRotationDelta.multiply(restWorldRotation.clone());
    final parentWorldRotation = Quaternion();

    final dynamic parentNode = bone.parent;
    if (parentNode != null) {
      parentNode.getWorldQuaternion(parentWorldRotation);
    } else {
      parentWorldRotation.identity();
    }

    final targetLocalRotation = parentWorldRotation.clone().invert().multiply(targetWorldRotation);
    bone.quaternion.setFrom(targetLocalRotation);
    bone.updateWorldMatrix(true, true);
  }

  Vector3? averageChildDirectionFromRestPose(Bone bone) {
    final boneRestWorldPosition = restBoneWorldPositions[bone.uuid];
    if (boneRestWorldPosition == null) {
      return null;
    }

    final averagedDirection = Vector3(0.0, 0.0, 0.0);
    int directionCount = 0;

    for (int i = 0; i < bone.children.length; i++) {
      final child = bone.children[i];
      if (!isBone(child)) {
        continue;
      }
      final childRestWorldPosition = restBoneWorldPositions[child.uuid];
      if (childRestWorldPosition == null) {
        continue;
      }

      final childDirection = childRestWorldPosition.clone().sub(boneRestWorldPosition);
      if (childDirection.length2 < 1e-8) {
        continue;
      }

      childDirection.normalize();
      averagedDirection.add(childDirection);
      directionCount += 1;
    }

    if (directionCount == 0 || averagedDirection.length2 < 1e-8) {
      return null;
    }

    return averagedDirection.normalize();
  }

  /// Computes direction from current running tracking states safely
  Vector3? averageChildDirectionFromCurrentPose(Bone bone) {
    final boneWorldPosition = Vector3();
    bone.getWorldPosition(boneWorldPosition);
    
    final averagedDirection = Vector3(0.0, 0.0, 0.0);
    int directionCount = 0;

    for (int i = 0; i < bone.children.length; i++) {
      final childNode = bone.children[i];
      if (!isBone(childNode)) {
        continue;
      }
      final childWorldPosition = Vector3();
      childNode.getWorldPosition(childWorldPosition);
      
      final childDirection = childWorldPosition.sub(boneWorldPosition);
      if (childDirection.length2 < 1e-8) {
        continue;
      }

      childDirection.normalize();
      averagedDirection.add(childDirection);
      directionCount += 1;
    }

    if (directionCount == 0 || averagedDirection.length2 < 1e-8) {
      return null;
    }

    return averagedDirection.normalize();
  }

  bool isBone(dynamic value) {
    if (value == null) {
      return false;
    }
    // Safely check three_js node tracking descriptors 
    if (value is Bone) {
      return true;
    }
    try {
      return value.isBone == true;
    } catch (_) {
      return false;
    }
  }
}
