
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/navigation/navData.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_js_advanced_exporters/usdz_exporter.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_geometry/three_js_geometry.dart';

class ScreenNavigator{
  void Function(void Function()) setState;
  void Function({required LSICallbacks call}) callBacks;
  final three.Scene scene;

  ScreenNavigator(this.scene,this.setState,this.callBacks);

  late List<NavItems> navigator = [
    NavItems(
      name: 'File',
      subItems:[ 
        NavItems(
          name: 'New',
          icon: Icons.new_label_outlined,
          function: (data){
            callBacks(call: LSICallbacks.clear);
          }
        ),
        NavItems(
          name: 'Open',
          icon: Icons.folder_open,
          function: (data){
            setState(() {
              callBacks(call: LSICallbacks.clear);
              GetFilePicker.pickFiles(['spark','jle']).then((value)async{
                if(value != null){
                  for(int i = 0; i < value.files.length;i++){

                  }
                }
              });
            });
          }
        ),
        NavItems(
          name: 'Save',
          icon: Icons.save,
          function: (data){
            callBacks(call: LSICallbacks.updatedNav);
            setState(() {});
          }
        ),
        NavItems(
          name: 'Save As',
          icon: Icons.save_outlined,
          function: (data){
            setState(() {
              callBacks(call: LSICallbacks.updatedNav);
              if(!kIsWeb){
                GetFilePicker.saveFile('untilted', 'jle').then((path){
                  setState(() {

                  });
                });
              }
              else if(kIsWeb){
              }
            });
          }
        ),
        NavItems(
          name: 'Import',
          icon: Icons.file_download_outlined,
          subItems: [
            NavItems(
              name: 'obj',
              icon: Icons.view_in_ar_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final manager = three.LoadingManager();
                three.MaterialCreator? materials;
                final objs = await GetFilePicker.pickFiles(['obj']);
                final mtls = await GetFilePicker.pickFiles(['mtl']);
                if(mtls != null){
                  for(int i = 0; i < mtls.files.length;i++){
                    final mtlLoader = three.MTLLoader(manager);
                    final last = mtls.files[i].path!.split('/').last;
                    mtlLoader.setPath(mtls.files[i].path!.replaceAll(last,''));
                    materials = await mtlLoader.fromPath(last);
                    await materials?.preload();
                  }
                }
                if(objs != null){
                  for(int i = 0; i < objs.files.length;i++){
                    final loader = three.OBJLoader();
                    loader.setMaterials(materials);
                    final object = await loader.fromPath(objs.files[i].path!);
                    final three.BoundingBox box = three.BoundingBox();
                    box.setFromObject(object!);
                    object.scale = three.Vector3(0.01,0.01,0.01);        
                    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                    object.name = objs.files[i].name.split('.').first;
                    scene.add(object.add(h));
                  }
                }
                setState(() {});
              },
            ),
            NavItems(
              name: 'stl',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['stl']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final object = await three.STLLoader().fromPath(value.files[i].path!);
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object!);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'ply',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['ply']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final buffer = await three.PLYLoader().fromPath(value.files[i].path!);
                      final object = three.Mesh(buffer,three.MeshPhongMaterial());
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object);
                      object.scale = three.Vector3(0.01,0.01,0.01);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'glb/gltf',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['glb','gltf']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final loader = three.GLTFLoader();
                      final String path = value.files[i].path!;
                      loader.setPath(path.replaceAll(path.split('/').last, ''));
                      final object = await three.GLTFLoader().fromPath(value.files[i].path!);
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object!.scene);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.scene.name = value.files[i].name.split('.').first;
                      if(object.animations != null) scene.userData['animationClips'][object.scene.name] = object.animations!;
                      final skeleton = SkeletonHelper(object.scene);
                      skeleton.visible = false;
                      scene.add(object.scene..add(h)..add(skeleton));
                    }
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'fbx',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['fbx']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final object = await three.FBXLoader(width: 1,height: 1).fromPath(value.files[i].path!);
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object!);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      final skeleton = SkeletonHelper(object)..visible = false;
                      object.scale = three.Vector3(0.01,0.01,0.01);
                      object.name = value.files[i].name.split('.').first;
                      scene.userData['animationClips'][object.name] = object.animations;
                      scene.add(object..add(h)..add(skeleton));
                    }
                  }
                });
              },
            ),
            NavItems(
              name: 'usdz',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['usdz']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final object = await three.USDZLoader().fromPath(value.files[i].path!);
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object!);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.scale = three.Vector3(0.01,0.01,0.01);
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                });
              },
            ),
            NavItems(
              name: 'collada',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['dae']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final mesh = await three.ColladaLoader().fromPath(value.files[i].path!);
                      final object = mesh!.scene!;
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                });
              },
            ),
            NavItems(
              name: 'xyz',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['xyz']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final mesh = await three.XYZLoader().fromPath(value.files[i].path!);
                      final object = three.Mesh(mesh,three.MeshPhongMaterial());
                      final three.BoundingBox box = three.BoundingBox();
                      box.setFromObject(object);
                      BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                });
              },
            ),
            NavItems(
              name: 'vox',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['vox']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      final chunks = await three.VOXLoader().fromPath(value.files[i].path!);
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
                      object.name = value.files[i].name.split('.').first;
                      scene.add(object.add(h));
                    }
                  }
                });
              },
            ),
          ]
        ),
        NavItems(
          name: 'Export',
          icon: Icons.file_upload_outlined,
          subItems: [
            NavItems(
              name: 'stl',
              icon: Icons.file_upload_outlined,
              subItems: [
                NavItems(
                  name: 'ascii',
                  icon: Icons.file_copy_outlined,
                  function: (data){
                    callBacks(call: LSICallbacks.updatedNav);
                    STLExporter.exportScene('untilted', scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  function: (data){
                    setState(() {
                      callBacks(call: LSICallbacks.updatedNav);
                      STLBinaryExporter.exportScene('untilted', scene);
                    });
                  }
                )
              ]
            ),
            NavItems(
              name: 'ply',
              icon: Icons.file_upload_outlined,
              subItems: [
                NavItems(
                  name: 'ascii',
                  icon: Icons.file_copy_outlined,
                  function: (data){
                    callBacks(call: LSICallbacks.updatedNav);
                    PLYExporter.exportScene('untilted', scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  function: (data){
                    setState(() {
                      callBacks(call: LSICallbacks.updatedNav);
                      PLYExporter.exportScene('untilted', scene, PLYOptions(type: ExportTypes.binary));
                    });
                  }
                )
              ]
            ),
            NavItems(
              name: 'obj',
              icon: Icons.file_copy_outlined,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                OBJExporter.exportScene('untilted', scene);
              }
            ),
            NavItems(
              name: 'usdz',
              icon: Icons.file_copy_outlined,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                USDZExporter().exportScene('untilted', scene);
              }
            ),
            NavItems(
              name: 'json',
              icon: Icons.file_copy_outlined,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.saveFile('untilted', 'json').then((path){

                });
              }
            ),
            NavItems(
              name: 'level image',
              icon: Icons.image,
              function: (data){
                setState(() {
                  callBacks(call: LSICallbacks.updatedNav);
                  GetFilePicker.saveFile('untilted', 'png').then((path){

                  });
                });
              }
            )
          ]
        ),
        NavItems(
          name: 'Quit',
          icon: Icons.exit_to_app,
          function: (data){
            callBacks(call: LSICallbacks.quit);
          }
        ),
      ]
    ),
    NavItems(
      name: 'View',
      subItems:[
        NavItems(
          name: 'Reset Camera',
          icon: Icons.camera_indoor_outlined,
          function: (e){
            callBacks(call: LSICallbacks.resetCamera);
          }
        )
      ]
    ),
    NavItems(
      name: 'Add',
      subItems:[ 
        NavItems(
          name: 'Mesh',
          icon: Icons.share,
          subItems: [
            NavItems(
              name: 'Plane',
              icon: Icons.view_in_ar_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(three.PlaneGeometry(),three.MeshStandardMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Plane';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cube',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(three.BoxGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.receiveShadow = true;
                object.name = 'Cube';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Circle',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(CircleGeometry(),three.MeshStandardMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Circle';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Sphere',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(three.SphereGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Sphere';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Ico Sphere',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(IcosahedronGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Ico Sphere';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cylinder',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(CylinderGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Cylinder';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cone',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(ConeGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Cone';
                scene.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Torus',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(TorusGeometry(),three.MeshStandardMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Torus';
                scene.add(object.add(h));
              },
            ),
          ]
        ),
      ]
    ),
  ];
}