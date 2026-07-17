import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/enums.dart';
import 'package:three_forge/src/helpers/get_content.dart';
import 'package:three_forge/src/m2m_viewer/src/model_preview_display.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_animations.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_edit_skeleton.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_load_model.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_weight_skin.dart';
import 'package:three_forge/src/navigation/navigation.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';
import 'package:media_kit/media_kit.dart';

class Mesh2Motion{
  ForgeScene? forgeScene;
  double fovAspect = 1;
  late ViewHelper viewHelper;
  final GridHelper grid = GridHelper()..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[900]!.value:Colors.grey[700]!.value)..material?.vertexColors = false;
  final three.Renderer renderer;
  late final three.Scene scene;
  late final three.Camera camera;

  File? reference;
  Directory get baseDir => Directory.current;

  late three.OrbitControls orbit;
  late TransformControls control;
  GlobalKey<three.PeripheralsState> globalKey;

  three.Object3D? get animationObject => loadModelStep.modelMeshes();
  three.GLTFLoader loader = three.GLTFLoader();
  Map<String,dynamic> contents = {};

  bool get isTexture => meshPreviewDisplayType == ModelPreviewDisplay.textured;
  bool useHeadWeightCorrection = false;
  
  List<DropdownMenuItem<String>> rigSelector = [];

  late final StepEditSkeleton editSkeletonStep;
  three.Mesh get _box => editSkeletonStep.selectBox;
  three.Object3D? get armature => editSkeletonStep.armature;
  SkeletonHelper? get skeleton => editSkeletonStep.skeleton;
  bool get mirror => editSkeletonStep.mirror;
  set mirror(bool value) => editSkeletonStep.mirror = value;

  final StepWeightSkin weightSkinStep = StepWeightSkin();
  late final StepAnimations animationsStep = StepAnimations(setState);
  List<Widget> Function(String, double, BuildContext, Map<String, dynamic>, String) get animationVideos => animationsStep.animationVideos;
  final StepLoadModel loadModelStep = StepLoadModel();

  ModelPreviewDisplay meshPreviewDisplayType = ModelPreviewDisplay.weightPainted;
  Function setState;
  String key = 'human';
  
  Mesh2Motion(this.renderer, this.globalKey, this.setState){
    MediaKit.ensureInitialized();
    _setup();
  }

  void _setup(){
    scene = three.Scene();
    scene.background = three.Color.fromHex32(theme.canvasColor.toARGB32());
    scene.fog = three.Fog(theme.canvasColor.toARGB32(), 10,500);
    scene.add( three.AmbientLight( 0xffffff ) );
    scene.add(grid);

    camera = three.PerspectiveCamera(45, 1, 0.1, 1000)
      ..position.setValues( - 0, 0, 2.7 )
      ..lookAt(scene.position);
    final light2 = three.DirectionalLight( 0xffffff, 0.5 );
    light2.position = camera.position;
    scene.add( light2 );

    orbit = three.OrbitControls(camera, globalKey);
    orbit.mouseButtons = {
      'left': three.Mouse.rotate,
      'MIDDLE': three.Mouse.pan,
      //'right': three.Mouse.pan
    };
    control = TransformControls(camera, globalKey)..addEventListener('dragging-changed', (event) {
      bool isDragging = event.value == true;
      orbit.enabled = !isDragging;
      if (!isDragging) {
        regenerateWeightPaintedPreviewMesh();
        editSkeletonStep.applyMirrorMode();
      }
    });

    control.addEventListener('change', (event) {
      editSkeletonStep.applyMirrorMode();
    });
    
    viewHelper = ViewHelper(
      //size: 1.8,
      offsetType: OffsetType.topRight,
      offset: three.Vector2(0, -35),
      screenSize: const Size(80, 80), 
      listenableKey: globalKey,
      camera: camera,
    );

    scene.add( control );
    editSkeletonStep = StepEditSkeleton(camera,control,setState);
    scene.add(_box);
    _setDropDown();
  }

  void _setDropDown() async{
    contents = await syncAndProcessAssets('./m2m') ?? {};
    final Directory baseDir = Directory.current;
    loader.setPath('${baseDir.path}/m2m');

    rigSelector.add(
      DropdownMenuItem(
        value: null,
        child: Text(
          'None', 
          overflow: TextOverflow.ellipsis,
        )
      )
    );

    for(final key in contents.keys){
      rigSelector.add(
        DropdownMenuItem(
            value: key,
            child: Text(
              LSIFunctions.capFirstLetter(key), 
              overflow: TextOverflow.ellipsis,
            )
        )
      );
    }
  }

  Future<void> selected(String? key) async{
    if(armature != null){
      scene.remove( armature! );
      editSkeletonStep.armature = null;
    }
    if(skeleton != null){
      scene.remove( skeleton! );
      editSkeletonStep.skeleton = null;
    }

    reference = null;

    if(key != null){
      this.key = key;
      final rig = await loader.fromAsset('${contents[key]['rig']}');
      final obj = rig!.scene..name = key;
      final skeleton = SkeletonHelper(obj);
      editSkeletonStep.setArmature(obj, skeleton, scene);
      reference = File('${baseDir.path}/m2m/${contents[key]['reference']}');
    }

    setState((){});
  }

  void onPointerMove(three.Vector2 normalizedMouse) {
    editSkeletonStep.onPointerMove(normalizedMouse);
  }

  void onPointerDown(three.Vector2 normalizedMouse) {
    editSkeletonStep.onPointerDown(normalizedMouse);
  }

  void rotateX(){
    loadModelStep.setModelRotation(three.Euler(math.pi/2));
    regenerateWeightPaintedPreviewMesh();
  }
  void rotateY(){
    loadModelStep.setModelRotation(three.Euler(0,math.pi/2));
    regenerateWeightPaintedPreviewMesh();
  }
  void rotateZ(){
    loadModelStep.setModelRotation(three.Euler(0,0,math.pi/2));
    regenerateWeightPaintedPreviewMesh();
  }
  void scale(double scale){
    loadModelStep.setModelScale(scale);
    regenerateWeightPaintedPreviewMesh();
  }

  void dispose(){
    control.dispose();
    orbit.dispose();
    viewHelper.dispose();
    scene.dispose();
  }

  void start(ForgeScene newScene, three.Object3D object, [three.BoundingBox? box]){
    if(ForgeScene.main == newScene) return;
    animationsStep.start();

    orbit.enabled = true;
    if(animationObject != null){
      scene.remove(animationObject!);
      scene.remove(weightSkinStep.weightPaintedMeshGroup()!);
    }
    loadModelStep.clearLoadedModelData();
    final m = object.children.first.userData['mainMaterial'];
    final c = object.children.first.clone()..material = m;
    loadModelStep.loadGeometry(c);
    // animationObject?.material = m;
    // animationObject?.material?.needsUpdate = true; // Inform Three.js that the material has changed
    forgeScene = newScene;
    scene.add(animationObject);
    if(ForgeScene.rig == newScene){
      control.enabled = true;
    }
    else{
      scene.add(SkeletonHelper(animationObject!));
      startAnimation();
    }
  }

  Future<void> startAnimation() async{
    animationsStep.setModel(weightSkinStep.skinnedObject, weightSkinStep.helper);
    for(final path in contents[key]['animations']){
      final gltf = await loader.fromAsset(path);
      animationsStep.addAnimations(
        gltf!,
        SkeletonType.fromString(key)
      );
    }
    animationsStep.onAllAnimationsLoaded();
  }

  void stop(){
    control.enabled = false;
    orbit.enabled = false;
    useHeadWeightCorrection = false;
    mirror = true;
    
    removeSkinnedMeshesFromScene();
    reference = null;

    useHeadWeightCorrection = false;
    animationsStep.stop();
  }

  void render(double dt){
    renderer.clear();
    renderer.render(scene, camera);
    viewHelper.render(renderer);
    if (viewHelper.animating ) {
      viewHelper.update( dt );
    }

    editSkeletonStep.update();
    animationsStep.update(dt);
  }

  void changeHeadWeightCorrection(){
    useHeadWeightCorrection = !useHeadWeightCorrection;
    _box.visible = useHeadWeightCorrection;
  }

  void changedModelPreviewDisplay() {
    meshPreviewDisplayType = isTexture?ModelPreviewDisplay.weightPainted:ModelPreviewDisplay.textured;

    // show/hide loaded textured model depending on view
    loadModelStep.modelMeshes()?.visible = isTexture;

    if (meshPreviewDisplayType == ModelPreviewDisplay.weightPainted) {
      regenerateWeightPaintedPreviewMesh();
    }

    // show/hide weight painted mesh depending on view
    weightSkinStep.weightPaintedMeshGroup()?.visible = !isTexture;
  }

  void changeMirror(){
    this.mirror = !mirror;
  }

  void regenerateWeightPaintedPreviewMesh() {
    if(meshPreviewDisplayType == ModelPreviewDisplay.textured) return;
    weightSkinStep.weightPaintedMeshGroup()?.visible = !isTexture;
    // needed for skinning process
    calculateSkinWeightingForModels();

    // if the weight painted mesh is not in scene, add it
    if (scene.getObjectByName('Weight Painted Mesh') == null) {
      scene.add(weightSkinStep.weightPaintedMeshGroup());
    }
  }

  void calculateSkinWeightingForModels() {
    if(armature == null) return;
    // we only need one binding skeleton. All skinned meshes will use this.
    weightSkinStep.resetAllSkinProcessData();

    // clear out any existing skinned meshes in storage
    // needed for skinning process if we change modes
    weightSkinStep.createBoneFormulaObject(armature!, SkeletonType.fromString(armature?.name));

    // Pass head weight correction settings to the weight skin step
    weightSkinStep.setHeadWeightCorrectionSettings(
      useHeadWeightCorrection,
      editSkeletonStep.previewPlaneHeight,
    );

    weightSkinStep.createBindingSkeleton();

    // add geometry data needed for skinning using explicit loop indexing
    final List<three.BufferGeometry> geometryList = loadModelStep.modelsGeometryList();
    for (int i = 0; i < geometryList.length; i++) {
      weightSkinStep.addToGeometryDataToSkin(geometryList[i]);
    }

    // all mesh material data associated with the geometry data
    final List<three.Material> materialList = loadModelStep.modelsMaterialList();
    for (int i = 0; i < materialList.length; i++) {
      weightSkinStep.addMeshMaterial(materialList[i]);
    }

    // perform skinning operation
    weightSkinStep.calculateWeightsForAllMeshData(regenerateWeightPaintedMesh: true);

    loadModelStep.modelMeshes()?.visible = false; // hide our unskinned mesh after we have done the skinning process

    // re-define skeleton helper to use the skinned mesh
    if (weightSkinStep.skeleton == null) {
      print('Tried to regenerate skeleton helper, but skeleton is undefined!');
    }
  }

  void bind(){
    control.detach();
    control.enabled = false; // shouldn't be editing bones
    calculateSkinWeightingForModels();
    removeSkinnedMeshesFromScene(); // clean up in case we had skinned meshes in scene previously
    forgeScene = ForgeScene.animate;

    weightSkinStep.helper = SkeletonHelper(weightSkinStep.skinnedObject);
    editSkeletonStep.setArmature(weightSkinStep.skinnedObject, weightSkinStep.helper!, scene, true);
    weightSkinStep.weightPaintedMeshGroup()?.visible = false; // hide weight painted mesh
    startAnimation();
  }

  void removeSkinnedMeshesFromScene(){
    if(armature != null){
      scene.remove( armature! );
      editSkeletonStep.armature = null;
    }
    if(skeleton != null){
      scene.remove( skeleton! );
      editSkeletonStep.skeleton = null;
    }
  }

  List<Widget> Function(BuildContext) get hud => forgeScene == ForgeScene.rig?editSkeletonStep.hud:animationsStep.hud;
}