import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/navigation/right_click.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer/terrain.dart';
import 'package:three_forge/src/thumbnail/thumbnail.dart';

import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';
import 'package:three_js_objects/three_js_objects.dart';

class IntersectsInfo{
  IntersectsInfo(this.intersects,this.oInt);
  List<three.Intersection> intersects = [];
  List<int> oInt = [];
}
enum ShadingType{wireframe,solid,material}
enum ControlSpaceType{global,local}
enum EditType{point,edge,face}
enum GridAxis{XZ,YZ,XY}

class GridInfo{
  int divisions = 10;
  double size = 10;
  int color = Colors.grey[900]!.value;
  double x = 0;
  double y = 0;
  GridAxis axis = GridAxis.XZ;

  three.LineSegments? axisX;
  three.LineSegments? axisY;
  three.LineSegments? axisZ;

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
}
class EditInfo{
  bool active = false;
  EditType type = EditType.point;
  three.Object3D? object;
}

class ThreeViewer {
  void Function(void Function()) setState;
  RightClick rightClick;

  ThreeViewer(this.setState,this.rightClick,this.dirPath){
    init();
  }

  String dirPath;
  late three.ThreeJS threeJs;

  Widget build() => threeJs.build();
  bool get mounted => threeJs.mounted;

  late final Thumbnail thumbnail;

  ControlSpaceType _controlSpace = ControlSpaceType.global;

  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 mousePosition = three.Vector2.zero();
  three.Object3D? intersected;
  three.AnimationMixer? mixer;
  three.AnimationClip? currentAnimation;

  late TransformControls control;
  late three.OrbitControls orbit;
  late three.PerspectiveCamera cameraPersp;

  three.Object3D? copy;
  ShadingType shading = ShadingType.solid;
  EditInfo editInfo = EditInfo();
  three.Group editObject = three.Group();
  ViewHelper? viewHelper;

  three.Group helper = three.Group();
  GridHelper grid = GridHelper( 500, 500, Colors.grey[900]!.value, Colors.grey[900]!.value);
  GridInfo gridInfo = GridInfo();
  final three.Vector3 sun = three.Vector3();

  bool didClick = false;
  bool holdingControl = false;
  bool usingMouse = false;
  bool sceneSelected = false;
  bool showCameraView = false;

  GlobalKey<three.PeripheralsState> get listenableKey => threeJs.globalKey;

  final three.Vector3 resetCamPos = three.Vector3(5, 2.5, 5);
  final three.Vector3 resetCamLookAt = three.Vector3();
  final three.Quaternion resetCamQuant = three.Quaternion();

  final three.Scene scene = three.Scene();
  late final three.Camera camera;
  final three.Scene thumbnailScene = three.Scene();
  late final three.Camera thumbnailCamera;
  late final Sky sky;
  final List<Terrain> terrains = [];

  void init(){
    threeJs = three.ThreeJS(
      onSetupComplete: (){
        setState(() {});
      },
      setup: setup,
    );
  }
  void dispose(){
    threeJs.dispose();
    control.dispose();
    orbit.dispose();
    thumbnail.dispose();
    editObject.dispose();
  }

  void _addCamera(){
    final CameraHelper cameraHelper = CameraHelper(camera);
    helper.add(cameraHelper);
    scene.add(camera..userData['helper'] = cameraHelper);
  }

