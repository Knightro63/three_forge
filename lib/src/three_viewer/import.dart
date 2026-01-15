import 'package:three_forge/src/modifers/create_mesh.dart';
import 'package:three_forge/src/modifers/create_models.dart';
import 'package:three_forge/src/modifers/insert_camera.dart';
import 'package:three_forge/src/modifers/insert_empty.dart';
import 'package:three_forge/src/modifers/insert_light.dart';
import 'package:three_forge/src/modifers/insert_mesh.dart';
import 'package:three_forge/src/modifers/insert_models.dart';
import 'package:three_forge/src/three_viewer/src/grid_info.dart';
import 'package:three_forge/src/three_viewer/src/terrain.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/material_loader.dart';

class ThreeForgeImport{
  final ThreeViewer threeV;
  late final InsertMesh insertMesh = InsertMesh(threeV);
  late final InsertModels insertModel = InsertModels(threeV);
  late final InsertLight insertLight = InsertLight(threeV);
  late final InsertEmpty insertEmpty = InsertEmpty(threeV);
  late final InsertCamera insertCamera = InsertCamera(threeV);

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
    if(map['importedActions'] != null){
      for(final key in map['importedActions'].keys){
        final path = map['importedActions'][key];
        CreateModels.addFBXAnimation(object, path, threeV);
      }
    }
    object.userData['importedActions'] = map['importedActions'];
    object.userData['scripts'] = map['scripts'];
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
    object.userData['scripts'] = map['scripts'];
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
        String uuid = object.getObjectByName(l['parent'])?.uuid ?? '';
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
          if(object.userData['attachedObjects']?[uuid] == null){
            object.userData['attachedObjects']?[uuid] = <Object3D>[];
          }
          object.userData['attachedObjects'][uuid].add(o);
          final selectedBone = threeV.scene.getObjectByName(l['parent']);
          selectedBone?.add(o);
        }
      }
    }
  }

  Future<void> _createVoxel(Map<String,dynamic> map) async{
    threeV.createVoxelPainter();
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

  void _createCamera(Map<String,dynamic> map){
    insertCamera.insert(map['type'], threeV.aspectRatio());
    final camera = threeV.scene.children.last as Camera;
    _setTransform(camera, map['transform']);
    _setCamera(camera, map);
    if(map['mainCamera'] == true){
      threeV.changeCamera(camera);
    }
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
    threeV.updateCameraHelper(camera);
  }

  void _createEmpty(Map<String,dynamic> map){
    insertEmpty.insert(map['type'] ?? 'empty');
    final empty = threeV.scene.children.last;
    _setTransform(empty, map['transform']);
  }

  void _createLight(Map<String,dynamic> map){
    insertLight.insert(map['type']);

    final light = threeV.scene.children.last as Light;

    for(final key in map.keys){
      if(key != 'type' && map[key] != null) light[key] = map[key];
    }

    _setTransform(light, map['transform']);
    light.castShadow = map['castShadow'];
    light.userData['scripts'] = map['scripts'];
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
    insertMesh.insert(map['type']);
    final mesh = threeV.scene.children.last;
    modifyMesh(mesh, map);
  }
  Future<Mesh?> _createrMesh(Map<String,dynamic> map) async{
    final mesh = CreateMesh.create(map['type'])!;
    modifyMesh(mesh, map);
    return mesh;
  }
  void modifyMesh(Object3D mesh, Map<String,dynamic> map){
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['audio'] = map['audio'];
    mesh.userData['scripts'] = map['scripts'];
    mesh.userData['subdivisions'] = map['subdivisions'];
    mesh.userData['decimate'] = map['decimate'];
    mesh.userData['subdivisionType'] = map['subdivisionType'];
    if(map['physics'] != null) CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);

    if(map['subdivisions'] != null){
      mesh.userData['origionalGeometry'] ??= mesh.geometry?.clone();
      CreateMesh.subdivision(mesh, map['subdivisionType'] == 'simple');
    }
    else if(map['decimate'] != null){
      mesh.userData['origionalGeometry'] ??= mesh.geometry?.clone();
      CreateMesh.decimate(mesh);
    }

    mesh.userData['mainMaterial'] = MaterialLoader().parseJson(map['material']);
  }

  void _insertCollider(Map<String,dynamic> map){
    insertMesh.insert(map['type']);
    final mesh = threeV.scene.children.last;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['scripts'] = map['scripts'];
    mesh.userData['audio'] = map['audio'];
    CreateMesh.addPhysics(mesh);
    _setTransform(mesh, map['transform']);
  }
  Mesh? _createrCollider(Map<String,dynamic> map){
    final mesh = CreateMesh.create(map['type'])!;
    mesh.uuid = map['uuid'];
    mesh.name = map['name'];
    mesh.userData['scripts'] = map['scripts'];
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
    final imagePath = terrain.guiSettings['imagePath'];
    terrain.getHeightMapFromImage(imagePath);
    terrain.terrainScene?.userData['scripts'] = map['scripts'];
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
      else if(key.contains('empty')){
        _createEmpty(map);
      }
      else if(key.contains('object')){
        if(map['path'] == null){
          _createEmpty(map);
        }
        else{
          await _insertObject(map);
        }
      }
      else if(key.contains('collider')){
        _insertCollider(map);
      }
      else if(key.contains('mesh')){
        await _insertMesh(map);
      }
      else if(key.contains('camera')){
        _createCamera(map);
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

    threeV.history.clear();
  }
}