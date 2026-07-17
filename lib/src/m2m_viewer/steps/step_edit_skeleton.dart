import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:three_forge/src/m2m_viewer/src/model_preview_display.dart';
import 'package:three_forge/src/m2m_viewer/src/utilities.dart';
import 'package:three_forge/src/navigation/navigation.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';

class StepEditSkeleton {
  final Function setState;
  final TransformControls control;
  final three.Camera camera;

  List<three.Mesh> skeletonHandles = [];
  three.Raycaster raycaster = three.Raycaster();
  three.Mesh? _hoveredClickMesh;

  double get previewPlaneHeight => selectBox.position.y;
  three.Object3D? armature;
  SkeletonHelper? skeleton;
  ModelPreviewDisplay meshPreviewDisplayType = ModelPreviewDisplay.weightPainted;

  bool _animating = true;
  bool get animating => _animating;
  set animating(bool val){
    _animating = val;
    showAll(_animating);
  }

  bool solving = false;
  three.CCDIKSolver? ikSolver;

  bool _mirror = true;
  bool get mirror => _mirror;
  set mirror(bool val){
    _mirror = val;
    _showRightSide(_mirror);
  }

  three.Mesh _plane = three.Mesh(three.PlaneGeometry(),three.MeshBasicMaterial.fromMap({
      'color': 0x00ff00,
      'transparent': true,
      'opacity': 0.7,
      //'depthWrite': true,
      'depthTest': true,
      'side': three.DoubleSide
    }));

    late three.Mesh selectBox = three.Mesh(
      three.BoxGeometry(1,1,0.01),
      three.MeshBasicMaterial.fromMap({
        'color': 0xff0000,
        'transparent': true,
        'opacity': 0.2,
        'visible': false
      })
    )..add(_plane)
    ..userData['visual_dot'] = _plane
    ..userData['head_weight'] = true
    ..visible = false
    ..rotateX(-math.pi/2)
    ..translateZ(0.55);

  StepEditSkeleton(this.camera,this.control, this.setState);

  void setArmature(
    three.Object3D armature, 
    SkeletonHelper skeleton,
    three.Scene scene,
    [bool ik = false]
  ){
    this.armature = armature;
    armature.userData['skeleton'] = skeleton;
    this.skeleton = skeleton;

    attachInteractivePointsToHelper(skeleton);

    if(ik){
      _mirror = false;
      animating = false;
      meshPreviewDisplayType = ModelPreviewDisplay.textured;
      //ikSolver = three.CCDIKSolver(armature,armature.skeleton!);
    }
    else{
      _mirror = true;
      _animating = true;
      meshPreviewDisplayType = ModelPreviewDisplay.weightPainted;
    }

    scene.add(armature);
    scene.add(skeleton);
  }

  void attachInteractivePointsToHelper(SkeletonHelper skeletonHelper) {
    skeletonHandles.clear();
    skeletonHandles.add(selectBox);

    final visualGeom = three.SphereGeometry(0.01, 16, 16);
    final clickGeom = three.SphereGeometry(0.025, 16, 16);
    final clickMat = three.MeshBasicMaterial.fromMap({
      'color': 0xff0000, 
      'visible': false,
    });

    for (final bone in skeletonHelper.bones) {
      final visualMat = three.MeshBasicMaterial.fromMap({
        'color': 0x00ff00,
        'transparent': true,
        'opacity': 0.8,
        'depthWrite': false,
        'depthTest': false,
      });
      // Create the visual dot
      final clickMesh = three.Mesh(clickGeom, clickMat);
      final visualMesh = three.Mesh(visualGeom, visualMat);
      clickMesh.userData['bone_target'] = bone;
      clickMesh.userData['visual_dot'] = visualMesh;

      bone.add(clickMesh..add(visualMesh));
      skeletonHandles.add(clickMesh);
    }

    _showRightSide(mirror);
  }

  void stop(){
    selectBox.visible = false;
    
  }

  void _showRightSide(bool value){
    for(final handle in skeletonHandles){
      final three.Bone? bone = handle.userData['bone_target'];
      final three.Mesh? visualMesh = handle.userData['visual_dot'];
      if(bone != null && isRightSideBone(bone)){
        visualMesh?.material?.opacity = value?0.2:0.8;
      }
    }
  }
  
  void showAll(bool value){
    for(final handle in skeletonHandles){
      final three.Bone? bone = handle.userData['bone_target'];
      final three.Mesh? visualMesh = handle.userData['visual_dot'];
      if(bone != null){
        visualMesh?.material?.opacity = !value?0.2:0.8;
      }
    }
  }

  void onPointerMove(three.Vector2 normalizedMouse) {
    // If the rigging tools are hidden, do nothing
    if (armature == null) return;

    raycaster.setFromCamera(normalizedMouse, camera);
    final intersects = raycaster.intersectObjects(skeletonHandles, true);

    if (intersects.isNotEmpty) {
      final hitClickMesh = intersects.first.object as three.Mesh?;
      
      // If we hovered over a NEW joint handle mesh
      if (hitClickMesh != _hoveredClickMesh) {
        final three.Bone? underlyingBone = hitClickMesh?.userData['bone_target'];
        if(!isBoneSelectable(underlyingBone))return;

        // 1. Reset the previous hovered item back to normal
        _resetHoverState();
        _hoveredClickMesh = hitClickMesh;

        if (_hoveredClickMesh != null && _hoveredClickMesh!.userData['visual_dot'] != null) {
          final three.Mesh visualDot = _hoveredClickMesh!.userData['visual_dot'];
          final three.Material material = visualDot.material!;

          // 2. Change the visual dot to a bright yellow/white highlight color
          material.color.setFromHex32(0xff00ff); 
          material.opacity = 1.0; // Crank up the opacity for max brightness
          //material.needsUpdate = true;
        }
      }
    } else {
      // If the mouse is in empty space, reset whatever was highlighted
      _resetHoverState();
    }
  }

