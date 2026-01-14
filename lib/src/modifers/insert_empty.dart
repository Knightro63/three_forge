import 'package:three_forge/src/modifers/create_empty.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class InsertEmpty{
  ThreeViewer threeV;
  InsertEmpty(this.threeV);

  void insert(String type){
    if(type == 'empty'){
      empty();
    }
    else if(type == 'empty_parent'){
      emptyParent();
    }
  }

  void empty(){
    threeV.add(CreateEmpty.empty());
  }
  void emptyParent(){
    threeV.add(CreateEmpty.emptyParent());
  }
}