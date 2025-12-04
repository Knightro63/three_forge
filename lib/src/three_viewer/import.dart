import 'package:three_forge/src/objects/create_mesh.dart';
import 'package:three_forge/src/objects/create_models.dart';
import 'package:three_forge/src/objects/insert_mesh.dart';
import 'package:three_forge/src/objects/insert_models.dart';
import 'package:three_forge/src/three_viewer/src/grid_info.dart';
import 'package:three_forge/src/three_viewer/src/terrain.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

class ThreeForgeImport{
  final ThreeViewer threeV;
  late final InsertMesh insertMesh = InsertMesh(threeV);
  late final InsertModels insertModel = InsertModels(threeV);

  ThreeForgeImport(this.threeV);

  void _setTransform(Object3D object, Map<String,dynamic> map){
    object.position.setValues(map['position']['x'], map['position']['y'], map['position']['z']);
    object.scale.setValues(map['scale']['x'], map['scale']['y'], map['scale']['z']);
    object.rotation.set(map['rotation']['x'], map['rotation']['y'], map['rotation']['z']);
  }

  void _setRotation(Euler rotation, Map<String,dynamic> map){
    rotation.set(map['x'], map['y'], map['z']);
  }

  Future<void> _insertObject(Map<String,dynamic> map) async{
    await insertModel.insert(map['path']);
    final object = threeV.scene.children.last;
    _setTransform(object, map['transform']);
    object.uuid = map['uuid'];
    object.name = map['name'];
    object.userData['audio'] = map['audio'];
    for(final key in map['importedActions'].keys){
      final path = map['importedActions'][key];
      CreateModels.addFBXAnimation(object, path, threeV);
    }
    object.userData['importedActions'] = map['importedActions'];
    object.userData['scriptPath'] = map['scriptPath'];
    object.userData['physics'] = map['physics'];
    await _setAttachedObject(object, map);
  }

  Future<Object3D> _createObject(Map<String,dynamic> map) async{
    final object = (await CreateModels.create(map['path']))!;
    _setTransform(object, map['transform']);
    object.uuid = map['uuid'];
    object.name = map['name'];
    object.userData['audio'] = map['audio'];
    for(final key in map['importedActions'].keys){
      final path = map['importedActions'][key];
      CreateModels.addFBXAnimation(object, path, threeV);
    }
    object.userData['importedActions'] = map['importedActions'];
    object.userData['scriptPath'] = map['scriptPath'];
    object.userData['physics'] = map['physics'];
    await _setAttachedObject(object, map);

    return object;
  }

  Future<void> _setAttachedObject(Object3D object, Map<String,dynamic> map) async{
    if(map['attachedObjects'] == null) return;
    Map<String,dynamic> attachedObjects = map['attachedObjects'];
    object.userData['attachedObjects'] = <String,List<Object3D>>{};
    for(final key in attachedObjects.keys){
      object.userData['attachedObjects'][key] = <Object3D>[];
      for(final l in attachedObjects[key]!){
        
        final name = l.keys.toList()[0];
        Object3D? o;
        final m = l[name];

        if(name.contains('object')){
          o = await _createObject(m);
        }
        else if(name.contains('mesh')){
          o = await _createrMesh(m);
        }
        else if(name.contains('collider')){
          o = await _createrCollider(m);
        }

        if(o != null){
          if(object.userData['attachedObjects']?[name] == null){
            object.userData['attachedObjects']?[name] = <Object3D>[];
          }
          object.userData['attachedObjects'][name].add(o);
          final selectedBone = threeV.scene.getObjectByName(l['parent']);
          selectedBone?.add(o);
        }
      }
    }
  }

  Future<void> _createVoxel(Map<String,dynamic> map) async{
    threeV.addVoxelPainter();
    final voxel = threeV.scene.children.last;
    voxel.uuid = map['uuid'];
    voxel.name = map['name'];
    _setTransform(voxel, map['transform']);
    final object = voxel.add(await CreateModels.create(map['object']));

    for(final key in map['children'].keys){
      final child = object.clone();
      voxel.children.add(child);
      _setTransform(child,map['children'][key]);
    }
  }