  Future<void> setup() async{
    final aspect = threeJs.width / threeJs.height;
    cameraPersp = three.PerspectiveCamera( 50, aspect, 0.1, 100 );
    camera = three.PerspectiveCamera(40, aspect, 0.1, 10)..name = 'Main Camera';
    threeJs.camera = cameraPersp;
    threeJs.camera.position.setFrom(resetCamPos);
    threeJs.camera.getWorldDirection(resetCamLookAt);
    resetCamQuant.setFrom(threeJs.camera.quaternion);

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(theme.canvasColor.value);
    threeJs.scene.fog = three.Fog(theme.canvasColor.value, 10,500);
    threeJs.scene.add( grid );

    final ambientLight = three.AmbientLight( 0xffffff,0 );
    threeJs.scene.add( ambientLight );

    final light = three.DirectionalLight( 0xffffff, 0.5 );
    light.position = threeJs.camera.position;
    threeJs.scene.add( light );

    thumbnailCamera = three.PerspectiveCamera(45, 1, 0.1, 1000)
      ..position.setValues( - 0, 0, 2.7 )
      ..lookAt(thumbnailScene.position);
    thumbnailScene.add( three.AmbientLight( 0xffffff ) );
    final light2 = three.DirectionalLight( 0xffffff, 0.5 );
    light2.position = thumbnailCamera.position;
    thumbnailScene.add( light2 );
    thumbnail = Thumbnail(threeJs.renderer!, thumbnailScene, thumbnailCamera);

    orbit = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    control = TransformControls(threeJs.camera, threeJs.globalKey);

    control.addEventListener( 'dragging-changed', (event) {
      orbit.enabled = ! event.value;
    });
    creteHelpers();
    threeJs.scene.add( control );
    threeJs.scene.add(helper);
    threeJs.scene.add(editObject);
    generateSky();
    _addCamera();
    scene.userData['animationClips'] = <String,dynamic>{};
    scene.background = threeJs.scene.background;
    threeJs.scene.add(scene);

    threeJs.domElement.addEventListener(three.PeripheralType.keydown,(event) {
      event as LogicalKeyboardKey;
      switch (event.keyLabel.toLowerCase()) {
        case 'meta left':
          holdingControl = true;
        case 'q':
          control.setSpace( control.space == 'local' ? 'world' : 'local' );
          break;
        case 'shift right':
        case 'shift left':
          control.setTranslationSnap( 1 );
          control.setRotationSnap( three.MathUtils.degToRad( 15 ) );
          control.setScaleSnap( 0.25 );
          break;
        case 'w':
          control.setMode(GizmoType.translate);
          break;
        case 'e':
          control.setMode(GizmoType.rotate);
          break;
        case 'r':
          control.setMode(GizmoType.scale);
          break;
        case 'c':
          if(holdingControl){
            copy = intersected;
          }
          break;
        case 'v':
          if(holdingControl){
            if(copy != null){
              scene.add(copy?.clone());
            }
          }
          break;
        case '+':
        case '=':
          control.setSize( control.size + 0.1 );
          break;
        case '-':
        case '_':
          control.setSize( math.max( control.size - 0.1, 0.1 ) );
          break;
        case 'delete':
        case 'x':
          if(intersected != null){
            rightClick.openMenu('',Offset(mousePosition.x,mousePosition.y),[RightClickOptions.delete]);
          }
          break;
        case 'tab':
          if(intersected != null){
            editModes([intersected!]);
            editInfo.active = true;
          }
          else if(editInfo.active){
            for(int i = 0; i < editObject.children.length; i++){
              editObject.children[i].dispose();
            }
            editInfo.active = false;
          }
          break;
        case 'y':
          break;
        case 'z':
          break;
        case ' ':
          break;
        case 'escape':
          break;
      }
    });
    threeJs.domElement.addEventListener(three.PeripheralType.keyup, (event) {
      event as LogicalKeyboardKey;
      switch ( event.keyLabel.toLowerCase() ) {
        case 'meta left':
          holdingControl = false;
        case 'shift right':
        case 'shift left':
          control.setTranslationSnap( null );
          control.setRotationSnap( null );
          control.setScaleSnap( null );
          break;
      }
    });
    threeJs.domElement.addEventListener(three.PeripheralType.pointerdown, (details){
      mousePosition = three.Vector2(details.clientX, details.clientY);
      if(!control.dragging){
        checkIntersection(scene.children);
        mixer = null;
        currentAnimation = null;
      }
    });
    threeJs.domElement.addEventListener(three.PeripheralType.pointermove, (details){
      mousePosition = three.Vector2(details.clientX, details.clientY);
      if(control.dragging){}
    });

    threeJs.addAnimationEvent((dt){
      mixer?.update(dt);
      orbit.update();
      if (viewHelper != null && viewHelper!.animating ) {
        viewHelper!.update( dt );
      }
    });
    threeJs.renderer?.autoClear = false;
    
    threeJs.postProcessor = ([double? dt]){
      //threeJs.renderer!.clear();
      threeJs.renderer!.setViewport(0,0,threeJs.width,threeJs.height);
      threeJs.renderer!.render(threeJs.scene,threeJs.camera );
      viewHelper?.render(threeJs.renderer!);

      if(showCameraView){
        threeJs.renderer?.setScissorTest( true );
        threeJs.renderer?.setScissor( 20, 20, threeJs.width/4, threeJs.height/4 );
        threeJs.renderer?.setViewport( 20, 20, threeJs.width/4, threeJs.height/4 );

        threeJs.renderer?.render(scene, camera );

        threeJs.renderer?.setScissorTest( false );
      }
    };
  }

