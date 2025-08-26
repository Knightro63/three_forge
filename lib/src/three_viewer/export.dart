import 'dart:io';

import 'package:three_forge/src/three_viewer/terrain.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

class ThreeForgeExport{
  Map<String,dynamic> _getTransform(Object3D object){
    return{
      'scale': {
        'x': object.scale.x,
        'y': object.scale.y,
        'z': object.scale.z,
      },
      'position':{
        'x': object.position.x,
        'y': object.position.y,
        'z': object.position.z
      },
      'rotation': _getRotation(object.rotation)
    };
  }

  Map<String,dynamic> _getRotation(Euler rotation){
    return{
      'rotation': {
        'x': rotation.x,
        'y': rotation.y,
        'z': rotation.z
      }
    };
  }

  Map<String,dynamic> _createObject(Object3D object){
    Map<String,List<String>> attachedObjects = {};
    if(object.userData['attachedObjects'] != null){
      for(final key in object.userData['attachedObjects'].keys){
        final List<String> list = [];
        for(final l in object.userData['attachedObjects'][key]){
          list.add(l.uuid);
        }
        attachedObjects[key] = list;
      }
    }
    return {
      'object_${object.uuid}': {
        'path': object.userData['path'],
        'transform': _getTransform(object),
        if(attachedObjects != {})'attachedObjects': attachedObjects,
        if(object.userData['importedActions'] != null)'importedActions': object.userData['importedActions'],
        if(object.userData['scriptPath'] != null)'script': object.userData['scriptPath'],
        if(object.userData['physics'] != null)'physics': object.userData['physics']
      }
    };
  }

  Map<String,dynamic> _createMaterial(Mesh mesh){
    return mesh.material!.toJson();
  }

  Map<String,dynamic> _createCamera(Camera camera){
    return {
      'camera_${camera.uuid}': {
        'type': camera.runtimeType.toString(),
        'near': camera.near,
        'far': camera.far,
        'zoom': camera.zoom,
        'aspect': camera.aspect,
        'fov': camera.fov,
        'left': camera.left,
        'top': camera.top,
        'right': camera.right,
        'bottom': camera.bottom,
        'transform': _getTransform(camera)
      },
    };
  }

  Map<String,dynamic> _createLight(Light light){
    return {
      'light_${light.uuid}': {
        'type': light.runtimeType.toString(),
        'color': light.color?.getHex(),
        'intensity': light.intensity,
        'groundColor': light.groundColor?.getHex(),
        'distance': light.distance,
        'decay': light.decay,
        'width': light.width,
        'height': light.height,
        'angle': light.angle,
        'penumbra': light.penumbra,
        'transform': _getTransform(light),
        'castShadow': light.castShadow,
        if(light.castShadow && light.shadow?.camera != null) 'camera': _createCamera(light.shadow!.camera!),
        if(light.castShadow && light.shadow?.camera != null) 'map':{
          'width': light.shadow?.map?.width,
          'height': light.shadow?.map?.height,
        },
        if(light.castShadow && light.shadow?.camera != null)'shadow':{
          'bias': light.shadow?.bias,
          'radius': light.shadow?.radius,
        },
        if(light.userData['scriptPath'] != null)'script': light.userData['scriptPath'],
      },
    };
  }

  Map<String,dynamic> _createMesh(Mesh mesh){
    return {
      'mesh_${mesh.uuid}': {
        'subdivisions': mesh.userData['subdivisions'],
        'decimate': mesh.userData['decimate'],
        'subdivisionType': mesh.userData['subdivisionType'],
        'material': _createMaterial(mesh),
        'transform': _getTransform(mesh),
        if(mesh.userData['scriptPath'] != null)'script': mesh.userData['scriptPath'],
        if(mesh.userData['physics'] != null)'physics': mesh.userData['physics']
      }
    };
  }
  Map<String,dynamic> _createCollider(Mesh mesh){
    return {
      'collider_${mesh.uuid}': {
        'transform': _getTransform(mesh),
        'physics': mesh.userData['physics']
      }
    };
  }
  Map<String,dynamic> _createScene(ThreeViewer viewer){
    final Scene scene = viewer.scene;
    return {
      'scene': {
        'name': scene.name,
        'uuid': scene.uuid,
        'backgroundType': scene.background.runtimeType.toString(),
        'background': {
          'texture': scene.background is Texture?{
            'path': scene.background?.userData['path'],
            'type': scene.background.runtimeType.toString(),
            'mapping': (scene.background as Texture?)?.mapping
          }:null,
          'color': scene.background is Color?(scene.background as Color).getHex():null,
        },
        'backgroundTexture': scene.background is Color?null:scene.background?.userData['path'],
        'sameastext': scene.environment == scene.background,
        'environment': {
          'path': scene.environment?.userData['path'],
          'type': scene.environment?.runtimeType.toString(),
          'mapping': scene.environment?.mapping
        },
        'backgroundIntensity': scene.backgroundIntensity,
        'environmentIntensity': scene.environmentIntensity,
        'backgroundRotation': _getRotation(scene.backgroundRotation),
        'environmentRotation': _getRotation(scene.environmentRotation),
        if(scene.fog != null)'fog': {
          'color': scene.fog?.color.getHex(),
          'near': scene.fog?.near,
          'far': scene.fog?.far,
        }
      },
      'settings':{
        'camera': _getTransform(viewer.camera),
        'grid': viewer.gridInfo.toJson(),
        'shading': viewer.shading.index,
        'controlSpace': viewer.controlSpace.index,
      }
    };
  }

  Future<Map<String,dynamic>> _createTerrain(Terrain terrain, ThreeViewer viewer) async{
    String path ='${viewer.dirPath}/assets/terrain/';
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);
    final name = 'terrain_${terrain.terrainScene?.uuid}';
    final file = await File('$path/$name.bmp').writeAsBytes(terrain.heightmap);
    terrain.guiSettings['imagePath'] = file.path;
    return {
      name: terrain.guiSettings,
      if(terrain.terrainScene?.userData['scriptPath'] != null)'script': terrain.terrainScene?.userData['scriptPath'],
    };
  }

  Future<Map<String,dynamic>> export(ThreeViewer viewer)async{
    Map<String,dynamic> scene = _createScene(viewer);

    for(final t in viewer.terrains){
      scene.addAll(await _createTerrain(t,viewer));
    }

    for(final o in viewer.scene.children){
      if(o is Camera){
        scene.addAll(_createCamera(o));
      }
      else if(o is Light){
        scene.addAll(_createLight(o));
      }
      else if(o is Mesh && o.userData['path'] == null){
        if(o.name.contains('Collider-')){
          scene.addAll(_createCollider(o));
        }
        else{
          scene.addAll(_createMesh(o));
        }
      }
      else if(o.userData['terrain_id'] == null){
        scene.addAll(_createObject(o));
      }
    }

    return scene;
  }
}