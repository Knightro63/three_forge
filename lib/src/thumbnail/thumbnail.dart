import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'package:image/image.dart' as img;

class Thumbnail{
  Thumbnail(this.renderer,this.scene,this.camera){
    buffer = three.Uint8Array( desiredWidth * desiredHeight * 4 );
    rt = three.WebGLRenderTarget( desiredWidth, desiredHeight, three.WebGLRenderTargetOptions({'colorSpace': three.SRGBColorSpace}) );
  }

  int desiredWidth = 1280;
  int desiredHeight = 720;

  List<FileSystemEntity> files = [];

  final three.WebGLRenderer renderer;
  final three.Scene scene;
  final three.Camera camera;

  late final three.Uint8Array buffer;
  late final three.WebGLRenderTarget rt;

  bool auto = false;

  void dispose(){
    buffer.dispose();
    rt.dispose();
  }

  Future<void> captureThumbnail(String dirPath, {String? modelPath, three.Object3D? model}) async{
    try {
      if(model == null){
        model = await loadObject(modelPath!);
      }
      else{
        positionCamera(model);
      }
      if(model == null) return;

      renderer.setRenderTarget( rt );
      renderer.render( scene, camera );
      renderer.readRenderTargetPixels(rt, 0, 0, desiredWidth, desiredHeight, buffer);
      
      img.Image image = img.Image.fromBytes(
        width: desiredWidth,
        height: desiredHeight,
        bytes: buffer.toDartList().buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgb
      );
      image = img.copyFlip(image, direction: img.FlipDirection.vertical);
      Uint8List pngBytes = img.encodePng(image);

      bool exists = await Directory(dirPath).exists();
      if(!exists) await Directory(dirPath).create(recursive: true);

      await File('$dirPath/${model.name}.png').writeAsBytes(pngBytes);
      renderer.clear();
      renderer.setClearColor(three.Color.fromHex32(0x000000), 0); 
      renderer.setRenderTarget(null);
      
      scene.children.remove(model);
    }catch (e) {
      print(e);
    }
  }

  Future<three.Object3D?> loadFileType(String path) async{
    final type = path.split('.').last;
    final sp = path.split('/');
    final resPath = '${path.replaceAll(sp.last, '')}';

    three.Object3D? object;

    final manager = three.LoadingManager();
    if(type == 'fbx'){
      final texturesLoc = '${resPath}textures/';
      manager.addHandler( RegExp('.tga'), three.TGALoader() );
      // manager.addHandler( RegExp('.psd'), three.TGALoader() );
      // manager.addHandler( RegExp('.dds'), three.DDSLoader() );

      final loader = three.FBXLoader(manager:manager, width: 1,height: 1);
      loader.setResourcePath(texturesLoc);
      object = await loader.fromPath(path);
    }
    else if(type == 'glb' || type == 'gltf'){
      final loader = three.GLTFLoader(manager:manager);
      loader.setPath(resPath);
      object = (await loader.fromPath(path))?.scene;
    }
    else if(type == 'obj'){
      final mtlLoader = three.MTLLoader(manager);
      mtlLoader.setPath(resPath);
      final materials = await mtlLoader.fromPath(path.replaceAll('.obj', '.mtl'));
      await materials?.preload();

      final loader = three.OBJLoader();
      loader.setMaterials(materials);
      object = (await loader.fromPath(path));
    }
    else if(type == 'ply'){
      final loader = three.PLYLoader();
      await loader.fromPath(path).then(( geometry ) {
        geometry?.computeVertexNormals();

        final material = three.MeshStandardMaterial.fromMap( { 'color': 0x009cff, 'flatShading': true } );
        object = three.Mesh( geometry, material );

        object!.castShadow = true;
        object!.receiveShadow = true;
      } );
    }
    else if(type == 'xyz'){
      final geometry = await three.XYZLoader().fromPath(path);
      geometry?.center();
      final vertexColors = ( geometry?.hasAttributeFromString( 'color' ) == true );
      final material = three.PointsMaterial.fromMap( { 'size': 0.1, 'vertexColors': vertexColors } );
      object = three.Points( geometry!, material );
    }
    else if(type == 'vox'){
      final loader = three.VOXLoader();
      await loader.fromPath(path).then(( chunks ) {
        if(object == null){
          object = three.Group();
        }
        for (int i = 0; i < chunks!.length; i ++ ) {
          final chunk = chunks[ i ];

          // displayPalette( chunk.palette );

          final mesh = three.VOXMesh( chunk );
          mesh.scale.setScalar( 0.0015 );
          object?.add( mesh );
        }
      });
    }
    else if(type == 'usdz'){
      object = (await three.USDZLoader().fromAsset(path));
    }
    else if(type == 'stl'){
      final loader = three.STLLoader();
      object = await loader.fromPath(path);
    }
    
    object?.name = path.split('/').last.split('.').first;
    return object;
  }

  void positionCamera(three.Object3D object){
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);

    final size = box.getSize(three.Vector3());
    final center = box.getCenter(three.Vector3());

    // Position the camera to fit the model
    final maxDim = math.max(size.x, math.max(size.y, size.z));
    final fov = camera.fov * (math.pi / 180);
    double cameraZ = (maxDim / 2 / math.tan(fov / 2)).abs();
    cameraZ *= 1.5; // Add some padding
    camera.position.setValues(center.x, center.y, center.z + cameraZ);
    camera.lookAt(center);

    scene.add(object);
  }

  Future<three.Object3D?> loadObject(String path) async{
    final object = await loadFileType(path);
    if(object == null) return null;
    object.name = path.split('/').last.split('.').first;
    positionCamera(object);
    return object;
  }
}