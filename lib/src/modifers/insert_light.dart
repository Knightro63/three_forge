import 'package:three_forge/src/modifers/create_light.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class InsertLight{
  ThreeViewer threeV;
  InsertLight(this.threeV);

  void insert(String type){
    if(type == 'AmbientLight'){
      ambientLight();
    }
    else if(type == 'SpotLight'){
      spotLight();
    }
    else if(type == 'DirectionalLight'){
      directionalLight();
    }
    else if(type == 'PointLight'){
      pointLight();
    }
    else if(type == 'RectAreaLight'){
      rectAreaLight();
    }
    else if(type == 'HemisphereLight'){
      hemisphereLight();
    }
  }

  void ambientLight(){
    threeV.add(CreateLight.ambientLight());
  }
  void spotLight(){
    threeV.add(CreateLight.spotLight());
  }
  void directionalLight(){
    threeV.add(CreateLight.directionalLight());
  }
  void pointLight(){
    threeV.add(CreateLight.pointLight());
  }
  void rectAreaLight(){
    threeV.add(CreateLight.rectAreaLight());
  }
  void hemisphereLight(){
    threeV.add(CreateLight.hemisphereLight());
  }
}