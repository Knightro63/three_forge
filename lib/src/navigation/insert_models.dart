import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class InsertModels {
  ThreeViewer threeV;

  InsertModels(this.threeV);

  Future<void> insert(String path)async{
    String name = path.split('/').last;
    String fileType = name.split('.').last;

    if(fileType == 'obj'){
      await mtl('${path.replaceAll('.obj', '.mtl')}', '${name.replaceAll('.obj', '.mtl')}');
      await obj(path,name,false);
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
    threeV.add(object.add(h));
  }
  
  Future<void> xyz(String path, String name, [bool crerateThumbnial = true]) async{
    final mesh = await three.XYZLoader().fromPath(path);
    final object = three.Mesh(mesh,three.MeshStandardMaterial.fromMap({'side': three.DoubleSide}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object.add(h));
  }

  Future<void> collada(String path, String name, [bool crerateThumbnial = true]) async{
    final mesh = await three.ColladaLoader().fromPath(path);
    final object = mesh!.scene!;
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object.add(h));
  }

  Future<void> usdz(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await three.USDZLoader().fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.scale = three.Vector3(0.01,0.01,0.01);
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object.add(h));
  }

  Future<void> fbx(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await three.FBXLoader(width: 1,height: 1).fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    final skeleton = SkeletonHelper(object)..visible = false;
    object.scale = three.Vector3(0.01,0.01,0.01);
    object.name = name.split('.').first;
    threeV.scene.userData['animationClips'][object.name] = object.animations;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object..add(h)..add(skeleton));
  }

  Future<void> gltf(String path, String name, [bool crerateThumbnial = true]) async{
    final loader = three.GLTFLoader();
    final String setPath = path.replaceAll(path.split('/').last, '');
    loader.setPath(setPath);
    final object = await loader.fromPath(path.replaceAll(setPath, ''));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!.scene);
    final skeleton = SkeletonHelper(object.scene);
    skeleton.visible = false;
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.scene.name = name.split('.').first;
    if(object.animations != null)threeV. scene.userData['animationClips'][object.scene.name] = object.animations!;
    if(crerateThumbnial) await threeV.crerateThumbnial(object.scene);
    threeV.add(object.scene..add(h)..add(skeleton));
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
    threeV.add(object.add(h));
  }

  Future<void> stl(String path, String name, [bool crerateThumbnial = true]) async{
    final object = await three.STLLoader().fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object.add(h));
  }

  Future<void> obj(String path, String name, [bool crerateThumbnial = true, three.MaterialCreator? materials]) async{
    final loader = three.OBJLoader();
    loader.setMaterials(materials);
    final object = await loader.fromPath(path);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object!);
    object.scale = three.Vector3(0.01,0.01,0.01);        
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = name.split('.').first;
    if(crerateThumbnial) await threeV.crerateThumbnial(object);
    threeV.add(object.add(h));
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
    threeV.add(object.add(h));
  }
}