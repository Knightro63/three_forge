import 'package:three_js/three_js.dart';
import 'package:three_js_helpers/three_js_helpers.dart';

class CreateCamera{
  static Camera? create(String type, double aspectRatio){
    if(type == 'Perspective'){
      return perspective(aspectRatio);
    }
    else if(type == 'Ortographic'){
      return ortographic(aspectRatio);
    }

    return null;
  }

  static PerspectiveCamera perspective(double aspectRatio){
    final camera = PerspectiveCamera(40, aspectRatio, 0.1, 10);
    camera.name = 'Perspective Camera';
    final helper = CameraHelper(camera);
    camera.userData['skeleton'] = helper;
    return camera;
  }

  static OrthographicCamera ortographic(double aspectRatio){
    final frustumSize = 5.0;
    final camera = OrthographicCamera(- frustumSize * aspectRatio, frustumSize * aspectRatio, frustumSize, - frustumSize, 0.1, 10);
    camera.name = 'Ortographic Camera';
    final helper = CameraHelper(camera);
    camera.userData['skeleton'] = helper;
    return camera;
  }
}