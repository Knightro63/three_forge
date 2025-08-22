import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:three_forge/src/objects/insert_mesh.dart';
import 'package:three_forge/src/objects/insert_models.dart';
import 'package:three_forge/src/navigation/navData.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js_advanced_exporters/usdz_exporter.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class ScreenNavigator{
  void Function(void Function()) setState;
  void Function({required LSICallbacks call}) callBacks;
  final ThreeViewer threeV;
  late final InsertModels insert;
  late final InsertMesh insertMesh;

  String saveName = '';

  ScreenNavigator(this.threeV,this.setState,this.callBacks){
    insert = InsertModels(threeV);
    insertMesh = InsertMesh(threeV);
  }

  late List<NavItems> navigator = [
    NavItems(
      name: 'File',
      subItems:[ 
        NavItems(
          name: 'New',
          icon: Icons.new_label_outlined,
          onTap: (data){
            callBacks(call: LSICallbacks.updatedNav);
          }
        ),
        NavItems(
          name: 'Save',
          icon: Icons.save,
          input: saveName,
          onTap: (data){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.export(saveName);
          },
          onChange: (data){
            saveName = data;
          }
        ),
        // NavItems(
        //   name: 'Save As',
        //   icon: Icons.save_outlined,
        //   onTap: (data){
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
              onTap: (data) async{
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
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final objs = await GetFilePicker.pickFiles(['obj']);
                if(objs != null){
                  for(int i = 0; i < objs.files.length;i++){
                    three.MaterialCreator? materials;
                    String name = objs.files[i].name;
                    final path = objs.files[i].path!.replaceAll(name, '');
                    final mtlName = name.replaceAll('obj', 'mtl');
                    final List<String> paths = [];

                    try{
                      String mtl = await File('$path/$mtlName').readAsString();
                      paths.add('$path/$mtlName');
                      List<String> parms = mtl.split('\n');
                      for(final p in parms){
                        if(p.toLowerCase().contains('jpeg') || p.toLowerCase().contains('jpg') || p.toLowerCase().contains('png')){
                          final split = p.split(' ');
                          final image  = p.replaceAll('${split.first} ', '');
                          if(!paths.contains(image)){
                            paths.add('$path/$image');
                          }
                        }
                      }
                      materials = await insert.mtl('$path/$mtlName', mtlName);
                      paths.add('$path/$name');
                    }catch(e){}
                    await insert.obj('$path/$name', name, true, materials);

                    if(materials != null){
                      threeV.moveFiles(name, paths);
                    }
                    else{
                      threeV.moveObject(objs.files[i]);
                    }
                  }
                  
                }
                setState(() {});
              },
            ),
            NavItems(
              name: 'stl',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              name: 'usdz',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
              onTap: (data){
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
                  onTap: (data){
                    callBacks(call: LSICallbacks.updatedNav);
                    STLExporter.exportScene('untilted', threeV.scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  onTap: (data){
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
                  onTap: (data){
                    callBacks(call: LSICallbacks.updatedNav);
                    PLYExporter.exportScene('untilted', threeV.scene);
                  }
                ),
                NavItems(
                  name: 'binary',
                  icon: Icons.image,
                  onTap: (data){
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
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                OBJExporter.exportScene('untilted', threeV.scene);
              }
            ),
            NavItems(
              name: 'usdz',
              icon: Icons.file_copy_outlined,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                USDZExporter().exportScene('untilted', threeV.scene);
              }
            ),
            // NavItems(
            //   name: 'json',
            //   icon: Icons.file_copy_outlined,
            //   onTap: (data){
            //     callBacks(call: LSICallbacks.updatedNav);
            //     GetFilePicker.saveFile('untilted', 'json').then((path){

            //     });
            //   }
            // ),
            // NavItems(
            //   name: 'View',
            //   icon: Icons.image,
            //   onTap: (data){
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
          onTap: (data){
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
          onTap: (e){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.showCameraView = !threeV.showCameraView;
          }
        ),
        NavItems(
          name: 'Reset Camera',
          icon: Icons.camera_indoor_outlined,
          onTap: (e){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.resetCamera();
          }
        ),
        NavItems(
          name: 'Sky',
          icon: Icons.public,
          onTap: (e){
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
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.plane();
              },
            ),
            NavItems(
              name: 'Cube',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.cube();
              },
            ),
            NavItems(
              name: 'Circle',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.circle();
              },
            ),
            NavItems(
              name: 'Sphere',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.sphere();
              },
            ),
            NavItems(
              name: 'Ico Sphere',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.icoSphere();
              },
            ),
            NavItems(
              name: 'Cylinder',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.cylinder();
              },
            ),
            NavItems(
              name: 'Cone',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.cone();
              },
            ),
            NavItems(
              name: 'Torus',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.torus();
              },
            ),
          ]
        ),
        NavItems(
          name: 'Parametric',
          icon: Icons.share,
          subItems: [
            NavItems(
              name: 'Plane',
              icon: Icons.view_in_ar_rounded,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.parametricPlane();
              },
            ),
            NavItems(
              name: 'Klein',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.parametricKlein();
              },
            ),
            NavItems(
              name: 'Mobius',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.parametricMobius();
              },
            ),
            NavItems(
              name: 'Torus',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.parametricTorus();
              },
            ),
            NavItems(
              name: 'Sphere',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.parametricSphere();
              },
            ),
          ]
        ),
        NavItems(
          show: true,
          name: 'Collider',
          icon: Icons.share,
          subItems: [
            // NavItems(
            //   name: 'Plane',
            //   icon: Icons.view_in_ar_rounded,
            //   onTap: (data) async{
            //     callBacks(call: LSICallbacks.updatedNav);
            //     insertMesh.plane();
            //   },
            // ),
            NavItems(
              name: 'Cube',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.colliderCube();
              },
            ),
            NavItems(
              name: 'Sphere',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.colliderSphere();
              },
            ),
            NavItems(
              name: 'Cylinder',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.colliderCylinder();
              },
            ),
            NavItems(
              name: 'Capsule',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.cylinder();
              },
            ),
          ]
        ),
        NavItems(
          name: 'Camera',
          icon: Icons.videocam,
          subItems: [
            NavItems(
              name: 'Perspective',
              icon: Icons.video_camera_back,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final aspect = threeV.aspectRatio();
                final camera = three.PerspectiveCamera(40, aspect, 0.1, 10);
                camera.name = 'Perspective Camera';
                final helper = CameraHelper(camera);
                threeV.add(camera,helper);
              },
            ),
            NavItems(
              name: 'Ortographic',
              icon: Icons.video_camera_back,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final aspect = threeV.aspectRatio();
                final frustumSize = 5.0;
                final camera = three.OrthographicCamera(- frustumSize * aspect, frustumSize * aspect, frustumSize, - frustumSize, 0.1, 10);
                camera.name = 'Ortographic Camera';
                final helper = CameraHelper(camera);
                threeV.add(camera,helper);
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
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.AmbientLight(0xffffff);
                object.name = 'Ambient Light';
                threeV.add(object);
              },
            ),
            NavItems(
              name: 'Spot',
              icon: Icons.light,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.SpotLight(0xffffff,100,2,math.pi / 6, 1, 2);
                light.name = 'Spot Light';
                final helper = SpotLightHelper(light,0xffff00);
                threeV.add(light,helper);
                threeV.helper.add(helper);
              },
            ),
            NavItems(
              name: 'Directional',
              icon: Icons.light,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.DirectionalLight(0xffffff);
                light.name = 'Directional Light';
                final helper = DirectionalLightHelper(light,1,three.Color.fromHex32(0xffff00));
                threeV.add(light,helper);
              },
            ),
            NavItems(
              name: 'Point',
              icon: Icons.view_in_ar_rounded,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.PointLight(0xffffff,10);
                final helper = PointLightHelper(light,1,0xffff00);
                light.name = 'Point Light';
                threeV.add(light,helper);
              },
            ),
            NavItems(
              name: 'Hemisphere',
              icon: Icons.panorama_photosphere,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.HemisphereLight(0xffffff,0x444444);
                final helper = HemisphereLightHelper(light,1,three.Color.fromHex32(0xffff00));
                light.name = 'Hemisphere Light';
                threeV.add(light,helper);
              },
            ),
            NavItems(
              name: 'Rect Area',
              icon: Icons.rectangle_outlined,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final light = three.RectAreaLight(0xffffff,0x444444);
                final helper = RectAreaLightHelper(light,three.Color.fromHex32(0xffff00));
                light.name = 'Rect Area Light';
                threeV.add(light,helper);
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
        //           onTap: (data) async{
        //             callBacks(call: LSICallbacks.updatedNav);
        //             final object = three.AmbientLightProbe(three.Color.fromHex32(0xffffff));
        //             object.name = 'Ambient Probe';
        //             threeV.add(object);
        //           },
        //         ),
        //         NavItems(
        //           name: 'Hemisphere',
        //           icon: Icons.panorama_photosphere_rounded,
        //           onTap: (data) async{
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
        //           onTap: (data) async{
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
        //           onTap: (data) async{
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
        //           onTap: (data) async{
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
          show: false,
          name: 'Audio',
          icon: Icons.audiotrack_rounded,
          subItems: [
            NavItems(
              name: 'Positional',
              icon: Icons.spatial_audio_rounded,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Object3D();
                object.name = 'Positional Audio';
                threeV.add(object);
              },
            ),
            NavItems(
              name: 'Background',
              icon: Icons.audiotrack_rounded,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                final object = three.Object3D();
                object.name = 'Background Audio';
                threeV.add(object);
              },
            ),
          ]
        ),
        NavItems(
          show: false,
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
          onTap: (_){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.createTerrain();
          }
        )
      ]
    )

  ];
}