import 'dart:io';
import 'dart:math' as math;
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class CreateModels {
  static Future<three.Object3D?> create(String path)async{
    String name = path.split('/').last;
    String fileType = name.split('.').last;

    if(path.contains('.folder')){
      bool exists = await File(path.replaceAll('.folder', '.obj')).exists();
      if(exists){
        exists = await File(path.replaceAll('.folder', '.obj')).exists();
        path = path.replaceAll('.folder', '.obj');
        fileType = 'obj';
      }
      else{
        exists = await File(path.replaceAll('.folder', '.gltf')).exists();
        if(exists){
          path = path.replaceAll('.folder', '.gltf');
          fileType = 'gltf';
        }
        else{
          path = path.replaceAll('.folder', '.fbx');
          fileType = 'fbx';
        }
      }
    }

    if(fileType == 'obj'){
      final mat = await mtl('${path.replaceAll('.obj', '.mtl')}', '${name.replaceAll('.obj', '.mtl')}');
      return await obj(path,name,mat);
    }
    else if(fileType == 'stl'){
      return await stl(path,name);
    }
    else if(fileType == 'ply'){
      return await ply(path,name);
    }
    else if(fileType == 'gltf' || fileType == 'glb'){
      return await gltf(path,name);
    }
    else if(fileType == 'fbx'){
      return await fbx(path,name);
    }
    else if(fileType == 'vox'){
      return await vox(path,name);
    }
    else if(fileType == 'xyz'){
      return await xyz(path,name);
    }
    else if(fileType == 'collada'){
      return await collada(path,name);
    }
    else if(fileType == 'usdz'){
      return await usdz(path,name);
    }
    else if(path.contains('.jpg') || path.contains('.png') || path.contains('.jpeg') || path.contains('.tiff') || path.contains('.bmp')){
      return await image(path, name);
    }

    return null;
  }

  static void _ifNull(three.Object3D object, ThreeViewer threeV){
    final mixer = three.AnimationMixer(object);
    object.userData['mixer'] = mixer;
    threeV.threeJs.addAnimationEvent((dt){
      mixer.update(dt);
    });
    object.userData['animationEvent'] = threeV.threeJs.events.last;
  }

  static Future<void> addFBXAnimation(three.Object3D target, String path, ThreeViewer threeV) async{
    final loader = three.FBXLoader();
    final bvh = await loader.fromPath(path);

    String name = path.split('/').last.split('.').first;
    if(target.userData['mixer'] == null){
      _ifNull(target,threeV);
    }
    if(target.userData['importedActions'] == null){
      target.userData['importedActions'] = <String,dynamic>{};
    }
    final ba = (target.userData['mixer'] as three.AnimationMixer).clipAction(bvh!.animations[0])!;

    threeV.execute(MultiCmdsCommand(threeV,[
      SetUserDataValueCommand(threeV,target,'importedActions',bvh.uuid,path),
      SetUserDataValueCommand(threeV,target,'actionMap', name, ba)..onUndoDone = (){//<String,dynamic>{name: ba}..addAll(target.userData['actionMap']??{}))..onUndoDone = (){
        target.userData['actionMap'][name]?.enabled = false;
        target.userData['actionMap'][name]?.setEffectiveWeight( 0.0 );
        target.userData['actionMap'][name]?.stop();
        LSIFunctions.removeNull(target.userData['actionMap']);
        //(target.userData['mixer'] as three.AnimationMixer).uncacheAction(bvh.animations[0]);
      }
    ]));
    
    target.userData['importedActions'][bvh.uuid] = path;
    target.userData['actionMap'][name] = ba;
    target.userData['actionMap'][name]!.enabled = true;
    target.userData['actionMap'][name]!.setEffectiveTimeScale( 1.0 );
    target.userData['actionMap'][name]!.setEffectiveWeight( 0.0 );
    target.userData['actionMap'][name]!.play();
  }

  static Future<three.Object3D> vox(String path, String name) async{
    final chunks = await three.VOXLoader().fromPath(path);
    final object = three.Group();
    for (int i = 0; i < chunks!.length; i ++ ) {
      final chunk = chunks[ i ];
      final mesh = three.VOXMesh( chunk );
      mesh.scale.setScalar( 0.015 );
      object.add( mesh );
    }
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }
  
  static Future<three.Object3D> xyz(String path, String name) async{
    final mesh = await three.XYZLoader().fromPath(path);
    final object = three.Mesh(mesh,three.MeshStandardMaterial.fromMap({'side': three.DoubleSide}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }

  static Future<three.Object3D> collada(String path, String name) async{
    final mesh = await three.ColladaLoader().fromPath(path);
    final object = mesh!.scene!;
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }

  static Future<three.Object3D> usdz(String path, String name) async{
    final object =  (await three.USDZLoader().fromPath(path))!;
    final three.BoundingBox box = three.BoundingBox();
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    object.scale = three.Vector3(0.01,0.01,0.01);
    return object..userData['path'] = path..name = name.split('.').first..boundingBox = box;
  }

  static Future<three.Object3D> fbx(String path, String name) async{
    final three.LoadingManager manager = three.LoadingManager();
    final loader = three.FBXLoader(manager:manager, width: 1,height: 1);

    final sp = path.split('/');
    final mainPath = sp.sublist(0,sp.length-2).join('/');

    String resourcePath = '$mainPath/textures/';
    bool exists = await Directory(resourcePath).exists();
    if(!exists){
      resourcePath = '$mainPath/Textures/';
      exists = await Directory(resourcePath).exists();
    }

    if(exists){
      manager.addHandler( RegExp('.tga'), three.TGALoader() );
      manager.addHandler( RegExp('.psd'), three.TGALoader() );
      loader.setResourcePath(resourcePath);
    }
    manager.urlModifier = (d){
      String changedPath = d.split('.').first+'.tga';
      return changedPath;
    };

    final object = await loader.fromPath(path);

    object!.geometry?.computeBoundingBox();
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);

    //scale to normal size
    final temp = three.Vector3().sub2(box.max,box.min);
    final max = math.max(temp.x, math.max(temp.y,temp.z));
    double scalar = 0.5;
    if(max > 100){
      scalar = 0.01;
    }
    else if(max < 1){
      scalar = 1.2;
    }
    object.scale = three.Vector3(scalar,scalar,scalar);

    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    object.traverse((child) {
      if (child is three.Mesh) {
        child.geometry?.computeVertexNormals(); // Compute normals for the mesh
      }
    });

    if(object.animations.isNotEmpty){
      object.userData['animations'] = object.animations;
      object.userData['actionMap'] = <String,dynamic>{};
      final _actionMap = object.userData['actionMap'];

      final mixer = three.AnimationMixer(object);
      object.userData['mixer'] = mixer;

      for(int a = 0; a < object.animations.length;a++){
        String actionName = object.animations[a].name;
        _actionMap[actionName] = mixer.clipAction(object.animations[a])!;
      }

      int i = 0;
      for(final act in _actionMap.keys){
        _actionMap[act]!.enabled = true;
        _actionMap[act]!.setEffectiveTimeScale( 1 );
        double weight = 0;
        if(i == 0){
          object.userData['currentAction'] = act;
          weight = 1;
        }
        _actionMap[act]!.setEffectiveWeight( weight );
        i++;
      }
    }

    object.userData['path'] = path;
    object.boundingBox = box;

    return object;
  }

  static Future<three.Object3D> gltf(String path, String name) async{
    final three.LoadingManager manager = three.LoadingManager();
    final loader = three.GLTFLoader(manager: manager);
    final String setPath = path.replaceAll(path.split('/').last, '');
    loader.setPath(setPath);
    final object = await loader.fromPath(path.replaceAll(setPath, ''));
    final gltf = object!.scene;
    gltf.geometry?.computeBoundingBox();
    final vector = three.Vector3();
    final three.BoundingBox box = three.BoundingBox().empty();
    
    gltf.traverse((child){
      child.geometry?.computeBoundingBox();
      final position = child.geometry?.attributes['position'];
      if(position!= null){
        for (int i = 0, il = position.count; i < il; i ++ ) {
          vector.fromBuffer( position, i );
          if(child is three.SkinnedMesh)child.applyBoneTransform( i, vector );
          child.localToWorld( vector );
          box.expandByPoint( vector );
        }
      }
    });

    BoundingBoxHelper h = BoundingBoxHelper(gltf.boundingBox)..visible = false;
    gltf.name = name.split('.').first;
    gltf.add(h);

    if(object.animations!.isNotEmpty){
      gltf.userData['animations'] = object.animations!;
      gltf.userData['actionMap'] = <String,dynamic>{};
      final Map<String,dynamic> _actionMap = gltf.userData['actionMap'];
      
      final mixer = three.AnimationMixer(gltf);
      gltf.userData['mixer'] = mixer;

      for(int a = 0; a < object.animations!.length;a++){
        String actionName = (object.animations![a] as three.AnimationClip).name;
        _actionMap[actionName] = mixer.clipAction(object.animations![a])!;
      }

      int i = 0;
      for(final act in _actionMap.keys){
        _actionMap[act]!.enabled = true;
        _actionMap[act]!.setEffectiveTimeScale( 1 );
        double weight = 0;
        if(i == 0){
          gltf.userData['currentAction'] = act;
          weight = 1;
        }
        _actionMap[act]!.setEffectiveWeight( weight );
        _actionMap[act]!.play();
        i++;
      }
    }
    gltf.userData['path'] = path;
    gltf.boundingBox = box;

    return gltf;
  }

  static Future<three.Object3D> ply(String path, String name) async{
    final buffer = await three.PLYLoader().fromPath(path);
    final object = three.Mesh(buffer,three.MeshStandardMaterial());
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    object.scale = three.Vector3(0.001,0.001,0.001);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }

  static Future<three.Object3D> stl(String path, String name) async{
    final object = (await three.STLLoader().fromPath(path))!;
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }

  static Future<three.Object3D> obj(String path, String name, [three.MaterialCreator? materials]) async{
    final three.LoadingManager manager = three.LoadingManager();
    final loader = three.OBJLoader(manager);
    loader.setMaterials(materials);
    final object = await loader.fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    object.scale = three.Vector3(0.01,0.01,0.01);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }

  static Future<three.MaterialCreator?> mtl(String path, String name) async{
    try{
      three.MaterialCreator? materials;
      final manager = three.LoadingManager();
      final mtlLoader = three.MTLLoader(manager);
      final last = path.split('/').last;
      mtlLoader.setPath(path.replaceAll(last,''));
      materials = await mtlLoader.fromPath(last);
      await materials?.preload();

      return materials;
    }catch(e){
      return null;
    }
  }

  static Future<three.Object3D> image(String path, String name) async{
    final geometry = three.PlaneGeometry(10, 10);
    final material = three.MeshBasicMaterial.fromMap({"side": three.DoubleSide});
    
    final loader = three.TextureLoader();
    loader.flipY = true;
    final texture = await loader.fromPath(path);

    material.map = texture;
    material.needsUpdate = true;

    final object = three.Mesh(geometry, material);

    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(object.boundingBox)..visible = false;
    object.name = name.split('.').first;
    object.add(h);
    return object..userData['path'] = path..boundingBox = box;
  }
}