  // Helper to reset the dot back to its default semi-transparent green color
  void _resetHoverState() {
    if (_hoveredClickMesh != null && _hoveredClickMesh!.userData['visual_dot'] != null) {
      final three.Mesh visualDot = _hoveredClickMesh!.userData['visual_dot'];
      final three.Material material = visualDot.material!;

      material.color.setFromHex32(0x00ff00); // Back to bright green
      material.opacity = 0.8;          // Back to original transparency
      material.needsUpdate = true;
      
      _hoveredClickMesh = null;
    }
  }

  void onPointerDown(three.Vector2 normalizedMouse) {
    if (control.dragging || armature == null) return;
    control.detach();

    raycaster.setFromCamera(normalizedMouse, camera);
    
    final intersects = raycaster.intersectObjects(skeletonHandles, true);
    if (intersects.isNotEmpty) {
      final hitHandle = intersects.first.object;
      
      // Safety check against explicit hidden layer states
      if (hitHandle == null || hitHandle.visible == false) return;

      final three.Bone? underlyingBone = hitHandle.userData['bone_target'];

      if (underlyingBone != null) {
        if(!isBoneSelectable(underlyingBone))return;
        print("Selected bone: ${underlyingBone.name}");
        control.attach(underlyingBone);
        control.showY = true;
        control.showX = true;
        control.showZ = true;
      }
      else if(hitHandle.userData['head_weight'] = true){
        control.attach(hitHandle);
        control.showY = true;
        control.showX = false;
        control.showZ = false;
      }
    } 
  }

  bool isBoneSelectable(three.Bone? bone) {
    if (bone == null || !_animating) {
      return false;
    }
    if (!mirror) {
      return true;
    }
    return !isRightSideBone(bone);
  }

  bool isRightSideBone(three.Bone bone) {
    final String normalizedBoneName = bone.name.toLowerCase();
    return RegExp(r'(^right_|^r_|_right$|_r$|\.right$|\.r$|-right$|-r$)').hasMatch(normalizedBoneName);
  }

  three.Bone? findMirrorBone(three.Bone bone) {
    final String baseName = Utility.calculateBoneBaseName(bone.name);
    
    // Explicit loop replacing JavaScript .find() for index and safety compliance
    for (int i = 0; i < (skeleton?.bones.length ?? 0); i++) {
      final candidate = skeleton!.bones[i];
      final String candidateBase = Utility.calculateBoneBaseName(candidate.name);
      
      if (candidateBase == baseName && candidate.name != bone.name) {
        return candidate;
      }
    }
    return null;
  }

  void applyMirrorMode(){
    final three.Bone? selectedBone = control.object is three.Bone?control.object as three.Bone:null;
    if(!mirror || selectedBone == null) return;
    
    final transformType = control.getMode();
    final mirrorBone = findMirrorBone(selectedBone);
    if (mirrorBone == null) {
      return;
    }

    if (transformType == GizmoType.translate) {
      mirrorBone.position.setFrom(three.Vector3(
        -selectedBone.position.x.toDouble(),
        selectedBone.position.y.toDouble(),
        selectedBone.position.z.toDouble(),
      ));
    }

    if (transformType == GizmoType.rotate) {
      final euler = three.Euler(
        selectedBone.rotation.x.toDouble(),
        -selectedBone.rotation.y.toDouble(),
        -selectedBone.rotation.z.toDouble(),
      );
      mirrorBone.quaternion.setFromEuler(euler);
    }

    mirrorBone.updateWorldMatrix(true, true);
  }

  void update(){
    ikSolver?.update();
  }

  List<Widget> hud(BuildContext context){
    return [
        Positioned(
          left: 10,
          top: 10,
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  control.setMode(GizmoType.translate);
                  setState((){});
                },
                child:Container(
                  width: 25,
                  height: 25,
                  color: control.mode == GizmoType.translate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.control_camera,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  control.setMode(GizmoType.rotate);
                  setState((){});
                },
                child:Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: control.mode == GizmoType.rotate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.cached,
                    size: 20,
                  ),
                ),
              ),
            ],
          )
        ),
        Row(
          children: [
            SizedBox(
              width: 80,
              height: 25, 
              child: Navigation(
                spacer: Text('|'),
                navData: [
                  NavItems(
                    name: LSIFunctions.capFirstLetter(control.space),
                    icon:  control.space == 'local'?Icons.view_in_ar_outlined:Icons.public,
                    subItems: [
                      NavItems(
                        name: 'Global',
                        icon: Icons.public,
                        onTap: (data){
                          control.space = 'global';
                          setState((){});
                        }
                      ),
                      NavItems(
                        name: 'Local',
                        icon: Icons.view_in_ar_outlined,
                        onTap: (data){
                          control.space = 'local';
                          setState((){});
                        }
                      ),
                    ]
                  ),
                ]
              ),
            ),
          ]
        ),
    ];
  }
}