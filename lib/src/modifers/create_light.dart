import 'package:three_js/three_js.dart';
import 'package:three_js_helpers/three_js_helpers.dart';
import 'dart:math' as math;

class CreateLight{

  static Light? create(String type){
    if(type == 'AmbientLight'){
      return ambientLight();
    }
    else if(type == 'SpotLight'){
      return spotLight();
    }
    else if(type == 'DirectionalLight'){
      return directionalLight();
    }
    else if(type == 'PointLight'){
      return pointLight();
    }
    else if(type == 'RectAreaLight'){
      return rectAreaLight();
    }
    else if(type == 'HemisphereLight'){
      return hemisphereLight();
    }

    return null;
  }

  // static Light? createFromMap(Map<String,dynamic> map){
  //   late final Light light;

  //   if(map['type'] == 'AmbientLight'){
  //     light = AmbientLight(map['color'],map['intensity']);
  //   }
  //   else if(map['type'] == 'SpotLight'){
  //     light = SpotLight(map['color'],map['intensity'],map['distance'],map['angle'],map['penumbra'],map['decay']);
  //   }
  //   else if(map['type'] == 'DirectionalLight'){
  //     light = DirectionalLight(map['color'],map['intensity']);
  //   }
  //   else if(map['type'] == 'PointLight'){
  //     light = PointLight(map['color'],map['intensity'],map['distance'],map['decay']);
  //   }
  //   else if(map['type'] == 'RectAreaLight'){
  //     light = RectAreaLight(map['color'],map['intensity'],map['width'],map['height']);
  //   }
  //   else if(map['type'] == 'HemisphereLight'){
  //     light = HemisphereLight(map['color'],map['groundColor'],map['intensity']);
  //   }

  //   return light;
  // }

  static AmbientLight ambientLight(){
    final object = AmbientLight(0xffffff);
    final helper = HemisphereLightHelper(object,1,Color.fromHex32(0xffff00));
    object.userData['skeleton'] = helper;
    object.name = 'Ambient Light';
    return object;
  }

  static SpotLight spotLight(){
    final light = SpotLight(0xffffff,100,2,math.pi / 6, 1, 2);
    light.name = 'Spot Light';
    final helper = SpotLightHelper(light,0xffff00);
    light.userData['skeleton'] = helper;
    return light;
  }

  static DirectionalLight directionalLight(){
    final light = DirectionalLight(0xffffff,1.0);
    light.name = 'Directional Light';
    final helper = DirectionalLightHelper(light,1,Color.fromHex32(0xffff00));
    light.userData['skeleton'] = helper;
    return light;
  }

  static PointLight pointLight(){
    final light = PointLight(0xffffff,10);
    final helper = PointLightHelper(light,1,0xffff00);
    light.name = 'Point Light';
    light.userData['skeleton'] = helper;
    return light;
  }

  static HemisphereLight hemisphereLight(){
    final light = HemisphereLight(0xffffff,0x444444);
    final helper = HemisphereLightHelper(light,1,Color.fromHex32(0xffff00));
    light.name = 'Hemisphere Light';
    light.userData['skeleton'] = helper;
    return light;
  }

  static RectAreaLight rectAreaLight(){
    final light = RectAreaLight(0xffffff,0x444444);
    final helper = RectAreaLightHelper(light,Color.fromHex32(0xffff00));
    light.name = 'Rect Area Light';
    light.userData['skeleton'] = helper;
    return light;
  }
}