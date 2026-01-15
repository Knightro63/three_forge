import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/thumbnail/thumbnail.dart';
import 'package:three_js/three_js.dart' as three;

class ThumbnailCreator extends StatefulWidget {
  const ThumbnailCreator({Key? key, this.path, this.object}):super(key: key);
  final three.Object3D? object;
  final String? path;

  @override
  _ThumbnailCreatorState createState() => _ThumbnailCreatorState();
}

class _ThumbnailCreatorState extends State<ThumbnailCreator> {
  bool creating = false;
  List<FileSystemEntity> file = [];
  late final three.ThreeJS threeJs;
  late final Thumbnail thumbnail;
  final TextEditingController thumbnailLocationController = TextEditingController();
  final TextEditingController objectLocationController = TextEditingController();
  bool auto = false;

  @override
  void initState(){
    auto = widget.object != null && widget.path != null;
    threeJs = three.ThreeJS(
      onSetupComplete: (){
        setState(() {});
        thumbnail = Thumbnail(threeJs.renderer!, threeJs.scene, threeJs.camera);
        if(auto){
          thumbnail.captureThumbnailSave(widget.path!, model: widget.object);
        }
      },
      setup: setup,
      settings: three.Settings(
        alpha: true,
        clearAlpha: 0.0,
      )
    );
    super.initState();
  }
  @override
  void dispose(){
    three.loading.clear();
    thumbnail.dispose();
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
            SizedBox(
              width: 240,
              height: 240*aspect,
              child: threeJs.build(),
            ),
            InkWell(
              onTap: (){
                getPath().then((path){
                  objectLocationController.text = path ?? '';
                  if(path != null){
                    final sp = path.split('/');
                    final tpath = '${path.replaceAll(sp.last, '')}thumbnails';
                    thumbnailLocationController.text = tpath;
                  }
                  setState((){});
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 240-30,
                    height: 30,
                    alignment: Alignment.center,
                    child: TextField(
                      readOnly: true,
                      autofocus: false,
                      controller: objectLocationController,
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        contentPadding: EdgeInsets.fromLTRB(2,10,0,10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5)
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).hintColor,
                            width: 1,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                    width: 30,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5)
                      ),
                      border: Border.all(
                        color: Theme.of(context).hintColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.folder_open_rounded,size: 20,)
                  ),
                ],
              )
            ),
            InkWell(
              onTap: (){
                getPath().then((path){
                  thumbnailLocationController.text = path ?? '';
                  setState((){});
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 240-30,
                    height: 30,
                    alignment: Alignment.center,
                    child: TextField(
                      readOnly: true,
                      autofocus: false,
                      controller: thumbnailLocationController,
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Theme.of(context).splashColor,
                        contentPadding: EdgeInsets.fromLTRB(2,10,0,10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5)
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).hintColor,
                            width: 1,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                    width: 30,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5)
                      ),
                      border: Border.all(
                        color: Theme.of(context).hintColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.folder_open_rounded,size: 20,)
                  ),
                ],
              )
            ),
            InkWell(
              onTap: () async{
                if(objectLocationController.text != ''){
                  setState(() {creating = true;});
                  for(final f in file){
                    await thumbnail.captureThumbnailSave(thumbnailLocationController.text, modelPath: f.path);
                  }
                  setState(() {
                    creating = false;
                  });
                }
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

  late three.OrbitControls controls;

  Future<void> setup() async {
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
}