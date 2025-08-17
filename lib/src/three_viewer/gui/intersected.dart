import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/gui/camera.dart';
import 'package:three_forge/src/three_viewer/gui/light.dart';
import 'package:three_forge/src/three_viewer/gui/modifers.dart';
import 'package:three_forge/src/three_viewer/gui/scene.dart';
import 'package:three_forge/src/three_viewer/gui/sky.dart';
import 'package:three_forge/src/three_viewer/gui/terrain.dart';
import 'package:three_forge/src/three_viewer/gui/transform.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class IntersectedGui extends StatefulWidget {
  const IntersectedGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _IntersectedGuiState createState() => _IntersectedGuiState();
}

class _IntersectedGuiState extends State<IntersectedGui> {
  late final ThreeViewer threeV;

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    super.dispose();
    expands.clear();
  }

  final List<bool> expands = [false,false,false,false];

  List<Widget> objectGui(){
    int? id = int.tryParse(threeV.intersected[0].name.split('_').last);
    return[
      Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[0] = !expands[0];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[0]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tTransform'),
                ],
              )
            ),
            if(expands[0]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: TransformGui(threeV: threeV)
            )
          ],
        ),
      ),
      if(threeV.intersected[0] is three.Light) Container(
        margin: const EdgeInsets.fromLTRB(5,5,0,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[1] = !expands[1];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[1]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tLight'),
                ],
              )
            ),
            if(expands[1]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: LightGui(threeV: threeV)
            )
          ]
        )
      ),
      if(threeV.intersected[0] is three.Mesh) Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[2] = !expands[2];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[2]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tModifers'),
                ],
              )
            ),
            if(expands[2]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: ModiferGui(threeV: threeV)
            )
          ]
        )
      ),
      if(threeV.intersected[0] is three.Camera) Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[2] = !expands[2];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[2]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\Camera'),
                ],
              )
            ),
            if(expands[2]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: CameraGui(threeV: threeV)
            )
          ]
        )
      ),
      if(threeV.intersected[0] is three.Mesh) Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[3] = !expands[3];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[3]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tMaterial'),
                ],
              )
            ),
            if(expands[3]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ]
              )
            )
          ]
        )
      ),
      if(id != null) Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[3] = !expands[3];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[3]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tTerrain'),
                ],
              )
            ),
            if(expands[3]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: TerrainGui(terrain: threeV.terrains[id])
            )
          ]
        )
      ),


      // if(animationClips[intersected?.name] != null) Container(
      //   margin: const EdgeInsets.fromLTRB(5,5,5,5),
      //   decoration: BoxDecoration(
      //     color: Theme.of(context).cardColor,
      //     borderRadius: BorderRadius.circular(5)
      //   ),
      //   child: Column(
      //     children: [
      //       InkWell(
      //         onTap: (){
      //           setState(() {
      //             expands[3] = !expands[3];
      //           });
      //         },
      //         child: Row(
      //           children: [
      //             Icon(!expands[3]?Icons.expand_more:Icons.expand_less, size: 15,),
      //             const Text('\t Animation'),
      //           ],
      //         )
      //       ),
      //       if(expands[3]) Padding(
      //         padding: const EdgeInsets.fromLTRB(25,10,5,5),
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.start,
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: getAnimations()
      //         )
      //       )
      //     ]
      //   )
      // ),
    ];
  }

  List<Widget> sceneGui(){
    return[
      Container(
        margin: const EdgeInsets.fromLTRB(5,5,5,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[0] = !expands[0];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[0]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tBackground'),
                ],
              )
            ),
            if(expands[0]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: SceneGui(threeV: threeV)
            ),
          ]
        )
      ),
      if(threeV.sky.visible)Container(
        margin: const EdgeInsets.fromLTRB(5,5,0,5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  expands[1] = !expands[1];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[1]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tSky'),
                ],
              )
            ),
            if(expands[1]) Padding(
              padding: const EdgeInsets.fromLTRB(5,10,0,5),
              child: SkyGui(threeV: threeV)
            ),
          ]
        )
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: threeV.sceneSelected?sceneGui():threeV.intersected.isEmpty?[]:objectGui(),
    );
  }
}