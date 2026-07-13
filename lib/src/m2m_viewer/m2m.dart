import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/enums.dart';
import 'package:three_forge/src/helpers/get_content.dart';
import 'package:three_forge/src/m2m_viewer/src/model_preview_display.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_load_model.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_weight_skin.dart';
import 'package:three_forge/src/navigation/navigation.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class Mesh2Motion{
  ForgeScene? forgeScene;
  double fovAspect = 1;
  late ViewHelper viewHelper;
  final GridHelper grid = GridHelper()..material?.color.setFromHex32(themeType == LsiThemes.dark?Colors.grey[900]!.value:Colors.grey[700]!.value)..material?.vertexColors = false;
  final three.Renderer renderer;
  late final three.Scene scene;
  late final three.Camera camera;

  three.Object3D? armature;
  SkeletonHelper? skeleton;
  File? reference;
  Directory get baseDir => Directory.current;

  late three.OrbitControls orbit;
  late TransformControls control;
  GlobalKey<three.PeripheralsState> globalKey;

  three.Object3D? get animationObject => loadModelStep.modelMeshes();
  three.GLTFLoader loader = three.GLTFLoader();
  Map<String,dynamic> contents = {};

  List<DropdownMenuItem<String>> rigSelector = [];
  List<three.Mesh> skeletonHandles = [];
  three.Raycaster raycaster = three.Raycaster();
  three.Mesh? _hoveredClickMesh;

  bool get isTexture => meshPreviewDisplayType == ModelPreviewDisplay.textured;
  bool mirror = false;

  bool useHeadWeightCorrection = false;
  double get previewPlaneHeight => _box.position.y;

  List<String> exportAnimations = [];

  three.Mesh _plane = three.Mesh(three.PlaneGeometry(),three.MeshBasicMaterial.fromMap({
    'color': 0x00ff00,
    'transparent': true,
    'opacity': 0.7,
    //'depthWrite': true,
    'depthTest': true,
    'side': three.DoubleSide
  }));

  late three.Mesh _box = three.Mesh(
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

  //StepEditSkeleton editSkeletonStep = StepEditSkeleton();
  StepWeightSkin weightSkinStep = StepWeightSkin();
  StepLoadModel loadModelStep = StepLoadModel();

  List<three.AnimationClip>? animations;
  ModelPreviewDisplay meshPreviewDisplayType = ModelPreviewDisplay.weightPainted;
  Function setState;
  
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
      }
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
      armature = null;
    }
    if(skeleton != null){
      scene.remove( skeleton! );
      skeleton = null;
    }

    reference = null;

    if(key != null){
      final rig = await loader.fromAsset('${contents[key]['rig']}');
      final obj = rig!.scene..name = key;
      final seleton = SkeletonHelper(obj);
      attachInteractivePointsToHelper(seleton, key);
      obj.userData['skeleton'] = seleton;
      skeleton = seleton;
      armature = obj;

      scene.add(armature);
      scene.add(seleton);

      reference = File('${baseDir.path}/m2m/${contents[key]['reference']}');
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

  void attachInteractivePointsToHelper(SkeletonHelper skeletonHelper,String key) {
    skeletonHandles.clear();

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
      skeletonHandles.add(_box);
      skeletonHandles.add(clickMesh);
    }
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

  List<Widget> animationVideos(String key, double width, BuildContext context, String search) {  
    List<Widget> widgets = [];
    
    // Safety guard against missing or misconfigured dictionary keys
    if (contents[key] == null || contents[key]['previews'] == null) {
      return [];
    }

    final String query = search.toLowerCase().trim();

    // Iterate directly through the structured file paths array
    for (final dynamic path in contents[key]['previews']) {
      final String pathString = path.toString();
      final name = pathString.split('/').last.split('.').first.replaceAll('_', ' ');

      if(query.isEmpty || name.toLowerCase().contains(query)){
        // Normalize path separation boundaries depending on how tempPath handles slash prefixes
        final String cleanPath = pathString.startsWith('/') ? pathString.substring(1) : pathString;
        final File file = File('${baseDir.path}/m2m/$cleanPath');

        //final width = 120.0;
        final height = 200.0;

        widgets.add(
        Container(
            height: height,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    print("Tapped preview element target: ${file.path}");
                  },
                  child: Container(
                    height: height-45,
                    child: MediaKitVideoPreview(file: file),
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(!exportAnimations.contains(pathString)){
                      exportAnimations.add(pathString);
                    }
                    else{
                      exportAnimations.remove(pathString);
                    }

                    print(exportAnimations);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height:25,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SavedWidgets.checkBox(exportAnimations.contains(pathString)),
                        Text('${name.toUpperCase()}'),
                      ]
                    )
                  )
                ),
              ],
            )
          )
        );
      }
    }
    
    return widgets;
  }

  void dispose(){
    control.dispose();
    orbit.dispose();
    viewHelper.dispose();
    scene.dispose();
  }

  void start(ForgeScene newScene, three.Object3D object, [three.BoundingBox? box]){
    if(ForgeScene.main == newScene) return;

    exportAnimations.clear();

    orbit.enabled = true;
    if(animationObject != null){
      scene.remove(animationObject!);
      scene.remove(weightSkinStep.weightPaintedMeshGroup()!);
    }
    loadModelStep.clearLoadedModelData();
    loadModelStep.loadGeometry(object);

    forgeScene = newScene;
    
    if(ForgeScene.rig == newScene){
      control.enabled = true;
      scene.add(animationObject);
      //_positionCamera(animationObject!,box);
    }
    else{
      scene.add(animationObject);
      scene.add(SkeletonHelper(animationObject!));

      loader.fromAsset('${contents['human']['animations'][0]}').then((gltf){
        animations?.clear();
        animations = [];

        for(final a in gltf!.animations!){
          if(a is three.AnimationClip) animations?.add(a);
        }
        final ao = animationObject as three.AnimationObject;
        ao.animations.addAll(animations!);
      });
    }
  }

  void stop(){
    control.enabled = false;
    orbit.enabled = false;

    if(armature != null){
      scene.remove( armature! );
      armature = null;
    }
    if(skeleton != null){
      scene.remove( skeleton! );
      skeleton = null;
    }
    reference = null;
    exportAnimations.clear();
  }

  void _positionCamera(three.Object3D object, [three.BoundingBox? box]){
    if(box == null){
      box = three.BoundingBox();
      box.setFromObject(object);
    }

    final size = box.getSize(three.Vector3());
    final center = box.getCenter(three.Vector3());

    // Position the camera to fit the model
    final maxDim = math.max(size.x, math.max(size.y, size.z));
    final fov = camera.fov * (math.pi / 180);
    double cameraZ = (maxDim / 2 / math.tan(fov / 2)).abs();

    if (size.x / size.y > fovAspect) {
      cameraZ = (size.x / 2 / math.tan(fov / 2) / fovAspect).abs();
    }

    cameraZ *= 1.5; // Add some padding
    camera.position.setValues(center.x, center.y, center.z + cameraZ);
    camera.lookAt(center);

    scene.add(object);
  }

  void render(double dt){
    renderer.clear();
    renderer.render(scene, camera);
    viewHelper.render(renderer);
    if (viewHelper.animating ) {
      viewHelper.update( dt );
    }
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
    // needed for skinning process
    calculateSkinWeightingForModels();

    // if the weight painted mesh is not in scene, add it
    if (scene.getObjectByName('Weight Painted Mesh') == null) {
      scene.add(weightSkinStep.weightPaintedMeshGroup()!);
    }
  }

  void calculateSkinWeightingForModels() {
    // we only need one binding skeleton. All skinned meshes will use this.
    weightSkinStep.resetAllSkinProcessData();

    // clear out any existing skinned meshes in storage
    // needed for skinning process if we change modes
    weightSkinStep.createBoneFormulaObject(armature!, SkeletonType.fromString(armature?.name));

    // Pass head weight correction settings to the weight skin step
    weightSkinStep.setHeadWeightCorrectionSettings(
      useHeadWeightCorrection,
      previewPlaneHeight,
    );
    print(previewPlaneHeight);
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

class MediaKitVideoPreview extends StatefulWidget {
  final File file;

  const MediaKitVideoPreview({Key? key, required this.file}) : super(key: key);

  @override
  State<MediaKitVideoPreview> createState() => _MediaKitVideoPreviewState();
}

class _MediaKitVideoPreviewState extends State<MediaKitVideoPreview> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    
    // 1. Instantiate the background controller engine
    _player = Player(
      configuration: const PlayerConfiguration(
        muted: true, // Auto-mute preview loops
      ),
    );

    // 2. Link player instance straight to the native rendering controller layer
    _controller = VideoController(_player);

    // 3. Queue up the local system target path pointer and trigger continuous loops
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.open(Media(widget.file.path), play: true);
  }

  @override
  void dispose() {
    // Release the active hardware controller tracking arrays safely
    _player.stop().then((_){
      _player.dispose();
    });
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Video(
        controller: _controller,
        controls: NoVideoControls, // Prevents showing play/pause/scrub overlay elements
        fit: BoxFit.cover,        // Fits cleanly into fixed square frame metrics
      ),
    );
  }
}
