import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/three_viewer/src/grid_info.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

class VoxelPainter extends Object3D{
  final GlobalKey<PeripheralsState> listenableKey;
  PeripheralsState get _domElement => listenableKey.currentState!;
  Object3D? helper;
  Object3D? object;
  final GridInfo gridInfo;
  final Camera camera;
  bool _holdingShift = false;
  bool _holdingCRTL = false;
  bool allowPaint = false;
  Size screenSize = Size(0,0);
  final mouse = Vector2();
  final raycaster = Raycaster();
  List<Object3D> objects = [];
  SelectorType selectorType = SelectorType.paint;

  VoxelPainter({
    required this.listenableKey, 
    required this.camera,
    required this.gridInfo,
  }):super(){
    _activate();
    screenSize = _getSize();
  }

  void setObject(Object3D object, [Object3D? helper]){
    this.object = object;
    this.helper = helper ?? object.clone();

    if(helper == null){
      this.helper?.traverse((callback){
        callback.material?.transparent = true;
        callback.material?.opacity = 0.5;
      });
    }

    add(this.helper!..visible = false);
  }
  void setHelper(Object3D helper){
    this.helper = helper;
  }

  Size _getSize(){
    final RenderBox renderBox = listenableKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return size;
  }

  void onKeyDown(LogicalKeyboardKey event){
    if(!allowPaint)return;
    switch (event.keyLabel.toLowerCase()) {
      case 'control right':
      case 'control left':
        _holdingCRTL = true;
        break;
      case 'shift right':
      case 'shift left':
        _holdingShift = true;
        break;
    }
  }
  void onKeyUp(LogicalKeyboardKey event){
    if(!allowPaint)return;
    switch (event.keyLabel.toLowerCase()) {
      case 'control right':
      case 'control left':
        _holdingCRTL = false;
        break;
      case 'shift right':
      case 'shift left':
        _holdingShift = false;
        break;
    }
  }
  void onPointerDown(WebPointerEvent event){
    if(!allowPaint)return;
    raycaster.setFromCamera( mouse, camera );
    final intersects = raycaster.intersectObjects(<Object3D>[gridInfo.intersectPlane]+objects, false );
    if ( intersects.isNotEmpty ) {
      Intersection intersect = intersects[ 0 ];
      if (_holdingShift) {
        if(intersect.object == gridInfo.intersectPlane) intersect = intersects.length > 1 ? intersects[1] : intersect;
        if ( intersect.object != gridInfo.intersectPlane ) {
          remove(intersect.object!);
          objects.remove(intersect.object!);
        }
      } 
      else if(_holdingCRTL){
        final voxel = object?.clone();
        voxel?.position.setFrom( intersect.point! ).add( intersect.face!.normal );
        voxel?.position.divideScalar(gridInfo.snapDistance).floor().scale(gridInfo.snapDistance).addScalar(gridInfo.snapDistance/2);
        if(voxel != null){
          add(voxel);
          objects.add(voxel);
        }
      }
    }
  }
  void onPointerMove(WebPointerEvent event){
    if(!allowPaint)return;
    mouse.x = (event.clientX / screenSize.width) * 2 - 1;
    mouse.y = -(event.clientY / screenSize.height) * 2 + 1;
    raycaster.setFromCamera( mouse, camera );
    final intersects = raycaster.intersectObjects(<Object3D>[gridInfo.intersectPlane]+objects, false );

    if ( intersects.isNotEmpty ) {
      final intersect = intersects[ 0 ];
      if(selectorType == SelectorType.paint){
        helper?.position.setFrom( intersect.point! ).add( intersect.face!.normal );
        helper?.position.divideScalar(gridInfo.snapDistance).floor().scale(gridInfo.snapDistance).addScalar(gridInfo.snapDistance/2);
      }
      else if(selectorType == SelectorType.erase){
        if ( intersect.object != gridInfo.intersectPlane ) {
          remove(intersect.object!);
          objects.remove(intersect.object!);
        }
      }
    }
  }

  void activate(){
    allowPaint = true;
    helper?.visible = true;
  }

  void deactivate(){
    allowPaint = false;
    helper?.visible = false;
  }

  @override
  void dispose() {
    if(disposed) return;
    super.dispose();
    _deactivate();
    helper?.dispose();
    object?.dispose();
    raycaster.dispose();
  }

  /// Adds the event listeners of the controls.
  void _activate() {
    if(disposed) return;
    _domElement.addEventListener(PeripheralType.pointerdown, onPointerDown);
    _domElement.addEventListener(PeripheralType.pointerHover, onPointerMove);
    _domElement.addEventListener(PeripheralType.keydown, onKeyDown);
    _domElement.addEventListener(PeripheralType.keyup, onKeyUp);
  }

  /// Removes the event listeners of the controls.
  void _deactivate() {
    if(disposed) return;
    _domElement.removeEventListener(PeripheralType.pointerdown, onPointerDown);
    _domElement.removeEventListener(PeripheralType.pointerHover, onPointerMove);
    _domElement.removeEventListener(PeripheralType.keydown, onKeyDown);
    _domElement.removeEventListener(PeripheralType.keyup, onKeyUp);
  }
}