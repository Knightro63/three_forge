import 'package:three_js/three_js.dart' as three;
import 'package:three_js_transform_controls/three_js_transform_controls.dart';
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:flutter/material.dart';
import 'package:css/css.dart';
import 'dart:math' as math;
import 'package:three_forge/src/styles/globals.dart';

enum GridAxis{XZ,YZ,XY}

class GridInfo{
  GridInfo();
  
  final three.Mesh intersectPlane = three.Mesh(three.PlaneGeometry( 1000, 1000 )..rotateX( - math.pi / 2 ),three.MeshBasicMaterial.fromMap( { 'visible': false } ));//three.Mesh( three.BoxGeometry( 50, 50, 50 ), three.MeshBasicMaterial.fromMap( { 'color': 0xff0000, 'opacity': 0.5, 'transparent': true } ) );
  late TransformControls control;
  int divisions = 500;
  double size = 500;
  int color = Colors.grey[900]!.value;
  double x = 0;
  double y = 0;
  GridAxis axis = GridAxis.XZ;
  bool get isSnapOn => control.translationSnap == null?false:true;

  three.LineSegments? axisX;
  three.LineSegments? axisY;
  three.LineSegments? axisZ;

  double get snapDistance => size/divisions;

  final GridHelper grid1 = GridHelper( 500, 500)..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[900]!.value:Colors.grey[700]!.value)..material?.vertexColors = false;
  final GridHelper grid2 = GridHelper( 500, 100)..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[500]!.value:Colors.grey[900]!.value)..material?.vertexColors = false;
  late final three.Group grid = three.Group()..add(grid1)..add(grid2)..add(intersectPlane);
  void addControl(TransformControls control){
    this.control = control;
  }
  void showAxis(GridAxis axis){
    axisX?.visible = true;
    axisY?.visible = true;
    axisZ?.visible = true;
    if(axis == GridAxis.XY){
      axisZ?.visible = false;
    }
    else if(axis == GridAxis.XZ){
      axisY?.visible = false;
    }
    else{
      axisX?.visible = false;
    }
  }
  void setSnap(bool snap){
    if(snap){
      control.setTranslationSnap(snapDistance);
    }
    else{
      control.setTranslationSnap(null);
    }
  }
  void updateGrid(double size, int divisions){
    this.size = size;
    this.divisions = divisions;
    grid1.copy(GridHelper(size, divisions)..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[900]!.value:Colors.grey[700]!.value)..material?.vertexColors = false);
    grid2.copy(GridHelper(size, divisions~/5)..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[500]!.value:Colors.grey[900]!.value)..material?.vertexColors = false);
  
    if(control.translationSnap != null){
      final double snap = size/divisions;
      control.setTranslationSnap(snap);
    }
  }
  void setGridRotation(GridAxis axis){
    axis = axis;
    showAxis(axis);
    if(axis == GridAxis.XY){
      rotation.set(math.pi / 2,0,0);
      intersectPlane.rotation.set(-math.pi / 2,0,0);
    }
    else if(axis == GridAxis.XZ){
      rotation.set(0,0,0);
      intersectPlane.rotation.set(- math.pi / 2,0,0);
    }
    if(axis == GridAxis.YZ){
      rotation.set(0,0,math.pi / 2);
      intersectPlane.rotation.set(math.pi / 2,0,0);
    }
  }
  three.Euler get rotation => grid.rotation;

  Map<String,dynamic> toJson(){
    return {
      'divisions': divisions,
      'size': size,
      'color': color,
      'x': x,
      'y': y,
      'snap': isSnapOn,
      'axis': axis.index,
    };
  }
}