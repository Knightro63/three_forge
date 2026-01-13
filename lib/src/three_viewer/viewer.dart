import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/navigation/right_click.dart';
import 'package:three_forge/src/modifers/create_camera.dart';
import 'package:three_forge/src/modifers/insert_camera.dart';
import 'package:three_forge/src/modifers/insert_models.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer/src/file_sort.dart';
import 'package:three_forge/src/three_viewer/src/grid_info.dart';
import 'package:three_forge/src/three_viewer/src/terrain.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';
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
enum SelectorType{
  translate,rotate,scale,select,paint,erase;

  bool get isGimble => index < 3;
}

class EditInfo{
  bool active = false;
  EditType type = EditType.point;
  three.Object3D? object;
}

class ThreeViewer {
  late final FileSort fileSort = FileSort(dirPath);
  void Function(void Function()) setState;
  RightClick rightClick;

  ThreeViewer(this.setState,this.rightClick,this.dirPath){
    init();
  }

  late final History history = History(this);
  String dirPath;
  late three.ThreeJS threeJs;

  Widget build() => threeJs.build();
  bool get mounted => threeJs.mounted;

  late final Thumbnail thumbnail;

  ControlSpaceType _controlSpace = ControlSpaceType.global;
  ControlSpaceType get controlSpace => _controlSpace;
  late final InsertModels modelInsert;
  late final InsertCamera insertCamera = InsertCamera(this);

  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 mousePosition = three.Vector2.zero();
  List<three.Object3D> intersected = [];

  late TransformControls control;
  late three.OrbitControls orbit;

  List<three.Object3D>? copy;
  ShadingType shading = ShadingType.solid;
  EditInfo editInfo = EditInfo();
  three.Group editObject = three.Group();
  ViewHelper? viewHelper;

  final three.Group helper = three.Group();
  final three.Group skeleton = three.Group();
  final GridInfo gridInfo = GridInfo();
  final three.Fog fog = three.Fog(theme.canvasColor.toARGB32(), 2,10);
  final three.Vector3 sun = three.Vector3();

  bool didClick = false;
  String? holdingKey;
  bool sceneSelected = false;
  bool showCameraView = false;
  bool tempSnap = false;
  
  SelectorType _selectorType = SelectorType.translate;
  SelectorType get selectorType => _selectorType;
  bool get isVoxelPainter => intersected.isNotEmpty && intersected[0] is VoxelPainter;

  GlobalKey<three.PeripheralsState> get listenableKey => threeJs.globalKey;

  final three.Vector3 resetCamPos = three.Vector3(20, 20, 20);
  final three.Vector3 resetCamLookAt = three.Vector3();
  final three.Quaternion resetCamQuant = three.Quaternion();

  final three.Scene scene = three.Scene();
  //late three.Camera camera;
  three.Camera? mainCamera;

  final three.Scene thumbnailScene = three.Scene();
  late final three.Camera thumbnailCamera;
  late final Sky sky;
  final List<Terrain> terrains = [];

  late final selectionBox = SelectionBox(threeJs.camera, threeJs.scene);
  final List<RightClickOptions> rcOptions = [RightClickOptions.reset_camera,RightClickOptions.game_view];

  //SelectionHelper
  bool selectionHelperEnabled = false;
  final three.Vector2 startPoint = three.Vector2();
  
  void init(){
    threeJs = three.ThreeJS(
      onSetupComplete: (){
        setState(() {});
      },
      setup: setup,
    );
    modelInsert = InsertModels(this);
  }
  void dispose(){
    threeJs.dispose();
    control.dispose();
    orbit.dispose();
    thumbnail.dispose();
    viewHelper?.dispose();
    editObject.dispose();
  }

  void dispatch() => setState((){});
	void execute( cmd ) => this.history.execute( cmd );
	void undo() => this.history.undo();
	void redo() => this.history.redo();

  void _addCamera(){
    final aspect = aspectRatio();
    if(mainCamera != null) scene.remove(mainCamera!);
    mainCamera?.dispose();

    mainCamera = CreateCamera.perspective(aspect);

    add(mainCamera);
    mainCamera?.position.setValues(5,5,-5);
    mainCamera?.lookAt(three.Vector3());
    mainCamera?..name = 'Main Camera'..userData['mainCamera'] = true;
  }