  void generateSky(){
    threeJs.scene.add(threeJs.camera);
    threeJs.camera.lookAt(threeJs.scene.position);

    sky = Sky.create();
    sky.scale.setScalar( 10000 );
    threeJs.scene.add( sky );

    final skyUniforms = sky.material!.uniforms;

    skyUniforms[ 'turbidity' ]['value'] = 20.0;
    skyUniforms[ 'rayleigh' ]['value'] = 0.08;
    skyUniforms[ 'mieCoefficient' ]['value'] = 0.0;
    skyUniforms[ 'mieDirectionalG' ]['value'] = 0.0;

    final parameters = {
      'elevation': 90.0,
      'azimuth': 180.0
    };

    sky.visible = false;

    threeJs.scene.add( sky );

    void updateSun(r) {
      final phi = three.MathUtils.degToRad( 90 - parameters['elevation']!);
      final theta = three.MathUtils.degToRad( parameters['azimuth']!);

      sun.setFromSphericalCoords( 1, phi, theta );
      sky.material!.uniforms[ 'sunPosition' ]['value'].setFrom( sun );
    }

    updateSun('');
  }
  void createLine(int rgb){
    List<double> vertices = rgb == 0?[500,0,0,-500,0,0]:rgb == 1?[0,500,0,0,-500,0]:[0,0,500,0,0,-500];
    List<double> colors = rgb == 0?[1,0,0,1,0,0]:rgb == 1?[0,1,0,0,1,0]:[0,0,1,0,0,1];
    final geometry = three.BufferGeometry();
    geometry.setAttributeFromString('position',three.Float32BufferAttribute.fromList(vertices, 3, false));
    geometry.setAttributeFromString('color',three.Float32BufferAttribute.fromList(colors, 3, false));

    final material = three.LineBasicMaterial.fromMap({
      "vertexColors": true, 
      "toneMapped": true,
    })
      ..depthTest = false
      ..linewidth = 5.0
      ..depthWrite = true;

    final ls = three.LineSegments(geometry,material);

    helper.add(
      ls
      ..computeLineDistances()
      ..scale.setValues(1,1,1)
    );

    rgb == 0?gridInfo.axisX = ls:rgb==1?gridInfo.axisY = ls:gridInfo.axisZ = ls;
  }
  void creteHelpers(){
    createLine(0);
    createLine(1);
    createLine(2);

    gridInfo.showAxis(GridAxis.XZ);
    
    viewHelper = ViewHelper(
      //size: 1.8,
      offsetType: OffsetType.topRight,
      //offset: three.Vector2(-250, -200),
      screenSize: const Size(120, 120), 
      listenableKey: threeJs.globalKey,
      camera: threeJs.camera,
    );
  }

  final targetBoundingBox = three.BoundingBox(
    three.Vector3(-1,-1,-1),
    three.Vector3(1, 1, 1)
  );

  void add(three.Object3D? object){
    if(object != null){
      scene.add(object);

      // final three.BoundingBox modelBoundingBox = three.BoundingBox();
      // modelBoundingBox.setFromObject(object);

      // print(
      //   {
      //     'min': modelBoundingBox.min.toJson(),
      //     'max': modelBoundingBox.max.toJson()
      //   }
      // );

      // final modelSize = three.Vector3();
      // modelBoundingBox.getSize(modelSize);

      // print(modelSize.toJson());

      // final targetSize = three.Vector3();
      // targetBoundingBox.getSize(targetSize);

      // print(targetSize.toJson());

      // final scaleX = targetSize.x / modelSize.x;
      // final scaleY = targetSize.y / modelSize.y;
      // final scaleZ = targetSize.z / modelSize.z;

      // final scaleFactor = math.max(scaleX, math.max(scaleY, scaleZ));
      // print(scaleFactor);
      // object.scale.scale(scaleFactor);
      
      object.position.setFrom(orbit.target);
    
      if(shading == ShadingType.wireframe){
        materialWireframe(ShadingType.material,object,true);
      }
      else if(shading == ShadingType.solid){
        materialSolid(ShadingType.material,object,true);
      }
    }
  }

  void remove(three.Object3D object){
    scene.remove(object);
    if(object.name.contains('terrain_')){
      terrains.remove(object);
    }
  }

