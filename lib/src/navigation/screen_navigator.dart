import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/navigation/insert_models.dart';
import 'package:three_forge/src/navigation/navData.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import 'package:three_js_advanced_exporters/usdz_exporter.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_geometry/three_js_geometry.dart';

class ScreenNavigator{
  void Function(void Function()) setState;
  void Function({required LSICallbacks call}) callBacks;
  final ThreeViewer threeV;
  late final InsertModels insert;

  ScreenNavigator(this.threeV,this.setState,this.callBacks){
    insert = InsertModels(threeV);
  }

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
          name: 'Save',
          icon: Icons.save,
          function: (data){
            callBacks(call: LSICallbacks.updatedNav);
            setState(() {});
          }
        ),
        // NavItems(
        //   name: 'Save As',
        //   icon: Icons.save_outlined,
        //   function: (data){
        //     setState(() {
        //       callBacks(call: LSICallbacks.updatedNav);
        //       if(!kIsWeb){
        //         GetFilePicker.saveFile('untilted', 'jle').then((path){
        //           setState(() {

        //           });
        //         });
        //       }
        //       else if(kIsWeb){
        //       }
        //     });
        //   }
        // ),
        NavItems(
          name: 'Import',
          icon: Icons.file_download_outlined,
          subItems: [
            NavItems(
              name: 'Image',
              icon: Icons.image,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['jpg','jpeg','png']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.image(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'obj',
              icon: Icons.view_in_ar_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                three.MaterialCreator? materials;
                final objs = await GetFilePicker.pickFiles(['obj']);
                final mtls = await GetFilePicker.pickFiles(['mtl']);
                if(mtls != null){
                  for(int i = 0; i < mtls.files.length;i++){
                    materials = await insert.mtl(mtls.files[i].path!, mtls.files[i].name);
                  }
                }
                if(objs != null){
                  for(int i = 0; i < objs.files.length;i++){
                    await insert.obj(objs.files[i].path!, objs.files[i].name, true, materials);
                  }
                  final List<PlatformFile> files = [];
                  files.addAll(objs.files);
                  if(mtls!= null) files.addAll(mtls.files);
                  threeV.moveObjects(files);
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
                      await insert.stl(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
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
                      await insert.ply(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'glb',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['glb']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.gltf(value.files[i].path!, value.files[i].name);
                      await threeV.moveObject(value.files[i]);
                    }
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'gltf',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['gltf']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.gltf(value.files[i].path!, value.files[i].name);
                      await threeV.moveObject(value.files[i]);
                    }
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'gltf-folder',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                GetFilePicker.pickFiles(['gltf']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.gltf(value.files[i].path!, value.files[i].name);
                      await threeV.moveFolder(value.files[i]);
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
                GetFilePicker.pickFiles(['fbx']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.fbx(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
                  }
                  setState(() {});
                });
              },
            ),
            NavItems(
              name: 'fbx-unity',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);   
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
                      threeV.scene.userData['animationClips'][object.name] = object.animations;
                      threeV.add(object..add(h)..add(skeleton));
                    }
                    await threeV.moveObjects(value.files);
                  }
                  setState(() {});
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
                      await insert.usdz(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
                  }
                });
              },
            ),
            NavItems(
              show: false,
              name: 'collada',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                setState(() {

                });
                GetFilePicker.pickFiles(['dae']).then((value)async{
                  if(value != null){
                    for(int i = 0; i < value.files.length;i++){
                      await insert.collada(value.files[i].path!, value.files[i].name);
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
                      insert.xyz(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
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
                      insert.vox(value.files[i].path!, value.files[i].name);
                    }
                    await threeV.moveObjects(value.files);
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
                    STLExporter.exportScene('untilted', threeV.scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  function: (data){
                    setState(() {
                      callBacks(call: LSICallbacks.updatedNav);
                      STLBinaryExporter.exportScene('untilted', threeV.scene);
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
                    PLYExporter.exportScene('untilted', threeV.scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  function: (data){
                    setState(() {
                      callBacks(call: LSICallbacks.updatedNav);
                      PLYExporter.exportScene('untilted', threeV.scene, PLYOptions(type: ExportTypes.binary));
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
                OBJExporter.exportScene('untilted', threeV.scene);
              }
            ),
            NavItems(
              name: 'usdz',
              icon: Icons.file_copy_outlined,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                USDZExporter().exportScene('untilted', threeV.scene);
              }
            ),
            // NavItems(
            //   name: 'json',
            //   icon: Icons.file_copy_outlined,
            //   function: (data){
            //     callBacks(call: LSICallbacks.updatedNav);
            //     GetFilePicker.saveFile('untilted', 'json').then((path){

            //     });
            //   }
            // ),
            // NavItems(
            //   name: 'View',
            //   icon: Icons.image,
            //   function: (data){
            //     setState(() {
            //       callBacks(call: LSICallbacks.updatedNav);
            //       GetFilePicker.saveFile('untilted', 'png').then((path){

            //       });
            //     });
            //   }
            // )
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
          name: 'Game View',
          icon: Icons.camera_outdoor_rounded,
          function: (e){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.showCameraView = !threeV.showCameraView;
          }
        ),
        NavItems(
          name: 'Reset Camera',
          icon: Icons.camera_indoor_outlined,
          function: (e){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.resetCamera();
          }
        ),
        NavItems(
          name: 'Sky',
          icon: Icons.public,
          function: (e){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.viewSky();
          }
        ),
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
                final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Plane';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cube',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(three.BoxGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.receiveShadow = true;
                object.name = 'Cube';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Circle',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(CircleGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);

                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Circle';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Sphere',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(three.SphereGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                                print(box.getSize(three.Vector3()).toJson());
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Sphere';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Ico Sphere',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(IcosahedronGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Ico Sphere';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cylinder',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(CylinderGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Cylinder';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Cone',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(ConeGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Cone';
                threeV.add(object.add(h));
              },
            ),
            NavItems(
              name: 'Torus',
              icon: Icons.view_in_ar_rounded,
              function: (data){
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Mesh(TorusGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
                final three.BoundingBox box = three.BoundingBox();
                box.setFromObject(object);     
                BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
                object.name = 'Torus';
                threeV.add(object.add(h));
              },
            ),
          ]
        ),
        // NavItems(
        //   name: 'Light',
        //   icon: Icons.light,
        //   subItems: [
        NavItems(
          name: 'Light',
          icon: Icons.lightbulb_sharp,
          subItems: [
            NavItems(
              name: 'Ambient',
              icon: Icons.light_mode,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.AmbientLight(0xffffff);
                object.name = 'Ambient Light';
                threeV.add(object);
              },
            ),
            NavItems(
              name: 'Spot',
              icon: Icons.light,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.SpotLight(0xffffff,100,2,math.pi / 6, 1, 2);
                light.name = 'Spot Light';
                final helper = SpotLightHelper(light);
                threeV.add(light..userData['helper'] = helper);
                threeV.helper.add(helper);
              },
            ),
            NavItems(
              name: 'Directional',
              icon: Icons.light,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.DirectionalLight(0xffffff);
                light.name = 'Directional Light';
                final helper = DirectionalLightHelper(light);
                threeV.add(light..userData['helper'] = helper);
                threeV.helper.add(helper);
              },
            ),
            NavItems(
              name: 'Point',
              icon: Icons.view_in_ar_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.PointLight(0xffffff,10);
                final helper = PointLightHelper(light,1);
                light.name = 'Point Light';
                threeV.add(light..userData['helper'] = helper);
                threeV.helper.add(helper);
              },
            ),
            NavItems(
              name: 'Hemisphere',
              icon: Icons.panorama_photosphere,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.HemisphereLight(0xffffff,0x444444);
                final helper = HemisphereLightHelper(light,1);
                light.name = 'Hemisphere Light';
                threeV.add(light..userData['helper'] = helper);
                threeV.helper.add(helper);
              },
            ),
            NavItems(
              name: 'Rect Area',
              icon: Icons.rectangle_outlined,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.RectAreaLight(0xffffff,0x444444);
                final helper = RectAreaLightHelper(light);
                light.name = 'Rect Area Light';
                threeV.add(light..userData['helper'] = helper);
                threeV.helper.add(helper);
              },
            ),
          ]
        ),
        //     NavItems(
        //       name: 'Probe',
        //       icon: Icons.lightbulb_sharp,
        //       show: false,
        //       subItems: [
        //         NavItems(
        //           name: 'Ambient',
        //           icon: Icons.light_mode_outlined,
        //           function: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.AmbientLightProbe(three.Color.fromHex32(0xffffff));
        //             object.name = 'Ambient Probe';
        //             threeV.add(object);
        //           },
        //         ),
        //         NavItems(
        //           name: 'Hemisphere',
        //           icon: Icons.panorama_photosphere_rounded,
        //           function: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.HemisphereLightProbe(three.Color.fromHex32(0xffffff),three.Color.fromHex32(0x444444));
        //             object.name = 'Hemisphere Probe';
        //             threeV.add(object);
        //           },
        //         ),
        //       ]
        //     ),
        //     NavItems(
        //       name: 'Shadow',
        //       icon: Icons.lightbulb_circle_outlined,
        //       show: false,
        //       subItems: [
        //         NavItems(
        //           name: 'Spot',
        //           icon: Icons.light_outlined,
        //           function: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
        //             final three.BoundingBox box = three.BoundingBox();
        //             box.setFromObject(object);     
        //             BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
        //             object.name = 'Spot Shadow';
        //             threeV.add(object.add(h));
        //           },
        //         ),
        //         NavItems(
        //           name: 'Directional',
        //           icon: Icons.light_outlined,
        //           function: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
        //             final three.BoundingBox box = three.BoundingBox();
        //             box.setFromObject(object);     
        //             BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
        //             object.name = 'Directional Shadow';
        //             threeV.add(object.add(h));
        //           },
        //         ),
        //         NavItems(
        //           name: 'Point',
        //           icon: Icons.lightbulb_outlined,
        //           function: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
        //             final three.BoundingBox box = three.BoundingBox();
        //             box.setFromObject(object);     
        //             BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
        //             object.name = 'Point Shadow';
        //             threeV.add(object.add(h));
        //           },
        //         ),
        //       ]
        //     ),
        //   ]
        // ),
      ]
    ),
    NavItems(
      name: 'Create',
      subItems:[ 
        NavItems(
          name: 'Audio',
          icon: Icons.audiotrack_rounded,
          subItems: [
            NavItems(
              name: 'Positional',
              icon: Icons.spatial_audio_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Object3D();
                object.name = 'Positional Audio';
                threeV.add(object);
              },
            ),
            NavItems(
              name: 'Background',
              icon: Icons.audiotrack_rounded,
              function: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Object3D();
                object.name = 'Background Audio';
                threeV.add(object);
              },
            ),
          ]
        ),
        NavItems(
          name: 'Texture',
          icon: Icons.texture_outlined,
          subItems: [
            NavItems(
              name: 'Cube',
              icon: Icons.texture,
            ),
            NavItems(
              name: 'Data',
              icon: Icons.texture,
            ),
          ]
        ),
        NavItems(
          name: 'Terrain',
          icon: Icons.terrain,
        )
      ]
    )

  ];
}