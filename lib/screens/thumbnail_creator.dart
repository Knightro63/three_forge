import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:image/image.dart' as img;

class ThumbnailCreator extends StatefulWidget {
  const ThumbnailCreator({Key? key}):super(key: key);

  @override
  _ThumbnailCreatorState createState() => _ThumbnailCreatorState();
}

class _ThumbnailCreatorState extends State<ThumbnailCreator> {
  bool creating = false;
  List<FileSystemEntity> file = [];
  late three.ThreeJS threeJs;
  late final three.Uint8Array buffer;
  late final three.WebGLRenderTarget rt;

  @override
  void initState(){
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});},
      setup: setup,
      settings: three.Settings(
        alpha: true,
      )
    );
    super.initState();
  }
  @override
  void dispose(){
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  Future<String?> getPath() async{
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Loaction');
    if(path!=null) file = Directory(path).listSync();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    double aspect = 720/1280;
    return Scaffold(
      body: SizedBox(
        width: 260,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20,),
            SizedBox(
              width: 240,
              height: 240*aspect,
              child: threeJs.build(),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){
                creating = true;
                getPath().then((p) async{
                  for(final f in file){
                    if(f.path.split('.').last == 'fbx'){
                      await captureThumbnail(f);
                    }
                  }
                  setState(() {
                    creating = false;
                  });
                });
                setState(() {
                  
                });
              },
              child: Container(
                width: 240,
                height: 30,
                decoration: BoxDecoration(
                  color:  Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: creating?Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    SizedBox(width: 30, child:CircularProgressIndicator(color: Colors.white,))
                  ]):Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,size:20),
                    Text(
                      'Capture',
                      style: Theme.of(context).primaryTextTheme.bodyMedium,
                    )
                  ],
                ),
              ),
            )
          ]
        )
      )
    );
  }

  int desiredWidth = 1280;
  int desiredHeight = 720;
  late three.OrbitControls controls;

  Future<void> setup() async {
    buffer = three.Uint8Array( desiredWidth * desiredHeight * 4 );
    rt = three.WebGLRenderTarget( desiredWidth, desiredHeight, three.WebGLRenderTargetOptions({'colorSpace': three.SRGBColorSpace}) );

    threeJs.scene = three.Scene();

    threeJs.camera = three.PerspectiveCamera(45, threeJs.width / threeJs.height, 0.1, 1000);
    threeJs.camera.position.setValues( - 0, 0, 2.7 );
    threeJs.camera.lookAt(threeJs.scene.position);
    
    threeJs.scene.add( three.AmbientLight( 0xffffff ) );

    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);

    threeJs.addAnimationEvent((dt){
      controls.update();
    });
  }

  Future<void> captureThumbnail(FileSystemEntity value) async{
    three.Object3D? model;
    try {
      model = await loadFbx(value);

      threeJs.renderer?.setRenderTarget( rt );
      threeJs.renderer?.render( threeJs.scene, threeJs.camera );
      threeJs.renderer?.readRenderTargetPixels(rt, 0, 0, desiredWidth, desiredHeight, buffer);
      
      img.Image image = img.Image.fromBytes(
        width: desiredWidth,
        height: desiredHeight,
        bytes: buffer.toDartList().buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgb
      );
      image = img.copyFlip(image, direction: img.FlipDirection.vertical);
      Uint8List pngBytes = img.encodePng(image);
        
      final p = value.path;
      final sp = value.path.split('/');
      final path = '${p.replaceAll(sp.last, '').replaceAll('/models', '')}thumbnails/';

      bool exists = await Directory(path).exists();
      if(!exists) await Directory(path).create();

      await File('$path${model.name}.png').writeAsBytes(pngBytes);      
      threeJs.renderer?.setRenderTarget(null);
    }catch (e) {
      print(e);
    }

    if(threeJs.scene.children.isNotEmpty){
      // model?.traverse((object){
      //   object.geometry?.dispose();
      //   if (object.material != null) {
      //     if (object.material is three.GroupMaterial) {
      //       (object.material as three.GroupMaterial).children.forEach((mat) => mat.dispose());
      //     } 
      //     else {
      //       object.material?.dispose();
      //     }
      //   }
      // });
      // model?.dispose();
      if(model != null) threeJs.scene.remove(model);
    }
  }

  Future<three.Object3D> loadFbx(FileSystemEntity value) async{
    final p = value.path;
    final sp = value.path.split('/');
    final path = '${p.replaceAll(sp.last, '').replaceAll('/models', '')}textures/';

    final manager = three.LoadingManager();
    manager.addHandler( RegExp('.tga'), three.TGALoader() );
    manager.addHandler( RegExp('.psd'), three.TGALoader() );
    manager.addHandler( RegExp('.dds'), three.DDSLoader() );

    final loader = three.FBXLoader(manager:manager, width: 1,height: 1).setResourcePath(path);
    final three.AnimationObject object = await loader.fromPath(p);
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);

    final size = box.getSize(three.Vector3());
    final center = box.getCenter(three.Vector3());

    object.name = value.path.split('/').last.split('.').first;
    threeJs.scene.add(object);

    // Position the camera to fit the model
    final maxDim = math.max(size.x, math.max(size.y, size.z));
    final fov = threeJs.camera.fov * (math.pi / 180);
    double cameraZ = (maxDim / 2 / math.tan(fov / 2)).abs();
    cameraZ *= 1.5; // Add some padding
    threeJs.camera.position.setValues(center.x, center.y, center.z + cameraZ);
    threeJs.camera.lookAt(center);

    threeJs.render();

    return object;
  }
}