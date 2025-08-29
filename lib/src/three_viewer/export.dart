import 'dart:io';

import 'package:three_forge/src/three_viewer/src/terrain.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';
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
      'x': rotation.x,
      'y': rotation.y,
      'z': rotation.z
    };
  }

  Map<String,dynamic> _createObject(Object3D object){
    Map<String,List<Map<String,dynamic>>> attachedObjects = {};
    if(object.userData['attachedObjects'] != null){
      for(final key in object.userData['attachedObjects'].keys){
        final List<Map<String,dynamic>> list = [];
        for(final o in object.userData['attachedObjects'][key]){
          if(o is Mesh && o.userData['path'] == null){
            if(o.name.contains('Collider-')){
              list.add(_createCollider(o));
            }
            else{
              list.add(_createMesh(o));
            }
          }
          else{
            list.add(_createObject(o));
          }

          list.last['parent'] = o.parent.name;
        }
        attachedObjects[key] = list;
      }
    }
    return {
      'object_${object.uuid}': {
        'path': object.userData['path'],
        'transform': _getTransform(object),
        'uuid': object.uuid,
        'name': object.name,
        if(attachedObjects != {})'attachedObjects': attachedObjects,
        if(object.userData['importedActions'] != null)'importedActions': object.userData['importedActions'],
        if(object.userData['scriptPath'] != null)'script': object.userData['scriptPath'],
        if(object.userData['physics'] != null)'physics': object.userData['physics'],
        if(object.userData['audio'] != null)'audio': object.userData['audio'],
      }
    };
  }

  Map<String,dynamic> _voxel(VoxelPainter voxel){
    Map<String,dynamic> children = {};

    int i = 0;
    for(final child in voxel.children){
      if(i != 0){
        children[child.uuid] = _getTransform(child);
      }
      i++;
    }

    return {
      'voxel_${voxel.uuid}': {
        'path': voxel.object?.userData['path'],
        'transform': _getTransform(voxel),
        'children': children,
        'object': voxel.object?.userData['path'],
        'uuid': voxel.uuid,
        'name': voxel.name,
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
        'transform': _getTransform(camera),
        'uuid': camera.uuid,
        'name': camera.name,
        if(camera.userData['mainCamera'] != null)'mainCamera': camera.userData['mainCamera']
      },
    };
  }

  Map<String,dynamic> _createLight(Light light){
    return {
      'light_${light.uuid}': {
        'uuid': light.uuid,
        'name': light.name,
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
        'type': mesh.userData['meshType'],
        'uuid': mesh.uuid,
        'name': mesh.name,
        'subdivisions': mesh.userData['subdivisions'],
        'decimate': mesh.userData['decimate'],
        'subdivisionType': mesh.userData['subdivisionType'],
        'material': _createMaterial(mesh),
        'transform': _getTransform(mesh),
        if(mesh.userData['audio'] != null)'audio': mesh.userData['audio'],
        if(mesh.userData['scriptPath'] != null)'script': mesh.userData['scriptPath'],
        if(mesh.userData['physics'] != null)'physics': mesh.userData['physics']
      }
    };
  }
  Map<String,dynamic> _createCollider(Mesh mesh){
    return {
      'collider_${mesh.uuid}': {
        'type': mesh.userData['meshType'],
        'uuid': mesh.uuid,
        'name': mesh.name,
        'transform': _getTransform(mesh),
        'physics': mesh.userData['physics'],
        if(mesh.userData['audio'] != null)'audio': mesh.userData['audio'],
      }
    };
  }
  Map<String,dynamic> _createScene(ThreeViewer viewer){
    final Scene scene = viewer.scene;
    return {
      'scene': {
        'name': scene.name,
        'uuid': scene.uuid,
        if(scene.userData['audio'] != null)'audio': scene.userData['audio'],
        'backgroundType': scene.background.runtimeType.toString(),
        'background': {
          'texture': scene.background is Texture?{
            'path': scene.background?.userData['path'],
            'type': scene.background.runtimeType.toString(),
            'mapping': (scene.background as Texture?)?.mapping
          }:null,
          'color': scene.background is Color?(scene.background as Color).getHex():null,
        },
        'sameastext': scene.environment == scene.background,
        if(scene.environment != null)'environment': {
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
    String path ='${viewer.dirPath}/assets/terrain';
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);
    final name = 'terrain_${terrain.terrainScene?.uuid}';
    final file = await File('$path/$name.bmp').writeAsBytes(terrain.heightMapImage!);
    terrain.guiSettings['imagePath'] = file.path;
    return {
      name: {
        'settings': terrain.guiSettings,
        if(terrain.terrainScene?.userData['scriptPath'] != null)'script': terrain.terrainScene?.userData['scriptPath'],
      }
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
      else if(o is VoxelPainter){
        scene.addAll(_voxel(o));
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