  void _changeToVertex(three.Object3D o){
    if(o is! BoundingBoxHelper && o is! SkeletonHelper){
      final m = o.userData['mainMaterial'];
      o.material = m;
      o.material?.needsUpdate = true; // Inform Three.js that the material has changed
      o.material?.name = 'main';
      //o.userData['mainMaterial'] = null;
    }
  }
  void materialVertexMode(ShadingType type, three.Object3D object,[bool start = true]){
    if(start)_changeToVertex(object);
    for(final o in object.children){
      _changeToVertex(o);
      materialVertexMode(type, o);
    }
  }
  void materialVertexModeAll(ShadingType type){
    for(final o in scene.children){
      _changeToVertex(o);
      materialVertexMode(type, o);
    }
  }

  void _changeToSolid(ShadingType type, three.Object3D o){
    if(o is! BoundingBoxHelper && o is! SkeletonHelper){
     if (o is three.Mesh && o.material != null) {
        int side = _changeShared(type, o);
        o.material = three.MeshStandardMaterial.fromMap({'side': side, 'flatShading': true}); // Example: set to red
        o.material?.name = 'solid';
        o.material?.needsUpdate = true; // Inform Three.js that the material has changed
      }
    }
  }
  void materialSolid(ShadingType type, three.Object3D object,[bool start = false]){
    if(start)_changeToSolid(type,object);
    for(final o in object.children){
      if(o is! BoundingBoxHelper && o is! SkeletonHelper){
        _changeToSolid(type,o);
        materialSolid(type,o);
      }
    }
  }
  void materialSolidAll(ShadingType type){
    for(final o in scene.children){
      if(o is! BoundingBoxHelper && o is! SkeletonHelper){
        _changeToSolid(type,o);
        materialSolid(type,o);
      }
    }
  }

  int _changeShared(ShadingType type, three.Object3D o){
    int side = three.FrontSide;
    if(o.material?.side == three.DoubleSide){
      side = three.DoubleSide;
    }

    if(type == ShadingType.material){
      o.userData['mainMaterial'] = o.material;
      // if(o.userData['mainMaterial'] == null){
      //   o.userData['mainMaterial'] = three.MeshPhongMaterial.fromMap({'side': side, 'flatShading': true});
      // }
    }

    return side;
  }
  void _changeToWireframe(ShadingType type, three.Object3D o){
    if(o is! BoundingBoxHelper && o is! SkeletonHelper){
      _changeShared(type, o);
      o.material = three.MeshStandardMaterial.fromMap({'wireframe': true}); // Example: set to red
      o.material?.name = 'wireframe';
      o.material?.needsUpdate = true; // Inform Three.js that the material has changed
    }
  }
  void materialWireframe(ShadingType type, three.Object3D object,[bool start = false]){
    if(start)_changeToWireframe(type,object);
    for(final o in object.children){
      _changeToWireframe(type,o);
      materialWireframe(type,o);
    }
  }
  void materialWireframeAll(ShadingType type){
    for(final o in scene.children){
      _changeToWireframe(type,o);
      materialWireframe(type,o);
    }
  }

  void editModes(List<three.Object3D> obj){
    for(final o in obj){
      if(o is! BoundingBoxHelper && o is! SkeletonHelper){
        o.material?.wireframe = true;
        o.material?.colorWrite = true;
        editModes(o.children);
        if(editInfo.type == EditType.point){
          three.Points particles = three.Points(o.geometry!.clone(), three.PointsMaterial.fromMap({"color": 0xffff00, "size": 4,'sizeAttenuation': false}));
          editObject.add(particles);
        }
      }
    }
  }
  
