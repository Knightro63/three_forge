import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:three_forge/src/modifers/create_models.dart';
import 'package:three_forge/src/modifers/insert_camera.dart';
import 'package:three_forge/src/modifers/insert_empty.dart';
import 'package:three_forge/src/modifers/insert_light.dart';
import 'package:three_forge/src/modifers/insert_mesh.dart';
import 'package:three_forge/src/modifers/insert_models.dart';
import 'package:three_forge/src/navigation/navData.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer/import.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js_advanced_exporters/usdz_exporter.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:three_js/three_js.dart' as three;

class ScreenNavigator{
  void Function(void Function()) setState;
  void Function({required LSICallbacks call}) callBacks;
  final ThreeViewer threeV;
  late final InsertModels insert;
  late final InsertMesh insertMesh;
  late final InsertLight insertLight;
  late final InsertEmpty insertEmpty;
  late final InsertCamera insertCamera;
  late final import = ThreeForgeImport(threeV);

  ScreenNavigator(this.threeV,this.setState,this.callBacks){
    insert = InsertModels(threeV);
    insertMesh = InsertMesh(threeV);
    insertLight = InsertLight(threeV);
    insertEmpty = InsertEmpty(threeV);
    insertCamera = InsertCamera(threeV);
  }

  late List<NavItems> navigator = [
    NavItems(
      name: 'File',
      subItems:[ 
        NavItems(
          name: 'New',
          icon: Icons.new_label_outlined,
          onTap: (data){
            threeV.reset(false);
            callBacks(call: LSICallbacks.updatedNav);
          }
        ),
        NavItems(
          name: 'Open',
          icon: Icons.file_open,
          onTap: (data){
            GetFilePicker.pickFiles(['json']).then((value)async{
              if(value != null){
                final json = jsonDecode(String.fromCharCodes(value.files.first.bytes!));
                threeV.fileSort.sceneName = value.files.first.name.replaceAll('.json', '');
                threeV.reset(true);
                import.import(json);
              }
              setState(() {});
            });
            callBacks(call: LSICallbacks.updatedNav);
          }
        ),
        NavItems(
          name: 'Save',
          icon: Icons.save,
          input: threeV.fileSort.sceneName,
          onTap: (data){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.fileSort.export(threeV.fileSort.sceneName, threeV);
          },
          onChange: (data){
            threeV.fileSort.sceneName = data;
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
                    await threeV.fileSort.moveObjects(value.files);
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
                      materials = await CreateModels.mtl('$path/$mtlName', mtlName);
                      paths.add('$path/$name');
                    }catch(e){}
                    await insert.obj('$path/$name', name, true, materials);

                    if(materials != null){
                      threeV.fileSort.moveFiles(name, paths);
                    }
                    else{
                      threeV.fileSort.moveObject(objs.files[i]);
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
                    await threeV.fileSort.moveObjects(value.files);
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
                    await threeV.fileSort.moveObjects(value.files);
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
                      await threeV.fileSort.moveObject(value.files[i]);
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
                      bool didMove = await insert.gltf(value.files[i].path!, value.files[i].name,true,true);
                      if(!didMove) await threeV.fileSort.moveObject(value.files[i]);
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
                      await insert.fbx(value.files[i].path!, value.files[i].name, true, true);
                      await threeV.fileSort.moveObject(value.files[i]);
                    }
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
                    await threeV.fileSort.moveObjects(value.files);
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
                    await threeV.fileSort.moveObjects(value.files);
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
                    await threeV.fileSort.moveObjects(value.files);
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
            threeV.resetCameraView();
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
              name: 'Capsule',
              icon: Icons.view_in_ar_rounded,
              onTap: (data){
                callBacks(call: LSICallbacks.updatedNav);
                insertMesh.capsule();
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
                insertMesh.colliderCapsule();
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
                insertCamera.perspective(threeV.aspectRatio());
              },
            ),
            NavItems(
              name: 'Ortographic',
              icon: Icons.video_camera_back,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertCamera.ortographic(threeV.aspectRatio());
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
                insertLight.ambientLight();
              },
            ),
            NavItems(
              name: 'Spot',
              icon: Icons.light,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertLight.spotLight();
              },
            ),
            NavItems(
              name: 'Directional',
              icon: Icons.light,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertLight.directionalLight();
              },
            ),
            NavItems(
              name: 'Point',
              icon: Icons.view_in_ar_rounded,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertLight.pointLight();
              },
            ),
            NavItems(
              name: 'Hemisphere',
              icon: Icons.panorama_photosphere,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertLight.hemisphereLight();
              },
            ),
            NavItems(
              name: 'Rect Area',
              icon: Icons.rectangle_outlined,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertLight.rectAreaLight();
              },
            ),
          ]
        ),
        NavItems(
          name: 'Empty',
          icon: Icons.group_work_outlined,
          subItems: [
            NavItems(
              name: 'Empty',
              icon: Icons.workspaces_outlined,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertEmpty.empty();
              },
            ),
            NavItems(
              name: 'Empty Parent',
              icon: Icons.workspaces_filled,
              onTap: (data) async{
                callBacks(call: LSICallbacks.updatedNav);
                insertEmpty.emptyParent();
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
        ),
        NavItems(
          name: 'Voxel Painter',
          icon: Icons.view_in_ar_rounded,
          onTap: (_){
            callBacks(call: LSICallbacks.updatedNav);
            threeV.createVoxelPainter();
          }
        )
      ]
    )
  ];
}