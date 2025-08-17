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
    return {
      'object_${object.uuid}': {
        'path': object.userData['path'],
        'transform': _getTransform(object)
      }
    };
  }

  Map<String,dynamic> _createMaterial(Mesh mesh){
    return {

    };
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
        'transform': _getTransform(light)
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
        'transform': _getTransform(mesh)
      }
    };
  }

  Map<String,dynamic> _createScene(Scene scene){
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
      }
    };
  }

  Map<String,dynamic> _createTerrain(Terrain terrain){
    return {
      'terrain_${terrain.terrainScene?.uuid}': terrain.guiSettings
    };
  }

  Map<String,dynamic> export(ThreeViewer viewer){
    Map<String,dynamic> scene = _createScene(viewer.scene);

    for(final t in viewer.terrains){
      scene.addAll(_createTerrain(t));
    }

    for(final o in viewer.scene.children){
      if(o is Camera){
        scene.addAll(_createCamera(o));
      }
      else if(o is Light){
        scene.addAll(_createLight(o));
      }
      else if(o is Mesh && o.userData['path'] != null){
        scene.addAll(_createMesh(o));
      }
      else if(!o.name.contains('terrain_')){
        scene.addAll(_createObject(o));
      }
    }

    return scene;
  }
}