import 'dart:async';
import 'package:three_forge/src/m2m_viewer/src/generators.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_forge/src/m2m_viewer/src/utilities.dart';
import 'package:three_forge/src/m2m_viewer/steps/independent_bone_movement.dart';
import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_core_loaders/three_js_core_loaders.dart';
import 'package:three_js_math/three_js_math.dart';

class StepEditSkeleton {
  // Original armature data from the model data. A Skeleton type object is not
  // part of the original model data that is loaded
  Object3D editedArmature = Object3D();
  
  // Skeleton created from the armature that Three.js uses
  Skeleton threejsSkeleton = Skeleton([]);
  
  bool mirrorModeEnabled = true;
  bool meshDragPlacementEnabled = true;
  String? skinningAlgorithm;
  bool showDebug = true;
  Bone? currentlySelectedBone;
  Object3D? jointHoverPoint;
  Scene? mainSceneRef;
  
  // Preview plane state
  bool enableHeadWeightCorrection = false;
  double headWeightCorrectionHeight = 1.4; // default
  
  final Future<Texture?>? jointTexture = TextureLoader().fromAsset('assets/images/skeleton-joint-point.png');
  bool addedEventListeners = false;
  final IndependentBoneMovement independentBoneMovement = IndependentBoneMovement();
  
  // UI elements specific for this area
  SkeletonType? currentSkeletonType;

  // Stream infrastructure supporting modern platform notifications natively
  final StreamController<String> _eventController = StreamController<String>.broadcast();
  Stream<String> get stream => _eventController.stream;

  StepEditSkeleton();

  void begin(Scene mainScene, SkeletonType skeletonType) {
    bool localMirrorModeEnabled = mirrorModeEnabled;

    setMirrorModeEnabled(localMirrorModeEnabled);
    setMeshDragPlacementEnabled(true);
    mainSceneRef = mainScene;
  }

  bool showDebugging() {
    return showDebug;
  }

  void dispose() {
    _eventController.close();
  }

  /// [bone] The currently selected bone
  /// This is the bone that is currently selected in the UI while editing the skeleton.
  void setCurrentlySelectedBone(Bone? bone) {
    currentlySelectedBone = bone;
  }

  Bone? getCurrentlySelectedBone() {
    return currentlySelectedBone;
  }

  void setMirrorModeEnabled(bool value) {
    mirrorModeEnabled = value;
    _eventController.add('mirrorModeChanged');
  }

  bool isMirrorModeEnabled() {
    return mirrorModeEnabled;
  }

  void setMeshDragPlacementEnabled(bool value) {
    meshDragPlacementEnabled = value;
    _eventController.add('boneEditModeChanged');
  }

  bool isMeshDragPlacementEnabled() {
    return meshDragPlacementEnabled;
  }

  bool isBoneSelectable(Bone? bone) {
    if (bone == null) {
      return false;
    }
    if (!mirrorModeEnabled) {
      return true;
    }
    return !isRightSideBone(bone);
  }

  bool isRightSideBone(Bone bone) {
    final String normalizedBoneName = bone.name.toLowerCase();
    return RegExp(r'(^right_|^r_|_right$|_r$|\.right$|\.r$|-right$|-r$)').hasMatch(normalizedBoneName);
  }

  /// Find the mirrored counterpart of a bone by stripping side suffixes and
  /// matching against the rest of the skeleton. Returns null for centre-line
  /// bones (spine, neck, head, etc.) that have no counterpart.
  Bone? findMirrorBone(Bone bone) {
    final String baseName = Utility.calculateBoneBaseName(bone.name);
    
    // Explicit loop replacing JavaScript .find() for index and safety compliance
    for (int i = 0; i < threejsSkeleton.bones.length; i++) {
      final candidate = threejsSkeleton.bones[i];
      final String candidateBase = Utility.calculateBoneBaseName(candidate.name);
      
      if (candidateBase == baseName && candidate.name != bone.name) {
        return candidate;
      }
    }
    return null;
  }

  String? algorithm() {
    return skinningAlgorithm;
  }

  /// Toggle the visibility of the preview plane
  /// [isEnabled] Whether the plane should be visible
  void setUseHeadWeightCorrection(bool isEnabled) {
    enableHeadWeightCorrection = isEnabled;
  }

  /// Get the current visibility state of the preview plane
  bool useHeadWeightCorrection() {
    return enableHeadWeightCorrection;
  }

  /// Set the height of the preview plane
  /// [height] The Y coordinate height for the plane
  void setPreviewPlaneHeight(double height) {
    headWeightCorrectionHeight = height;
  }

  /// Get the current height of the preview plane
  double getPreviewPlaneHeight() {
    return headWeightCorrectionHeight;
  }

  void removeEventListeners() {
    // Platform-independent layout cleanup stubs
  }