  String controlSpace(){
    return _controlSpace.name;
  }
  void setControlSpace(ControlSpaceType space){
    _controlSpace = space;
    control.space = space == ControlSpaceType.global?'world':'local';
  }
  void resetCamera(){
    threeJs.camera.position.setFrom( resetCamPos );
    threeJs.camera.quaternion.setFrom( resetCamQuant );
    orbit.target.setFrom(resetCamLookAt);
  }
  void setToMainCamera(){
    threeJs.camera.position.setFrom( camera.position );
    threeJs.camera.quaternion.setFrom( camera.quaternion );

    final direction = three.Vector3(); // Create once and reuse
    camera.getWorldDirection(direction); 
    orbit.target.setFrom(orbit.target);
  }
  IntersectsInfo getIntersections(List<three.Object3D> objects){
    IntersectsInfo ii = IntersectsInfo([], []);
    int i = 0;
    for(final o in objects){
      if(o is three.Group || o is three.AnimationObject || o.runtimeType == three.Object3D){
        final inter = getIntersections(o.children);
        ii.intersects.addAll(inter.intersects);
        ii.oInt.addAll(List.filled(inter.intersects.length, i));
      }
      else if((o is three.Light && o is! three.AmbientLight) || o is three.Camera){
        final inter = raycaster.intersectObjects([o,o.userData['helper']], true);
        ii.intersects.addAll(inter);
        ii.oInt.addAll(List.filled(inter.length, i));
      }
      else if(o is! three.Bone && o is! BoundingBoxHelper){
        final inter = raycaster.intersectObject(o, false);
        ii.intersects.addAll(inter);
        ii.oInt.addAll(List.filled(inter.length, i));
      }
      i++;
    }
    return ii;
  }
  void boxSelect(bool select){
    if(intersected == null) return;
    if(!select){
      sceneSelected = false;
      control.detach();
      for(final o in intersected!.children){
        if(o is BoundingBoxHelper || o is SkeletonHelper){
          o.visible = false;
        }
      }
    }
    else{
      for(final o in intersected!.children){
        if(o is BoundingBoxHelper || o is SkeletonHelper){
          o.visible = true;
        }
      }
      control.attach( intersected );
    }
  }

  void setGridRotation(GridAxis axis){
    gridInfo.axis = axis;
    gridInfo.showAxis(axis);
    if(axis == GridAxis.XY){
      grid.rotation.set(math.pi / 2,0,0);
    }
    else if(axis == GridAxis.XZ){
      grid.rotation.set(0,0,0);
    }
    if(axis == GridAxis.YZ){
      grid.rotation.set(0,0,math.pi / 2);
    }
  }

  three.Vector2 convertPosition(three.Vector2 location){
    final RenderBox renderBox = listenableKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    double x = (location.x / (threeJs.width-size.width/6)) * 2 - 1;
    double y = -(location.y / (threeJs.height-20-285)) * 2 + 1;
    return three.Vector2(x,y);
  }

  void checkIntersection(List<three.Object3D> objects) {
    IntersectsInfo ii = getIntersections(objects);
    raycaster.setFromCamera(convertPosition(mousePosition), threeJs.camera);
    if (ii.intersects.isNotEmpty ) {
      if(intersected != objects[ii.oInt[0]]) {
        if(intersected != null){
          boxSelect(false);
        }
        intersected = objects[ii.oInt[0]];
        boxSelect(true);
      }
    }
    else if(intersected != null){
      boxSelect(false);
      intersected = null;
    }

    if(didClick && intersected != null){

    }
    else if(didClick && ii.intersects.isEmpty){
      boxSelect(false);
      intersected = null;
    }

    didClick = false;
    setState(() {});
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    await for (FileSystemEntity entity in source.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        File newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
        await entity.copy(newFile.path);
      } else if (entity is Directory) {
        Directory newDirectory = Directory('${destination.path}/${entity.uri.pathSegments.last}');
        await _copyDirectory(entity, newDirectory); // Recursive call for subdirectories
      }
    }
  }

  Future<void> moveFolder(PlatformFile file) async{
    String path ='$dirPath/assets/models/${file.name.split('.').first}/' ;
    Directory sourceDir = Directory(file.path!.replaceAll(file.path!.split('/').last, ''));
    Directory destinationDir = Directory(path);

    if (sourceDir.existsSync()) {
      await _copyDirectory(sourceDir, destinationDir);
      print('Folder copied successfully!');
    } else {
      print('Source folder does not exist.');
    }
  }
  Future<void> moveObjects(List<PlatformFile> files) async{
    String path ='$dirPath/assets/models/' ;
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);

    for(final file in files){
      if(file.bytes != null){
        final last = file.name;
        await File('$path$last').writeAsBytes(file.bytes!);
      }
    }
  }
  Future<void> moveObject(PlatformFile file) async{
    String path ='$dirPath/assets/models/' ;
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);

    if(file.bytes != null){
      final last = file.name;
      await File('$path$last').writeAsBytes(file.bytes!);
    }
  }
  Future<void> crerateThumbnial(three.Object3D model) async{
    thumbnail.captureThumbnail('$dirPath/assets/thumbnails/', model: model);
  }

  void viewSky(){
    sky.visible = !sky.visible;
  }

  void createTerrain(){
    print('terrain');
    terrains.add(Terrain(this,setState,terrains.length));
    terrains.last.setup();
  }
}