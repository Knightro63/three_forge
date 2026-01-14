import 'package:flutter/material.dart';
import 'package:three_forge/src/objects/insert_models.dart';
import 'package:three_forge/src/navigation/navigation.dart';
import 'package:three_forge/src/three_viewer/gui/paint_helper.dart';
import 'package:three_forge/src/three_viewer/gui/selection_helper.dart';
import 'package:three_forge/src/three_viewer/src/grid_info.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';

import 'package:three_forge/src/three_viewer/viewer.dart';
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
              insert.insert((path.data as String)).then((_){
                setState((){});
              });
            },
          ),
        ),
        SelectionHelper(threeV: threeV),
        PaintHelper(threeV: threeV),
        Positioned(
          left: 10,
          top: 10,
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    threeV.setSelector(SelectorType.select);
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  color: SelectorType.select == threeV.selectorType? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.select_all,
                    size: 20,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    threeV.setSelector(SelectorType.translate);
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  color: SelectorType.translate == threeV.selectorType && threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.translate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
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
                    threeV.setSelector(SelectorType.rotate);
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: SelectorType.rotate == threeV.selectorType && threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.rotate? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
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
                    threeV.setSelector(SelectorType.scale);
                  });
                },
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: SelectorType.scale == threeV.selectorType && threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.scale? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.aspect_ratio,
                    size: 20,
                  ),
                )
              ),
              if(threeV.intersected.isNotEmpty && threeV.intersected[0] is VoxelPainter)InkWell(
                onTap: (){
                  setState(() {
                    threeV.setSelector(SelectorType.paint);
                  });
                },
                child: Container(
                  width: 25,
                  height: 25,
                  margin: const EdgeInsets.only(top: 2),
                  color: SelectorType.paint == threeV.selectorType? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.brush_sharp,
                    size: 20,
                  ),
                )
              ),
              // if(threeV.intersected.isNotEmpty && threeV.intersected[0] is VoxelPainter)InkWell(
              //   onTap: (){
              //     setState(() {
              //       threeV.setSelector(SelectorType.erase);
              //     });
              //   },
              //   child: Container(
              //     width: 25,
              //     height: 25,
              //     margin: const EdgeInsets.only(top: 2),
              //     color: SelectorType.erase == threeV.selectorType? Theme.of(context).secondaryHeaderColor.withAlpha(200):Theme.of(context).cardColor.withAlpha(200),
              //     alignment: Alignment.center,
              //     child: const Icon(
              //       Icons.brunch_dining_sharp,
              //       size: 20,
              //     ),
              //   )
              // ),
            ],
          )
        ),
        Row(
          children: [
            SizedBox(
              width: 186,
              height: 25, 
              child: Navigation(
                spacer: Text('|'),
                navData: [
                  NavItems(
                    name: threeV.controlSpace.name.toUpperCase(),
                    icon:  threeV.controlSpace == ControlSpaceType.local?Icons.view_in_ar_outlined:Icons.public,
                    subItems: [
                      NavItems(
                        name: 'Global',
                        icon: Icons.public,
                        onTap: (data){
                          setState((){
                            threeV.setControlSpace(ControlSpaceType.global);
                          });
                        }
                      ),
                      NavItems(
                        name: 'Local',
                        icon: Icons.view_in_ar_outlined,
                        onTap: (data){
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
                        onTap: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.XZ);
                          });
                        }
                      ),
                      NavItems(
                        name: 'YZ',
                        icon: Icons.grid_on,
                        onTap: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.YZ);
                          });
                        }
                      ),
                      NavItems(
                        name: 'XY',
                        icon: Icons.grid_on,
                        onTap: (data){
                          setState((){
                            threeV.setGridRotation(GridAxis.XY);
                          });
                        }
                      ),
                    ]
                  ),
                  NavItems(
                    name: 'grid_info',
                    useName: false,
                    icon:  Icons.arrow_drop_down_rounded,
                    subItems: [
                      NavItems(
                        name: 'Size',
                        input: threeV.gridInfo.size,
                        onChange: (data){
                          final size = double.tryParse(data);
                          setState((){
                            if(size != null){
                              threeV.gridInfo.updateGrid(size, threeV.gridInfo.divisions);
                            }
                          });
                        }
                      ),
                      NavItems(
                        name: 'Div',
                        input: threeV.gridInfo.divisions,
                        onChange: (data){
                          setState((){
                            final divisions = int.tryParse(data);
                            if(divisions != null){
                              threeV.gridInfo.updateGrid(threeV.gridInfo.size, divisions);
                            }
                          });
                        }
                      ),
                      NavItems(
                        name: 'Snap',
                        icon: Icons.grid_goldenratio_rounded,
                        onTap: (data){
                          setState((){
                            threeV.gridInfo.setSnap(!threeV.gridInfo.isSnapOn);
                          });
                        }
                      ),
                    ]
                  )
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
              // InkWell(
              //   onTap: (){

              //   },
              //   child:Container(
              //     width: 25,
              //     height: 25,
              //     decoration: BoxDecoration(
              //       borderRadius: const BorderRadius.only(
              //         topRight: Radius.circular(5),
              //         bottomRight: Radius.circular(5)
              //       ),
              //       color: Theme.of(context).cardColor,
              //     ),
              //     alignment: Alignment.center,
              //     child: const Icon(
              //       Icons.radio_button_off,
              //       size: 20,
              //     ),
              //   ),
              // ),
            ]
          )
        ),
        Positioned(
          right: 10,
          top: 120,
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