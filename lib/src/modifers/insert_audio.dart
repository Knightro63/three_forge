import 'package:three_forge/src/modifers/create_audio.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

class InsertAudio{
  ThreeViewer threeV;
  InsertAudio(this.threeV);

  void insert(String type, String path,[Object3D? listener]){
    if(type.toLowerCase() == 'positionalaudio'){
      if(listener != null)positional(path,listener);
    }
    else if(type.toLowerCase() == 'audio'){
      surround(path);
    }
  }

  void positional(String path,Object3D listener){
    threeV.add(CreateAudio.positional(path,listener));
  }
  void surround(String path){
    threeV.add(CreateAudio.surround(path));
  }
}