  void changeCamera(three.Camera? newCamera){
    mainCamera?..name = mainCamera.runtimeType.toString()..userData['mainCamera'] = false;
    mainCamera = newCamera?..name = 'Main Camera'..userData['mainCamera'] = true;
  }
  void updateCameraHelper(three.Camera camera){
    (camera.userData['skeleton'] as CameraHelper?)?.copy(CameraHelper(camera));
  }
  
  double aspectRatio(){
    final RenderBox renderBox = listenableKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return size.width/size.height;
  }

  Future<void> setup() async{
    final aspect = aspectRatio();

    threeJs.camera = three.PerspectiveCamera( 50, aspect, 0.1, 500 );
    threeJs.camera.position.setFrom(resetCamPos);
    threeJs.camera.getWorldDirection(resetCamLookAt);
    resetCamQuant.setFrom(threeJs.camera.quaternion);

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(theme.canvasColor.toARGB32());
    threeJs.scene.fog = three.Fog(theme.canvasColor.toARGB32(), 10,500);
    threeJs.scene.add( gridInfo.grid );

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
    orbit.mouseButtons = {
      'left': three.Mouse.rotate,
      'MIDDLE': three.Mouse.pan,
      //'right': three.Mouse.pan
    };
    control = TransformControls(threeJs.camera, threeJs.globalKey);
    gridInfo.addControl(control);

    changeListener();
    creteHelpers();
    
    threeJs.scene.add( control );
    threeJs.scene.add(helper);
    threeJs.scene.add(editObject);
    threeJs.scene.add(skeleton);

    generateSky();
    _addCamera();
    
    scene.background = threeJs.scene.background;
    threeJs.scene.add(scene);

    threeJs.domElement.addEventListener(three.PeripheralType.keydown,onKeyDown);
    threeJs.domElement.addEventListener(three.PeripheralType.keyup, onKeyUp);
    threeJs.domElement.addEventListener(three.PeripheralType.pointerdown, onPointerDown);
    threeJs.domElement.addEventListener(three.PeripheralType.pointermove, onPointerMove);
    threeJs.domElement.addEventListener(three.PeripheralType.pointerup, onPointerUp);

    threeJs.addAnimationEvent((dt){
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

        if(mainCamera != null){
          threeJs.renderer?.render(scene, mainCamera! );
        }

        threeJs.renderer?.setScissorTest( false );
      }
    };
  }

  void changeListener(){
    final oldScale = three.Vector3();
    final oldPosition = three.Vector3();
    final oldRotation = three.Euler();
    control.addEventListener('dragging-changed', (event){
      orbit.enabled = ! event.value;
      if (control.object != null) {
        oldScale.setFrom(control.object!.scale);
        oldPosition.setFrom(control.object!.position);
        oldRotation.copy(control.object!.rotation);
      }
    });
    control.addEventListener('mouseDown', (event){
      if (control.object != null) {
        oldScale.setFrom(control.object!.scale);
        oldPosition.setFrom(control.object!.position);
        oldRotation.copy(control.object!.rotation);
      }
    });
    control.addEventListener('mouseUp', (event){
      final object = control.object;
      if (control.getMode() == GizmoType.scale) {
        execute(SetScaleCommand(this,object,object?.scale,oldScale));
      }
      else if (control.getMode() == GizmoType.translate) {
        execute(SetPositionCommand(this,object,object?.position,oldPosition));
      }
      else if (control.getMode() == GizmoType.rotate) {
        execute(SetRotationCommand(this,object,object?.rotation,oldRotation));
      }
    });
  }

