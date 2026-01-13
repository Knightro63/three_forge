import 'package:three_forge/src/modifers/create_camera.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class InsertCamera{
  ThreeViewer threeV;
  InsertCamera(this.threeV);

  void insert(String type, double aspectRatio){
    if(type.toLowerCase() == 'perspectivecamera'){
      perspective(aspectRatio);
    }
    else if(type.toLowerCase() == 'ortographiccamera'){
      ortographic(aspectRatio);
    }
  }

  void perspective(double aspectRatio){
    threeV.add(CreateCamera.perspective(aspectRatio));
  }
  void ortographic(double aspectRatio){
    threeV.add(CreateCamera.ortographic(aspectRatio));
  }
}