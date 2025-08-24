import 'dart:io';
import 'dart:math' as math;
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class InsertModels {
  ThreeViewer threeV;

  InsertModels(this.threeV);

  Future<void> insert(String path)async{
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
      await obj(path,name,false,mat);
    }
    else if(fileType == 'stl'){
      await stl(path,name,false);
    }
    else if(fileType == 'ply'){
      await ply(path,name,false);
    }
    else if(fileType == 'gltf' || fileType == 'glb'){
      await gltf(path,name,false);
    }
    else if(fileType == 'fbx'){
      await fbx(path,name,false);
    }
    else if(fileType == 'vox'){
      await vox(path,name,false);
    }
    else if(fileType == 'xyz'){
      await xyz(path,name,false);
    }
    else if(fileType == 'collada'){
      await collada(path,name,false);
    }
    else if(fileType == 'usdz'){
      await usdz(path,name,false);
    }
    else if(path.contains('.jpg') || path.contains('.png') || path.contains('.jpeg') || path.contains('.tiff') || path.contains('.bmp')){
      await image(path, name);
    }
  }

  Future<void> vox(String path, String name, [bool crerateThumbnial = true]) async{
    final chunks = await three.VOXLoader().fromPath(path);
    final object = three.Group();
    for (int i = 0; i < chunks!.length; i ++ ) {
      final chunk = chunks[ i ];
      final mesh = three.VOXMesh( chunk );
      mesh.scale.setScalar( 0.0015 );
      object.add( mesh );
    }
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }
  
  Future<void> xyz(String path, String name, [bool crerateThumbnial = true]) async{
    final mesh = await three.XYZLoader().fromPath(path);
    final object = three.Mesh(mesh,three.MeshStandardMaterial.fromMap({'side': three.DoubleSide}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<void> collada(String path, String name, [bool crerateThumbnial = true]) async{
    final mesh = await three.ColladaLoader().fromPath(path);
    final object = mesh!.scene!;
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<void> usdz(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await three.USDZLoader().fromPath(path);
    object!.geometry?.computeBoundingBox();
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.scale = three.Vector3(0.01,0.01,0.01);
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<void> fbx(String path, String name, [bool crerateThumbnial = true, bool moveFiles = false]) async{
    final List<String> paths = [];
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
      paths.add('$resourcePath/$changedPath');
      return changedPath;
    };
    final object = await loader.fromPath(path);
    object!.geometry?.computeBoundingBox();
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    final skeleton = SkeletonHelper(object)..visible = false;

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

    object.name = name.split('.').first;
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
      threeV.threeJs.addAnimationEvent((dt){
        mixer.update(dt);
      });
      object.userData['animationEvent'] = threeV.threeJs.events.last;

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
        _actionMap[act]!.play();
        i++;
      }
    }

    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    object.userData['skeleton'] = skeleton;
    threeV.add(object,h);
    threeV.threeJs.scene.add(skeleton);
    object.userData['path'] = path;

   if(moveFiles && paths.isNotEmpty){
      await threeV.moveTextures(paths);
    }
  }

  Future<bool> gltf(String path, String name, [bool crerateThumbnial = true, bool moveFiles = false]) async{
    final List<String> paths = [path];
    final three.LoadingManager manager = three.LoadingManager();
    manager.urlModifier = (d){
      paths.add(d);
      return d;
    };
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

    final skeleton = SkeletonHelper(gltf);
    skeleton.visible = false;
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    gltf.name = name.split('.').first;

    if(object.animations!.isNotEmpty){
      gltf.userData['animations'] = object.animations!;
      gltf.userData['actionMap'] = <String,dynamic>{};
      final Map<String,dynamic> _actionMap = gltf.userData['actionMap'];
      
      final mixer = three.AnimationMixer(gltf);
      gltf.userData['mixer'] = mixer;
      threeV.threeJs.addAnimationEvent((dt){
        mixer.update(dt);
      });
      gltf.userData['animationEvent'] = threeV.threeJs.events.last;

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

    if(crerateThumbnial) await threeV.crerateThumbnial(gltf, box);
    gltf.userData['skeleton'] = skeleton;
    threeV.add(gltf,h);
    threeV.threeJs.scene.add(skeleton);
    object.userData?['path'] = path;

    if(moveFiles && paths.length > 1){
      await threeV.moveFiles(name,paths);
      return true;
    }
    
    return false;
  }

  Future<void> ply(String path, String name, [bool crerateThumbnial = true]) async{
    final buffer = await three.PLYLoader().fromPath(path);
    final object = three.Mesh(buffer,three.MeshStandardMaterial());
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    object.scale = three.Vector3(0.01,0.01,0.01);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<void> stl(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await three.STLLoader().fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<void> obj(String path, String name, [bool crerateThumbnial = true, three.MaterialCreator? materials]) async{
    final three.LoadingManager manager = three.LoadingManager();
    final loader = three.OBJLoader(manager);
    loader.setMaterials(materials);
    final object = await loader.fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    object.scale = three.Vector3(0.01,0.01,0.01);        
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object,h);
    object.userData['path'] = path;
  }

  Future<three.MaterialCreator?> mtl(String path, String name) async{
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

  Future<void> image(String path, String name) async{
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
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    threeV.add(object,h);
    object.userData['path'] = path;
  }
}