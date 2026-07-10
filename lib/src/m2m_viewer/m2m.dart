import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/enums.dart';
import 'package:three_forge/src/helpers/get_content.dart';
import 'package:three_forge/src/m2m_viewer/src/model_preview_display.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_edit_skeleton.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_load_model.dart';
import 'package:three_forge/src/m2m_viewer/steps/step_weight_skin.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
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

  final three.Group rigs = three.Group();
  final three.Group rigSkeletons = three.Group();
  late three.OrbitControls orbit;
  late TransformControls control;
  GlobalKey<three.PeripheralsState> globalKey;

  three.Object3D? get animationObject => loadModelStep.modelMeshes();
  three.GLTFLoader loader = three.GLTFLoader();
  Map<String,dynamic> contents = {};

  Map<String,List<Widget>> _cachedVideos = {};
  List<DropdownMenuItem<three.Object3D?>> rigSelector = [];
  Map<String,List<three.Mesh>> skeletonHandles = {};
  three.Raycaster raycaster = three.Raycaster();
  three.Mesh? _hoveredClickMesh;
  three.Object3D? selectedRig;

  StepEditSkeleton editSkeletonStep = StepEditSkeleton();
  StepWeightSkin weightSkinStep = StepWeightSkin();
  StepLoadModel loadModelStep = StepLoadModel();

  ModelPreviewDisplay meshPreviewDisplayType = ModelPreviewDisplay.weightPainted;
  
  Mesh2Motion(this.renderer, this.globalKey){
    _setup();
  }

  void selected(three.Object3D? rig){
    selectedRig = rig;
    setRiggingToolsVisible();
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
        print("User STOPPED moving the control handle!");
        
        // B. Trigger your save, weight recalculation, or snapshot history logic here
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
    scene.add( rigs );
    scene.add( rigSkeletons );
    _importRigs();
  }

  

  Future<void> _importRigs() async{
    contents = await syncAndProcessAssets(tempPath) ?? {};
    loader.setPath(tempPath);

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
      final rig = await loader.fromAsset('${contents[key]['rig']}');
      final obj = rig!.scene..name = key;
      final seleton = SkeletonHelper(obj)..visible = false;
      attachInteractivePointsToHelper(seleton, key);
      obj.userData['skeleton'] = seleton;
      rigSkeletons.add(seleton);
      rigs.add(obj);
      rigSelector.add(
        DropdownMenuItem(
            value: obj,
            child: Text(
              LSIFunctions.capFirstLetter(key), 
              overflow: TextOverflow.ellipsis,
            )
        )
      );
    }
  }

  void onPointerMove(three.Vector2 normalizedMouse) {
    // If the rigging tools are hidden, do nothing
    if (selectedRig == null) return;

    raycaster.setFromCamera(normalizedMouse, camera);
    final intersects = raycaster.intersectObjects(skeletonHandles[selectedRig!.name]!, true);

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
    if (control.dragging || selectedRig == null) return;
    control.detach();

    raycaster.setFromCamera(normalizedMouse, camera);
    
    final intersects = raycaster.intersectObjects(skeletonHandles[selectedRig!.name]!, true);
    if (intersects.isNotEmpty) {
      final hitHandle = intersects.first.object;
      
      // Safety check against explicit hidden layer states
      if (hitHandle == null || hitHandle.visible == false) return;

      final three.Bone? underlyingBone = hitHandle.userData['bone_target'];
      if (underlyingBone != null) {
        print("Selected bone: ${underlyingBone.name}");
        control.attach(underlyingBone);
      }
    } 
  }

  void setRiggingToolsVisible() {
    bool visible = false;
    // 2. Hide/Show the custom clickable interaction spheres
    for(final rig in rigs.children){
      rig.userData['skeleton'].visible = false;
      if(selectedRig == rig){
        rig.userData['skeleton'].visible = true;
        visible = true;
      }

      for(final mesh in skeletonHandles[rig.name]!){
        if(rig.name == selectedRig?.name){
          mesh.visible = true;
        }
        else{
          mesh.visible = false;
        }
      }
    }
    
    // 3. Clean up the screen by hiding the transform arrows if turning off rigging tools
    if (!visible) {
      control.detach();
    }
  }

  void attachInteractivePointsToHelper(SkeletonHelper skeletonHelper,String key) {
    // 1. Geometry and material for the tiny visual joints
    final visualGeom = three.SphereGeometry(0.01, 16, 16);


    // 2. Geometry and material for the larger click targets
    // Bump this radius up higher if you want an even bigger tap zone!
    final clickGeom = three.SphereGeometry(0.025, 16, 16);
    final clickMat = three.MeshBasicMaterial.fromMap({
      'color': 0xff0000, 
      'visible': false,
    });

    // 3. Loop through the bones explicitly tracked by your current SkeletonHelper
    for (final bone in skeletonHelper.bones) {
      final visualMat = three.MeshBasicMaterial.fromMap({
        'color': 0x00ff00, // Bright green joints
        'transparent': true,
        'opacity': 0.8
      });
      // Create the visual dot
      final clickMesh = three.Mesh(clickGeom, clickMat);
      final visualMesh = three.Mesh(visualGeom, visualMat);
      clickMesh.userData['bone_target'] = bone;
      clickMesh.userData['visual_dot'] = visualMesh;

      bone.add(clickMesh..add(visualMesh)..visible = false);
      // CRITICAL: Push ONLY the large clickMesh to your raycaster tracking list!
      if(skeletonHandles[key] == null) skeletonHandles[key] = [];
      skeletonHandles[key]!.add(clickMesh);
    }
  }

  void rotateX(){
    animationObject?.rotateX(math.pi/2);
  }
  void rotateY(){
    animationObject?.rotateY(math.pi/2);
  }
  void rotateZ(){
    animationObject?.rotateZ(math.pi/2);
  }
  List<Widget> animationVideos(String key) {
    if (_cachedVideos[key] != null) return _cachedVideos[key]!;
    
    List<Widget> widgets = [];
    
    // Safety guard against missing or misconfigured dictionary keys
    if (contents[key] == null || contents[key]['previews'] == null) {
      return [];
    }

    // Iterate directly through the structured file paths array
    for (final dynamic path in contents[key]['previews']) {
      final String pathString = path.toString();
      
      // Normalize path separation boundaries depending on how tempPath handles slash prefixes
      final String cleanPath = pathString.startsWith('/') ? pathString.substring(1) : pathString;
      final File file = File('$tempPath/$cleanPath');

      widgets.add(
        InkWell(
          onTap: () {
            print("Tapped preview element target: ${file.path}");
          },
          child: Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: MediaKitVideoPreview(file: file),
          ),
        ),
      );
    }
    
    _cachedVideos[key] = widgets;
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
    control.enabled = true;
    orbit.enabled = true;
    if(animationObject != null){
      scene.remove(animationObject!);
      scene.remove(weightSkinStep.weightPaintedMeshGroup()!);
    }
    forgeScene = newScene;
    loadModelStep.clearLoadedModelData();
    loadModelStep.loadGeometry(object);
    _positionCamera(animationObject!,box);

    setRiggingToolsVisible();
  }

  void stop(){
    control.enabled = false;
    orbit.enabled = false;
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

  void changedModelPreviewDisplay(ModelPreviewDisplay meshTexturedDisplayType) {
    meshPreviewDisplayType = meshTexturedDisplayType;

    // show/hide loaded textured model depending on view
    loadModelStep.modelMeshes()?.visible = meshPreviewDisplayType == ModelPreviewDisplay.textured;

    if (meshPreviewDisplayType == ModelPreviewDisplay.weightPainted) {
      regenerateWeightPaintedPreviewMesh();
    }

    // show/hide weight painted mesh depending on view
    weightSkinStep.weightPaintedMeshGroup()?.visible = meshPreviewDisplayType == ModelPreviewDisplay.weightPainted;
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
    weightSkinStep.createBoneFormulaObject(selectedRig!, SkeletonType.fromString(selectedRig?.name));

    // Pass head weight correction settings to the weight skin step
    // weightSkinStep.setHeadWeightCorrectionSettings(
    //   editSkeletonStep.useHeadWeightCorrection(),
    //   editSkeletonStep.getPreviewPlaneHeight(),
    // );
    
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
    _player.dispose();
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
