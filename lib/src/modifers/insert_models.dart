import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/modifers/create_models.dart';
import 'package:three_forge/src/three_viewer/import.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class InsertModels {
  ThreeViewer threeV;
  late final ThreeForgeImport import = ThreeForgeImport(threeV);

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
    
    if(fileType == 'json'){
      File file = File(path);
      final json = jsonDecode(await file.readAsString());
      final sceneName = file.path.split('/').last.replaceAll('.json', '');//value.files.first.name.replaceAll('.json', '');
      threeV.reset(sceneName);
      import.import(json);
    }
    if(fileType == 'obj'){
      final mat = await CreateModels.mtl('${path.replaceAll('.obj', '.mtl')}', '${name.replaceAll('.obj', '.mtl')}');
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
    final object = await CreateModels.vox(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }
  
  Future<void> xyz(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await CreateModels.xyz(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }

  Future<void> collada(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await CreateModels.collada(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }

  Future<void> usdz(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await CreateModels.usdz(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
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
    object.add(h);
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

    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['skeleton'] = skeleton;
    threeV.add(object);
    object.userData['path'] = path;

   if(moveFiles && paths.isNotEmpty){
      await threeV.fileSort.moveTextures(paths);
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
    gltf.add(h);

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

    if(crerateThumbnial) await threeV.crerateThumbnialSave(gltf, box);
    gltf.userData['skeleton'] = skeleton;
    threeV.add(gltf);
    gltf.userData['path'] = path;

    if(moveFiles && paths.length > 1){
      await threeV.fileSort.moveFiles(name,paths);
      return true;
    }
    
    return false;
  }

  Future<void> ply(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await CreateModels.ply(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }

  Future<void> stl(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await CreateModels.stl(path, name);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }

  Future<void> obj(String path, String name, [bool crerateThumbnial = true, three.MaterialCreator? materials]) async{
    final object = await CreateModels.obj(path, name, materials);
    if(crerateThumbnial) await threeV.crerateThumbnialSave(object);
    object.userData['path'] = path;
    threeV.add(object);
  }

  Future<void> image(String path, String name) async{
    final object = await CreateModels.image(path, name);
    object.userData['path'] = path;
    threeV.add(object);
  }

  void setAsSame(bool sameastext){
    threeV.threeJs.scene.userData['sameTexture'] = sameastext;
    if(sameastext){
      threeV.execute(
        MultiCmdsCommand(threeV,[
          SetValueCommand(threeV, threeV.scene, 'environment', threeV.threeJs.scene.background)..allowDispatch=false,
          SetValueCommand(threeV, threeV.threeJs.scene, 'environment', threeV.threeJs.scene.background)..allowDispatch=false,
        ])
      );
      threeV.threeJs.scene.environment = threeV.threeJs.scene.background;
      threeV.scene.environment = threeV.threeJs.scene.background;
    }
    else{
      threeV.execute(
        MultiCmdsCommand(threeV,[
          SetValueCommand(threeV, threeV.scene, 'environment', null)..allowDispatch=false,
          SetValueCommand(threeV, threeV.threeJs.scene, 'environment', null)..allowDispatch=false,
        ])
      );
      threeV.threeJs.scene.environment = null;
      threeV.scene.environment = null;
    }
  }

  Future<void> insertTexture(String path, int mappingValue, bool sameastext) async{
    String fileType = path.split('.').last;
    String name = path.split('/').last;
    String dirPath = path.replaceAll(name, '');

    if(fileType == 'hdr'){
      final three.DataTexture rgbeLoader = await three.RGBELoader().setPath( dirPath ).fromAsset(name);
      rgbeLoader.userData['path'] = path;
      rgbeLoader.mapping = mappingValue;
      threeV.execute(
        MultiCmdsCommand(threeV,[
          SetValueCommand(threeV, threeV.scene, 'background', rgbeLoader)..allowDispatch=false,
          SetValueCommand(threeV, threeV.threeJs.scene, 'background', rgbeLoader)..allowDispatch=false,
          SetValueCommand(threeV, threeV.scene, 'backgroundRotation', three.Euler(math.pi))..allowDispatch=false,
          SetValueCommand(threeV, threeV.threeJs.scene, 'backgroundRotation', three.Euler(math.pi))
        ])
      );
      threeV.threeJs.scene.background = rgbeLoader;
      threeV.scene.background = rgbeLoader;
      threeV.threeJs.scene.backgroundRotation = three.Euler(math.pi);
      threeV.scene.backgroundRotation = three.Euler(math.pi);
      setAsSame(sameastext);
    }
    else if(fileType == 'folder'){
      final cubeRenderTarget = three.WebGLCubeRenderTarget( 256 );
      final cubeCamera = three.CubeCamera( 1, 1000, cubeRenderTarget );

      // envmap
      List<String> genCubeUrls( prefix, postfix ) {
        return [
          prefix + 'px' + postfix, prefix + 'nx' + postfix,
          '${prefix}ny$postfix', '${prefix}py$postfix',
          prefix + 'pz' + postfix, prefix + 'nz' + postfix
        ];
      }

      final urls = genCubeUrls( dirPath, '.jpg' );

      three.CubeTextureLoader(flipY: true).fromAssetList(urls).then(( cubeTexture ) {
        threeV.execute(
          MultiCmdsCommand(threeV,[
            SetValueCommand(threeV, threeV.scene, 'background', cubeTexture)..allowDispatch=false,
            SetValueCommand(threeV, threeV.threeJs.scene, 'background', cubeTexture)..allowDispatch=false,
          ])
        );
        threeV.threeJs.scene.background = cubeTexture;
        threeV.scene.background = cubeTexture;
        cubeTexture?.userData['path'] = path;
        setAsSame(sameastext);
        cubeCamera.update( threeV.threeJs.renderer!, threeV.threeJs.scene );
      });
    }
  }
}