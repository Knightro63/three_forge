
import 'package:css/css.dart';
import 'package:flutter/material.dart';

import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import 'package:three_js_transform_controls/three_js_transform_controls.dart';

class Hud extends StatelessWidget{
  final ThreeViewer threeV;
  final void Function(void Function()) setState;
  Hud(this.threeV,this.setState);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*.8,
          height: MediaQuery.of(context).size.height-285,
          child: threeV.build(),
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
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.translate? CSS.darkTheme.secondaryHeaderColor.withAlpha(200):CSS.darkTheme.cardColor.withAlpha(200),
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
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.rotate? CSS.darkTheme.secondaryHeaderColor.withAlpha(200):CSS.darkTheme.cardColor.withAlpha(200),
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
                  color: threeV.mounted && threeV.control.enabled && threeV.control.mode == GizmoType.scale? CSS.darkTheme.secondaryHeaderColor.withAlpha(200):CSS.darkTheme.cardColor.withAlpha(200),
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
        Positioned(
          right: 10,
          top: 10,
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  threeV.materialWireframeAll();
                  setState(() {
                    threeV.shading = ShadingType.wireframe;
                  });
                },
                child:Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5)
                    ),
                    color: threeV.shading != ShadingType.wireframe?CSS.darkTheme.cardColor:CSS.darkTheme.secondaryHeaderColor,
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
                  threeV.materialReset(threeV.scene.children);
                  setState(() {
                    threeV.shading = ShadingType.solid;
                  });
                },
                child:Container(
                  margin: const EdgeInsets.fromLTRB(2,0,2,0),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: threeV.shading == ShadingType.solid?CSS.darkTheme.secondaryHeaderColor:CSS.darkTheme.cardColor,
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
                  threeV.materialVertexMode(threeV.scene.children);
                  setState(() {
                    threeV.shading = ShadingType.material;
                  });
                },
                child:Container(
                  margin: const EdgeInsets.fromLTRB(0,0,2,0),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: threeV.shading == ShadingType.material?CSS.darkTheme.secondaryHeaderColor:CSS.darkTheme.cardColor,
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
                    color: CSS.darkTheme.cardColor,
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
      ]
    );
  }
}