  Map<String,dynamic> _createMaterial(Mesh mesh){
    return mesh.material!.toJson();
  }

  void _setMainCameras(Map<String,dynamic> map){
    if('PerspectiveCamera' == map['type']){
      _setCamera(threeV.cameraPersp, map);
    }
    else{
      _setCamera(threeV.cameraOrtho, map);
    }
  }

  void _createCamera(Map<String,dynamic> map, bool add){
    late final Camera camera;
    if('PerspectiveCamera' == map['type']){
      camera = PerspectiveCamera(
        map['fov'],
        map['aspect'],
        map['near'],
        map['far'],
      );
    }
    else{
      camera = OrthographicCamera(
        map['left'],
        map['right'],
        map['top'],
        map['bottom'],
        map['near'],
        map['far'],
      );
    }
    camera.uuid = map['uuid'];
    camera.name = map['name'];
    camera.zoom = map['zoom'];
    _setTransform(camera, map['transform']);
    if(add) threeV.add(camera);
  }
  void _setCamera(Camera camera, Map<String,dynamic> map){
    camera.fov = map['fov'];
    camera.aspect = map['aspect'];
    camera.near = map['near'];
    camera.far = map['far'];
    camera.left = map['left'];
    camera.right = map['right'];
    camera.top = map['top'];
    camera.bottom = map['bottom'];
    camera.near = map['near'];
    camera.far = map['far'];
    camera.uuid = map['uuid'];
    camera.name = map['name'];
    camera.zoom = map['zoom'];
    _setTransform(camera, map['transform']);
  }
  void _createLight(Map<String,dynamic> map){
    late final Light light;

    if(map['type'] == 'AmbientLight'){
      light = AmbientLight(map['color'],map['intensity']);
    }
    else if(map['type'] == 'SpotLight'){
      light = SpotLight(map['color'],map['intensity'],map['distance'],map['angle'],map['penumbra'],map['decay']);
    }
    else if(map['type'] == 'DirectionalLight'){
      light = DirectionalLight(map['color'],map['intensity']);
    }
    else if(map['type'] == 'PointLight'){
      light = PointLight(map['color'],map['intensity'],map['distance'],map['decay']);
    }
    else if(map['type'] == 'RectAreaLight'){
      light = RectAreaLight(map['color'],map['intensity'],map['width'],map['height']);
    }
    else if(map['type'] == 'HemisphereLight'){
      light = HemisphereLight(map['color'],map['groundColor'],map['intensity']);
    }

    _setTransform(light, map['transform']);
    light.castShadow = map['castShadow'];
    light.userData['scriptPath'] = map['script'];
    if(map['camera'] != null && light.shadow?.camera != null) _setCamera(light.shadow!.camera!,map['camera']);
    if(map['map'] != null && light.shadow?.camera != null){
      light.shadow?.map?.width = map['map']['width'];
      light.shadow?.map?.height = map['map']['height'];
    }
    if(map['shadow'] != null && light.shadow?.camera != null){
      light.shadow?.bias = map['shadow']['bias'];
      light.shadow?.radius = map['shadow']['radius'];
    }
  }

  Future<void> _insertMesh(Map<String,dynamic> map) async{
    await insertMesh.insert(map['type']);
    final mesh = threeV.scene.children.last;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['audio'] = map['audio'];
    mesh.userData['scriptPath'] = map['script'];
    mesh.userData['subdivisions'] = map['subdivisions'];
    mesh.userData['decimate'] = map['decimate'];
    mesh.userData['subdivisionType'] = map['subdivisionType'];
    if(map['physics'] != null) CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);

