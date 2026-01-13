import 'package:three_forge/src/helpers/empty_helper.dart';
import 'package:three_js/three_js.dart';

class CreateEmpty{

  static Object3D? create(String type){
    if(type == 'Empty'){
      return empty();
    }
    else if(type == 'Empty Parent'){
      return emptyParent();
    }

    return null;
  }

  static Object3D empty(){
    final object = Object3D();
    final helper = EmptyHelper(object,0.5,Color.fromHex32(0xff0000));
    object.name = 'Empty';
    object.userData['empty'] = true;
    object.userData['type'] = 'empty';
    object.userData['skeleton'] = helper;
    return object;
  }

  static Group emptyParent(){
    final object = Group();
    final helper = EmptyHelper(object,0.5,Color.fromHex32(0xff0000));
    object.name = 'Empty Parent';
    object.userData['empty'] = true;
    object.userData['type'] = 'empty_parent';
    object.userData['skeleton'] = helper;
    return object;
  }
}