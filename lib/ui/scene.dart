import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_geometry/three_js_geometry.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';
import 'package:three_js_objects/three_js_objects.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:css/css.dart';
import '../src/navigation/right_click.dart';

enum ShadingType{wireframe,solid,material}
enum EditType{point,edge,face}
class GridInfo{
  int divisions = 10;
  double size = 10;
  int color = Colors.grey[900]!.value;
  double x = 0;
  double y = 0;
}
class IntersectsInfo{
  IntersectsInfo(this.intersects,this.oInt);
  List<three.Intersection> intersects = [];
  List<int> oInt = [];
}
class EditInfo{
  bool active = false;
  EditType type = EditType.point;
  three.Object3D? object;
}


class ForgeScene{
  EditInfo editInfo = EditInfo();

  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 mousePosition = three.Vector2.zero();
  three.Object3D? intersected;
  three.AnimationMixer? mixer;
  three.AnimationClip? currentAnimation;

  late three.ThreeJS threeJs;

  late TransformControls control;
  late three.OrbitControls orbit;
  late three.PerspectiveCamera cameraPersp;
  late three.OrthographicCamera cameraOrtho;

  Map<String,List> animationClips = {};

  bool didClick = false;
  bool usingMouse = false;

  three.Group helper = three.Group();
  GridHelper grid = GridHelper( 500, 500, Colors.grey[900]!.value, Colors.grey[900]!.value);
  GridInfo gridInfo = GridInfo();

  three.Vector3 resetCamPos = three.Vector3(5, 2.5, 5);

  bool holdingControl = false;
  three.Object3D? copy;

  late RightClick rightClick;
  three.Scene scene = three.Scene();
  three.Group editObject = three.Group();
  ShadingType shading = ShadingType.solid;

  void initState(){
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});},
      setup: setup,
    );
    rightClick = RightClick(
      context: context,
      style: null,
      onTap: rightClickActions,
    );
    super.initState();
  }

  void dispose(){
    control.dispose();
    orbit.dispose();
    rightClick.dispose();
    threeJs.dispose();
  }

  Future<void> setup() async{
    const frustumSize = 5.0;
    final aspect = threeJs.width / threeJs.height;
    cameraPersp = three.PerspectiveCamera( 50, aspect, 0.1, 100 );
    cameraOrtho = three.OrthographicCamera( - frustumSize * aspect, frustumSize * aspect, frustumSize, - frustumSize, 0.1, 100 );
    threeJs.camera = cameraPersp;

    threeJs.camera.position.setFrom(resetCamPos);

    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(CSS.darkTheme.canvasColor.value);
    threeJs.scene.fog = three.Fog(CSS.darkTheme.canvasColor.value, 10,50);
    threeJs.scene.add( grid );

    final ambientLight = three.AmbientLight( 0xffffff, 0 );
    threeJs.scene.add( ambientLight );

    final light = three.DirectionalLight( 0xffffff, 0.5 );
    light.position = threeJs.camera.position;
    threeJs.scene.add( light );

    orbit = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    control = TransformControls(threeJs.camera, threeJs.globalKey);

    control.addEventListener( 'dragging-changed', (event) {
      orbit.enabled = ! event.value;
    });
    creteHelpers();
    threeJs.scene.add( control );
    threeJs.scene.add(helper);
    threeJs.scene.add(editObject);

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
      if(control.dragging){
        updateCubes();
      }
    });

    threeJs.addAnimationEvent((dt){
      mixer?.update(dt);
      orbit.update();
    });
  }

  void creteHelpers(){
    List<double> vertices = [500,0,0,-500,0,0,0,0,500,0,0,-500];
    List<double> colors = [1,0,0,1,0,0,0,0,1,0,0,1];
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

    helper.add(
      three.LineSegments(geometry,material)
      ..computeLineDistances()
      ..scale.setValues(1,1,1)
    );
    
    final viewHelper = ViewHelper(
      //size: 1.8,
      offsetType: OffsetType.topRight,
      offset: three.Vector2(-200, 10),
      screenSize: const Size(120, 120), 
      listenableKey: threeJs.globalKey,
      camera: threeJs.camera,
      //threeJs: threeJs
    );

    threeJs.renderer?.autoClear = false;
    threeJs.postProcessor = ([double? dt]){
      threeJs.renderer?.render( threeJs.scene, threeJs.camera );
      viewHelper.render(threeJs.renderer!);
    };
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
    setState(() {

    });
  }

  three.Vector2 convertPosition(three.Vector2 location){
    double x = (location.x / (threeJs.width-MediaQuery.of(context).size.width/6)) * 2 - 1;
    double y = -(location.y / (threeJs.height-20)) * 2 + 1;
    return three.Vector2(x,y);
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
}