  void onKeyDown(LogicalKeyboardKey event){
    switch (event.keyLabel.toLowerCase()) {
      case 'meta left':
        holdingKey = 'ctrl';
      case 'q':
        control.setSpace( control.space == 'local' ? 'world' : 'local' );
        break;
      case 'shift right':
      case 'shift left':
        if(SelectorType.paint == _selectorType || SelectorType.erase == _selectorType) return;
        holdingKey = 'shift';
        tempSnap = gridInfo.isSnapOn;
        gridInfo.setSnap(true);
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
        if(holdingKey == 'ctrl'){
          copy = intersected;
        }
        break;
      case 'v':
        if(holdingKey == 'ctrl'){
          if(copy != null){
            copyAll(copy);
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
        if(intersected.isNotEmpty){
          rightClick.openMenu('',Offset(mousePosition.x,mousePosition.y),[RightClickOptions.delete]);
        }
        break;
      case 'tab':
        if(intersected.isNotEmpty){
          editModes(intersected);
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
  }
  void onKeyUp(LogicalKeyboardKey event){
    holdingKey = null;
    switch ( event.keyLabel.toLowerCase() ) {
      case 'y':
        redo();
        setState((){});
        break;
      case 'z':
        undo();
        setState((){});
        break;
      case 'shift right':
      case 'shift left':
        if(SelectorType.paint == _selectorType || SelectorType.erase == _selectorType) return;
        gridInfo.setSnap(tempSnap);
        break;
    }
  }
  void onPointerDown(details){
    if(SelectorType.paint == _selectorType || SelectorType.erase == _selectorType) return;
    if(details.button == 2){
      if(rightClick.isMenuOpen){
        final showOptions = rcOptions+
        (copy != null && copy!.isNotEmpty?[RightClickOptions.paste]:[])+
        (intersected.isNotEmpty?[RightClickOptions.copy,RightClickOptions.delete]:[])
        ;
        rightClick.closeMenu();
        rightClick.openMenu(
          'Test', 
          Offset(details.clientX,details.clientY), 
          showOptions
        );
      }
      else{
        final showOptions = rcOptions+
        (copy != null && copy!.isNotEmpty?[RightClickOptions.paste]:[])+
        (intersected.isNotEmpty?[RightClickOptions.copy,RightClickOptions.delete]:[])
        ;
        rightClick.openMenu(            
          'Test', 
          Offset(details.clientX,details.clientY), 
          showOptions
        );
      }
    }
    else{
      if(rightClick.isMenuOpen){
        rightClick.closeMenu();
      }
      if(SelectorType.select == _selectorType){
        orbit.enableRotate = false;
        selectionHelperEnabled = true;
        
        startPoint.setValues(details.clientX,details.clientY);
        selectionBox.startPoint.setFrom(convertPosition(startPoint));
      }
      else{
        mousePosition = three.Vector2(details.clientX, details.clientY);
        if(!control.dragging){
          checkIntersection(scene.children);
        }
      }
    }
  }
  void onPointerMove(details){
    if(SelectorType.paint == _selectorType || SelectorType.erase == _selectorType) return;
    mousePosition = three.Vector2(details.clientX, details.clientY);
    if (SelectorType.select == _selectorType) {
      if(intersected.isNotEmpty){
        boxSelect(false);
        intersected.clear();
      }

      final temp = selectionBox.select();

      for(final s in temp){
        if(contains(s) && s.visible){
          intersected.add(s);
          boxSelect(true);
        }
      }

      selectionBox.endPoint.setFrom(convertPosition(mousePosition));
      setState((){});
    }
    else{
      selectionHelperEnabled = false;
    }
    
    if(control.dragging){}
  }
  void onPointerUp(event){
    if(event.pointerType == 'mouse'){
      orbit.enableRotate = true;
    }
    if(selectionHelperEnabled){
      selectionHelperEnabled = false;
      setState((){});
    }
  }
  
  void generateSky(){
    threeJs.scene.add(threeJs.camera);
    sky = Sky.create();
    threeJs.scene.add( sky );
    _setSky();
  }
  void _setSky(){
    
    threeJs.camera.lookAt(threeJs.scene.position);

    sky.scale.setScalar( 10000 );

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

    void updateSun(r) {
      final phi = three.MathUtils.degToRad( 90 - parameters['elevation']!);
      final theta = three.MathUtils.degToRad( parameters['azimuth']!);

      sun.setFromSphericalCoords( 1, phi, theta );
      sky.material!.uniforms[ 'sunPosition' ]['value'].setFrom( sun );
    }

    updateSun('');
  }

  void creteHelpers(){
    gridInfo.showAxis(GridAxis.XZ);
    
    viewHelper = ViewHelper(
      //size: 1.8,
      offsetType: OffsetType.topRight,
      offset: three.Vector2(0, -35),
      screenSize: const Size(80, 80), 
      listenableKey: threeJs.globalKey,
      camera: threeJs.camera,
    );
  }

  final targetBoundingBox = three.BoundingBox(
    three.Vector3(-1,-1,-1),
    three.Vector3(1, 1, 1)
  );

	three.Object3D? objectByUuid(String uuid ) {
		return this.scene.getObjectByProperty( 'uuid', uuid);//, true );
	}
  void add(three.Object3D? object,{three.Object3D? parent, int? index, bool usingUndo = false}){
    if(object == null) return;
		if ( parent == null ) {
			this.scene.add( object );
		} 
    else {
			parent.children.insert(index ?? 0, object);
			object.parent = parent;
		}
    object.position.setFrom(orbit.target);
    object.userData['mainMaterial'] = object.material;
  
    if(shading == ShadingType.wireframe){
      materialWireframe(ShadingType.material,object,true);
    }
    else if(shading == ShadingType.solid){
      materialSolid(ShadingType.material,object,true);
    }

    if(object.userData['skeleton'] != null){
      skeleton.add(object.userData['skeleton']);
    }

    if(!usingUndo) execute(AddObjectCommand(this, object));
  }
  void addAll(List<three.Object3D> objects){
    for(final object in objects){
      add(object);
    }
  }
  void copyAll(List<three.Object3D>? objects){
    if(objects == null) return;
    for(final object in objects){
      if(object.userData['path'] != null){
        modelInsert.insert(object.userData['path']).then((_){
          setState((){});
        });
      }
      else{
        final copy = object.clone();
        copy.userData.clear();
        BoundingBoxHelper? h;
        if(!object.name.contains('Collider-')){
          copy.children.clear();
          final three.BoundingBox box = three.BoundingBox();
          box.setFromObject(copy,true);

          h = BoundingBoxHelper(box)..visible = false;
        }

        add(copy..add(h));
        setState((){});
      }
    }
  }
  void removeAll(List<three.Object3D> objects){
    for(final object in objects){
      remove(object);
    }
  }
  void remove(three.Object3D object, [bool usingUndo = false]){
    if(!usingUndo) execute(RemoveObjectCommand(this, object));
    scene.remove(object);
    if(object.name.contains('terrain_')){
      terrains.remove(object);
    }
    else if(object.userData['helper'] != null){
      threeJs.scene.remove(object.userData['helper']);
      scene.remove(object.userData['helper']);
      object.userData['helper'].traverse((object) {
        if (object is three.Mesh) {
          if (object.material is three.MeshStandardMaterial) {
            object.material?.needsUpdate = true;
          }
        }
      });
    }
    else if(object.userData['skeleton'] != null){
      threeJs.scene.remove(object.userData['skeleton']);
      scene.remove(object.userData['skeleton']);
      skeleton.remove(object.userData['skeleton']);
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
    if(object.name.contains('Collider-')) return;
    if(start)_changeToVertex(object);
    for(final o in object.children){
      _changeToVertex(o);
      materialVertexMode(type, o);
    }
  }
  void materialVertexModeAll(ShadingType type){
    for(final o in scene.children){
      if(!o.name.contains('Collider-')){
        _changeToVertex(o);
        materialVertexMode(type, o);
      }
    }
  }

  void _changeToSolid(ShadingType type, three.Object3D o){
    if(o is! BoundingBoxHelper && o is! SkeletonHelper){
     if (o is three.Mesh && o.material != null) {
        int side = _changeShared(type, o);
        o.material = three.MeshMatcapMaterial.fromMap({'side': side, 'flatShading': true}); // Example: set to red
        o.material?.name = 'solid';
        o.material?.needsUpdate = true; // Inform Three.js that the material has changed
      }
    }
  }
  void materialSolid(ShadingType type, three.Object3D object,[bool start = false]){
    if(object.name.contains('Collider-')) return;
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
        if(!o.name.contains('Collider-')){
          _changeToSolid(type,o);
          materialSolid(type,o);
        }
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
      o.material = three.MeshMatcapMaterial.fromMap({'wireframe': true,'wireframeLinewidth':2}); // Example: set to red
      o.material?.name = 'wireframe';
      o.material?.needsUpdate = true;
    }
  }
  void materialWireframe(ShadingType type, three.Object3D object,[bool start = false]){
    if(object.name.contains('Collider-')) return;
    if(start)_changeToWireframe(type,object);
    for(final o in object.children){
      _changeToWireframe(type,o);
      materialWireframe(type,o);
    }
  }
  void materialWireframeAll(ShadingType type){
    for(final o in scene.children){
      if(!o.name.contains('Collider-')){
        _changeToWireframe(type,o);
        materialWireframe(type,o);
      }
    }
  }

	three.Material? getObjectMaterial(three.Object3D object, [int? slot ]) {
		three.Material? material = object.material;

		if (material is three.GroupMaterial && slot != null ) {
			material = material.children[ slot ];
		}

		return material;
	}
	void setObjectMaterial(three.Object3D object, int? slot, newMaterial ) {
		if (object.material is three.GroupMaterial && slot != null ) {
			(object.material as three.GroupMaterial?)?.children[ slot ] = newMaterial;
		} 
    else {
			object.material = newMaterial;
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
  
  void setControlSpace(ControlSpaceType space){
    _controlSpace = space;
    control.space = space == ControlSpaceType.global?'world':'local';
  }
  void resetCameraView(){
    threeJs.camera.position.setFrom( resetCamPos );
    threeJs.camera.quaternion.setFrom( resetCamQuant );
    orbit.target.setFrom(resetCamLookAt);
  }
  void setToMainCamera(){
    if(mainCamera == null) return;
    threeJs.camera.position.setFrom( mainCamera!.position );

    final direction = three.Vector3();
    mainCamera!.getWorldDirection(direction);

    final distance = 10; // Use a distance appropriate for your scene
    final newTarget = three.Vector3().setFrom(mainCamera!.position).add(direction.scale(distance));

    orbit.target.setFrom(newTarget);
    orbit.update();
  }
  IntersectsInfo getIntersections(List<three.Object3D> objects){
    IntersectsInfo ii = IntersectsInfo([], []);
    int i = 0;
    for(final o in objects){
      if(o.visible && contains(o)){
        if((o is three.Light && o is! three.AmbientLight) || o is three.Camera){
          final h = o.userData['helper'];
          final List<three.Object3D> l = [];
          if(h != null){
            l.add(h);
          }
          final inter = raycaster.intersectObjects(l, true);
          ii.intersects.addAll(inter);
          ii.oInt.addAll(List.filled(inter.length, i));
        }
        else if(o is three.Group || o is three.AnimationObject || o.runtimeType == three.Object3D){
          final inter = raycaster.intersectObjects(o.children, true);
          // ii.intersects.addAll(inter.intersects);
          // ii.oInt.addAll(List.filled(inter.intersects.length, i));
          ii.intersects.addAll(inter);
          ii.oInt.addAll(List.filled(inter.length, i));
        }
        else if(o is! three.Bone && o is! BoundingBoxHelper){
          final inter = raycaster.intersectObject(o, false);
          ii.intersects.addAll(inter);
          ii.oInt.addAll(List.filled(inter.length, i));
        }
      }
      i++;
    }
    return ii;
  }
  void boxSelect(bool select){
    if(intersected.isEmpty) return;
    if(isVoxelPainter){
      resetVoxelPainter();
    }
    for(final intersect in intersected){
      if(!select){
        sceneSelected = false;
        control.detach();
        for(final o in intersect.children){
          if(o is BoundingBoxHelper || o is SkeletonHelper){
            o.visible = false;
          }
        }
        if(intersect.userData['skeleton'] is SkeletonHelper){
          intersect.userData['skeleton'].visible = false;
        }
      }
      else{
        for(final o in intersect.children){
          if(o is SkeletonHelper){
            o.visible = true;
          }
          else if(o is BoundingBoxHelper){
            o.visible = true;
          }
        }
        if(intersect.userData['skeleton'] is SkeletonHelper){
          intersect.userData['skeleton'].visible = true;
        }
        //if(intersected.length == 1 && contains(intersect)){
        if(selectorType.isGimble && !isVoxelPainter){
          control.attach( intersect );
        }
        else{
          control.detach();
        }
      }
    }
  }

  void setGridRotation(GridAxis axis) => gridInfo.setGridRotation(axis);
  
  three.Vector2 convertPosition(three.Vector2 location){
    final RenderBox renderBox = listenableKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    double x = location.x / size.width * 2 - 1;
    double y = -location.y / size.height * 2 + 1;
    return three.Vector2(x,y);
  }

  void checkIntersection(List<three.Object3D> objects) {
    IntersectsInfo ii = getIntersections(objects);
    raycaster.setFromCamera(convertPosition(mousePosition), threeJs.camera);
    if (ii.intersects.isNotEmpty ) {
      if(intersected != objects[ii.oInt[0]]) {
        if(intersected.isNotEmpty){
          boxSelect(false);
        }
        intersected.add(objects[ii.oInt[0]]);
        boxSelect(true);
      }
    }
    else if(intersected.isNotEmpty){
      boxSelect(false);
      intersected.clear();
    }

    if(didClick && intersected.isNotEmpty){

    }
    else if(didClick && ii.intersects.isEmpty){
      boxSelect(false);
      intersected.clear();
    }

    didClick = false;
    setState(() {});
  }

  bool contains(three.Object3D object){
    return scene.children.contains(object) || threeJs.scene.children.contains(object);
  }

  Future<void> crerateThumbnial(three.Object3D model, [three.BoundingBox? box]) async{
    thumbnail.captureThumbnail('$dirPath/assets/thumbnails/', model: model, box: box);
  }

  void viewSky(){
    sky.visible = !sky.visible;
  }
  void createVoxelPainter(){
    add(
      VoxelPainter(
        listenableKey: listenableKey, 
        camera: threeJs.camera, 
        gridInfo: gridInfo
      )..name = 'Voxel Painter'
    );
  }
  void createTerrain(){
    terrains.add(Terrain(this,setState,terrains.length));
    terrains.last.setup();
  }
  void resetVoxelPainter(){
    if(isVoxelPainter){
      (intersected.first as VoxelPainter).deactivate();
      _selectorType = SelectorType.translate;
      setState((){});
    }
  }
  void setSelector(SelectorType type){
    _selectorType = type;
     if(type != SelectorType.paint && type != SelectorType.erase) resetVoxelPainter();
    if(
      type == SelectorType.select || 
      type == SelectorType.paint ||
      type == SelectorType.erase
    ){
      control.enabled = false;
      control.detach();

      if((type == SelectorType.paint || type == SelectorType.erase) && isVoxelPainter){
        (intersected.first as VoxelPainter).activate();
        (intersected.first as VoxelPainter).selectorType = type;
      }
    }
    else{
      control.setMode(GizmoType.values[type.index]);
      control.enabled = true;
    }
  }

  void selectScene(){
    control.detach();
    intersected.clear();
    sceneSelected = true;
  }

  void selectPart(three.Object3D? child){
    if(child == null) return;
    boxSelect(false);
    intersected.clear();
    intersected.add(child);
    boxSelect(true);
    sceneSelected = false;
  }

  void deselect(){
    boxSelect(false);
    control.detach();
    intersected.clear();
    sceneSelected = false;
  }

  void reset(bool isImport){
    copy = null;
    _controlSpace = ControlSpaceType.global;
    shading = ShadingType.solid;
    _selectorType = SelectorType.translate;
    mousePosition.setValues(0, 0);
    holdingKey = null;
    selectionHelperEnabled = false;
    control.detach();

    didClick = false;
    sceneSelected = false;
    showCameraView = false;
    tempSnap = false;

    intersected.clear();
    terrains.clear();
    scene.clear();
    skeleton.clear();

    threeJs.scene.background = three.Color.fromHex32(theme.canvasColor.toARGB32());
    threeJs.scene.fog?.color = three.Color.fromHex32(theme.canvasColor.toARGB32());
    threeJs.scene.fog?.near = 10;
    threeJs.scene.fog?.far = 500;

    fog.color = three.Color.fromHex32(theme.canvasColor.toARGB32());
    fog.near = 2;
    fog.far = 10;

    _setSky();
    if(!isImport){
      _addCamera();
      resetCameraView();
    }
    else if(mainCamera != null){
      remove(mainCamera!);
      changeCamera(null);
    }

    setSelector(_selectorType);
    control.setSpace('world');

    gridInfo.reset();
    history.clear();
    setState((){});
  }
}