  void cleanupOnExitStep() {
    removeEventListeners();
    clearHoverPointIfExists();
  }

  void clearHoverPointIfExists() {
    if (jointHoverPoint != null && mainSceneRef != null) {
      mainSceneRef!.remove(jointHoverPoint!);
      jointHoverPoint = null;
    }
  }
  /// Take original armature that we are editing and create a skeleton that Three.js can use
  void loadOriginalArmatureFromModel(Object3D armature) {
    editedArmature = armature.clone();
    createThreejsSkeletonObject();
    independentBoneMovement.setRestPose(threejsSkeleton);
  }

  Skeleton createThreejsSkeletonObject() {
    // create skeleton and helper to visualize
    if (editedArmature.children.isNotEmpty) {
      threejsSkeleton = Generators.createSkeleton(editedArmature.children[0]);
    } else {
      threejsSkeleton = Skeleton([]);
    }
        
    // update the world matrix for the skeleton
    // without this the skeleton helper won't appear when the bones are first loaded
    if (threejsSkeleton.bones.isNotEmpty) {
      threejsSkeleton.bones[0].updateWorldMatrix(true, true);
    }
    
    return threejsSkeleton;
  }

  Object3D armature() {
    return editedArmature;
  }

  Skeleton skeleton() {
    return threejsSkeleton;
  }

  void applyMirrorMode(Bone selectedBone, String transformType) {
    final mirrorBone = findMirrorBone(selectedBone);
    if (mirrorBone == null) {
      return; // centre-line bone (head, neck, spine) — no counterpart
    }

    if (transformType == 'translate') {
      // move the mirror bone in the -X value of the transform control
      // this will mirror the movement of the bone
      mirrorBone.position.setFrom(Vector3(
        -selectedBone.position.x.toDouble(),
        selectedBone.position.y.toDouble(),
        selectedBone.position.z.toDouble(),
      ));
    }

    if (transformType == 'rotate') {
      final euler = Euler(
        selectedBone.rotation.x.toDouble(),
        -selectedBone.rotation.y.toDouble(),
        -selectedBone.rotation.z.toDouble(),
      );
      mirrorBone.quaternion.setFromEuler(euler);
    }

    // updateWorldMatrix(updateParents, updateChildren) - propagate changes up and down the hierarchy
    mirrorBone.updateWorldMatrix(true, true);
  }

  /// [event] This will be called every mouse move event
  /// [hoverDistance] Maximum selection boundary distance
  void calculateBoneHoverEffect(dynamic event, Camera camera, double hoverDistance) {
    // create a raycaster to detect the bone that is being hovered over
    // we will only have a hover effect if the mouse is close enough to the bone
    final raycastResult = Utility.raycastClosestBoneTest(camera, event, threejsSkeleton);
    final closestBone = raycastResult.bone;
    final closestDistance = raycastResult.distance;

    // only do selection if we are close
    if (closestDistance > hoverDistance) {
      updateBoneHoverPointPosition(null);
      return;
    }
    if (!isBoneSelectable(closestBone)) {
      updateBoneHoverPointPosition(null);
      return;
    }
    
    updateBoneHoverPointPosition(closestBone);
  }

  /// Create a hover effect for the bone that would be selected for bone editing
  void updateBoneHoverPointPosition(Bone? bone) {
    // create hover point sphere for when our mouse gets close to a bone joint
    if (jointHoverPoint == null) {
      // Create the hover point if it doesn't exist
      final geometry = BufferGeometry();
      geometry.setAttributeFromString('position', Float32BufferAttribute.fromList([0.0, 0.0, 0.0], 3)); // Single vertex at origin
      
      final material = PointsMaterial.fromMap({
        'color': 0x69a1d0, // Blue color
        'size': 30.0, // Size of the point in pixels
        'sizeAttenuation': false, // Disable size attenuation
        'depthTest': false, // always render on top
        //'map': jointTexture, // Use a circular texture
        'opacity': 0.7,
        'transparent': true // Enable transparency for the circular texture
      });
      
      jointHoverPoint = Points(geometry, material);
      jointHoverPoint!.renderOrder = 100; // render on top of everything else
      jointHoverPoint!.name = 'Joint Hover Point';
      mainSceneRef?.add(jointHoverPoint!);
    }

    if (bone != null) {
      // update the position of the hover point
      final worldPosition = Utility.worldPositionFromObject(bone);
      jointHoverPoint!.position.setFrom(worldPosition);
      jointHoverPoint!.updateWorldMatrix(true, true);
    } else {
      // remove the hover point if we are not hovering over a bone
      if (jointHoverPoint != null) {
        mainSceneRef?.remove(jointHoverPoint!);
        jointHoverPoint = null;
      }
    }
  }
}
