import 'package:flutter/material.dart';
import 'package:three_forge/src/navigation/insert_models.dart';
import 'package:three_forge/src/navigation/navigation.dart';

import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';

class Hud extends StatelessWidget{
  final ThreeViewer threeV;
  final void Function(void Function()) setState;
  late final InsertModels insert;
  Hud(this.threeV,this.setState){
    insert = InsertModels(threeV);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*.8,
          height: MediaQuery.of(context).size.height-285,
          child: DragTarget(
            builder: (context, candidateItems, rejectedItems) {
              return threeV.build();
            },
            onAcceptWithDetails: (DragTargetDetails<Object> path){
              insert.insert((path.data as String));
            },
          ),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    threeV.control.setMode(GizmoType.translate);
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.translate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.control_camera,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    threeV.control.setMode(GizmoType.rotate);
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.rotate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.cached,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    threeV.control.setMode(GizmoType.scale);
                  });
                },
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.scale? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.aspect_ratio,
                    size: 20,
                  ),
                )
              ),
            ],
          )
        ),
        Row(
          children: [
            SizedBox(
              width: 150,
              height: 25, 
              child: Navigation(
                spacer: Text('|'),
                navData: [
                  NavItems(
                    name: threeV.controlSpace().toUpperCase(),
                    icon:  threeV.controlSpace() == ControlSpaceType.local.name?Icons.view_in_ar_outlined:Icons.public,
                    subItems: [
                      NavItems(
                        name: 'Global',
                        icon: Icons.public,
                        function: (data){
                          setState((){
                            threeV.setControlSpace(ControlSpaceType.global);
                          });
                        }
                      ),
                      NavItems(
                        name: 'Local',
                        icon: Icons.view_in_ar_outlined,
                        function: (data){
                          setState((){
                            threeV.setControlSpace(ControlSpaceType.local);
                          });
                        }
                      ),
                    ]
                  ),
                  NavItems(
                    name: threeV.gridInfo.axis.name,
                    icon:  Icons.grid_on,
                    subItems: [
                      NavItems(
                        name: 'XZ',
                        icon: Icons.grid_on,
                        function: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.XZ);
                          });
                        }
                      ),
                      NavItems(
                        name: 'YZ',
                        icon: Icons.grid_on,
                        function: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.YZ);
                          });
                        }
                      ),
                      NavItems(
                        name: 'XY',
                        icon: Icons.grid_on,
                        function: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.XY);
                          });
                        }
                      ),
                    ]
                  ),
                ]
              ),
            ),
          ]
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  if(threeV.shading != ShadingType.wireframe){
                    threeV.materialWireframeAll(threeV.shading);
                    setState(() {
                      threeV.shading = ShadingType.wireframe;
                    });
                  }
                },
                child:Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5)
                    ),
                    color: threeV.shading != ShadingType.wireframe?Theme.of(context).cardColor:Theme.of(context).secondaryHeaderColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.sports_basketball_outlined,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  if(threeV.shading != ShadingType.solid){
                    threeV.materialSolidAll(threeV.shading);
                    setState(() {
                      threeV.shading = ShadingType.solid;
                    });
                  }
                },
                child:Container(
                  margin: const EdgeInsets.fromLTRB(2,0,2,0),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: threeV.shading == ShadingType.solid?Theme.of(context).secondaryHeaderColor:Theme.of(context).cardColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.brightness_1,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  if(threeV.shading != ShadingType.material){
                    threeV.materialVertexModeAll(threeV.shading);
                    setState(() {
                      threeV.shading = ShadingType.material;
                    });
                  }
                },
                child:Container(
                  margin: const EdgeInsets.fromLTRB(0,0,2,0),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: threeV.shading == ShadingType.material?Theme.of(context).secondaryHeaderColor:Theme.of(context).cardColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.blur_on_rounded,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){

                },
                child:Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5)
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.radio_button_off,
                    size: 20,
                  ),
                ),
              ),
            ]
          )
        ),
        Positioned(
          right: 10,
          top: 60,
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  // threeV.materialWireframeAll();
                  // setState(() {
                  //   threeV.shading = ShadingType.wireframe;
                  // });
                  threeV.setToMainCamera();
                },
                child:Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5)
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.videocam_rounded,
                    size: 20,
                  ),
                ),
              ),
            ]
          )
        ),
      ]
    );
  }
}