    if(map['subdivisions'] != null){
      CreateMesh.subdivision(mesh, map['subdivisionType'] == 'simple');
    }
    else if(map['decimate'] != null){
      CreateMesh.decimate(mesh);
    }
  }
  Future<Mesh?> _createrMesh(Map<String,dynamic> map) async{
    final mesh = CreateMesh.create(map['type'])!;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['audio'] = map['audio'];
    mesh.userData['scriptPath'] = map['script'];
    mesh.userData['subdivisions'] = map['subdivisions'];
    mesh.userData['decimate'] = map['decimate'];
    mesh.userData['subdivisionType'] = map['subdivisionType'];
    if(map['physics'] != null) CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);

    if(map['subdivisions'] != null){
      CreateMesh.subdivision(mesh, map['subdivisionType'] == 'simple');
    }
    else if(map['decimate'] != null){
      CreateMesh.decimate(mesh);
    }

    return mesh;
  }
  void _insertCollider(Map<String,dynamic> map){
    insertMesh.insert(map['type']);
    final mesh = threeV.scene.children.last;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['scriptPath'] = map['script'];
    mesh.userData['audio'] = map['audio'];
    CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);
  }
  Mesh? _createrCollider(Map<String,dynamic> map){
    final mesh = CreateMesh.create(map['type'])!;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['scriptPath'] = map['script'];
    mesh.userData['audio'] = map['audio'];
    CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);
    return mesh;
  }
  void _createScene(Map<String,dynamic> map){
    Scene scene = threeV.scene;

    scene.name = map['name'];
    scene.uuid = map['uuid'];
    scene.userData['audio'] = map['audio'];

    if(map['backgroundType'] == 'Color'){
      scene.background = Color.fromHex32(map['background']['color']);
    }
    else{
      insertModel.insertTexture(map['background']['path'], map['background']['mapping'], map['sameastext']);
    }

    if(map['sameastext'] == false && map['environment'] != null){
      //insertModel.insertTexture(path, mappingValue, map['sameastext']);
    }

    scene.backgroundIntensity = map['backgroundIntensity'];
    scene.environmentIntensity = map['environmentIntensity'];
    _setRotation(scene.backgroundRotation, map['backgroundRotation']);
    _setRotation(scene.environmentRotation, map['environmentRotation']);

    if(map['fog'] != null){
      scene.fog?.color = Color.fromHex32(map['fog']['color']);
      scene.fog?.near = map['fog']['near'];
      scene.fog?.far = map['fog']['far'];
    }
  }

  Future<void> _createTerrain(Map<String,dynamic> map) async{
    Terrain terrain = Terrain(threeV,threeV.setState,threeV.terrains.length);
    threeV.terrains.add(terrain);
    terrain.guiSettings = map['settings'];
    terrain.terrainScene?.userData['scriptPath'] = map['scriptPath'];
    await threeV.terrains.last.setup();
  }

  void _setGrid(Map<String,dynamic> map){
    threeV.gridInfo.divisions = map['divisions'];
    threeV.gridInfo.size = map['size'];
    threeV.gridInfo.color = map['color'];
    threeV.gridInfo.x = map['x'];
    threeV.gridInfo.y = map['y'];
    threeV.gridInfo.setSnap(map['snap']);
    threeV.gridInfo.axis = GridAxis.values[map['axis']];
  }

  Future<void> import(Map<String,dynamic> allMap) async{
    for(final key in allMap.keys){
      Map<String,dynamic> map = allMap[key];
      if(key.contains('scene')){
        _createScene(map);
      }
      else if(key.contains('grid')){
        _setGrid(map);
      }
      else if(key.contains('object')){
        await _insertObject(map);
      }
      else if(key.contains('collider')){
        _insertCollider(map);
      }
      else if(key.contains('mesh')){
        await _insertMesh(map);
      }
      else if(key.contains('camera') && map['camera']?['mainCamera'] == true){
        _setMainCameras(map);
      }
      else if(key.contains('camera')){
        _createCamera(map, true);
      }
      else if(key.contains('light')){
        _createLight(map);
      }
      else if(key.contains('voxel')){
        await _createVoxel(map);
      }
      else if(key.contains('terrain')){
        await  _createTerrain(map);
      }
    }
  }
}