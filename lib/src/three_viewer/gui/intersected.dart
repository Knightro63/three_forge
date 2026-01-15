import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/gui/animation.dart';
import 'package:three_forge/src/three_viewer/gui/audio.dart';
import 'package:three_forge/src/three_viewer/gui/camera.dart';
import 'package:three_forge/src/three_viewer/gui/light.dart';
import 'package:three_forge/src/three_viewer/gui/material.dart';
import 'package:three_forge/src/three_viewer/gui/modifers.dart';
import 'package:three_forge/src/three_viewer/gui/object.dart';
import 'package:three_forge/src/three_viewer/gui/physics.dart';
import 'package:three_forge/src/three_viewer/gui/scene.dart';
import 'package:three_forge/src/three_viewer/gui/skeleton.dart';
import 'package:three_forge/src/three_viewer/gui/sky.dart';
import 'package:three_forge/src/three_viewer/gui/terrain.dart';
import 'package:three_forge/src/three_viewer/gui/transform.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_exporters/saveFile/filePicker.dart';
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_video_texture/three_js_video_texture.dart';

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

  final List<bool> expands = [false,false,false,false,false,false,false,false,false,false,false,false];

  List<Widget> objectGui(){
    int? id = threeV.intersected[0].userData['terrain_id'] == null?null:threeV.intersected[0].userData['terrain_id'];
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
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: TransformGui(threeV: threeV)
            )
          ],
        ),
      ),
      if(!threeV.intersected[0].name.contains('Collider-'))Container(
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
                  expands[5] = !expands[5];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[5]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\Object'),
                ],
              )
            ),
            if(expands[5]) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: ObjectGui(threeV: threeV)
            )
          ]
        )
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
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: LightGui(threeV: threeV)
            )
          ]
        )
      ),
      if(threeV.intersected[0] is three.Mesh && !threeV.intersected[0].name.contains('Collider-')) Container(
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
                  expands[4] = !expands[4];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[4]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tModifers'),
                ],
              )
            ),
            if(expands[4]) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
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
                  const Text('\tCamera'),
                ],
              )
            ),
            if(expands[2]) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: CameraGui(camera: threeV.intersected[0] as three.Camera, threeV: threeV))
          ]
        )
      ),
      if(threeV.intersected[0] is three.Mesh && !threeV.intersected[0].name.contains('Collider-')) Container(
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
                  expands[7] = !expands[7];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[7]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tMaterial'),
                ],
              )
            ),
            if(expands[7]) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,0,5),
              child: MaterialGui(threeV: threeV)
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
                  expands[8] = !expands[8];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[8]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\tTerrain'),
                ],
              )
            ),
            if(expands[8]) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: TerrainGui(terrain: threeV.terrains[id])
            )
          ]
        )
      ),
      if(threeV.intersected.isNotEmpty && threeV.intersected[0] is! three.Camera && threeV.intersected[0] is! three.Light && threeV.intersected[0] is! VoxelPainter&& threeV.intersected[0].userData['empty'] == false)Container(
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
                  expands[6] = !expands[6];
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      threeV.intersected[0].userData['addPhysics'] == false?SizedBox(width: 15,):Icon(!expands[6]?Icons.expand_more:Icons.expand_less, size: 15,),
                      const Text('\tPhysics'),
                    ],
                  ),
                  InkWell(
                    onTap: (){
                      threeV.intersected[0].userData['addPhysics'] = !(threeV.intersected[0].userData['addPhysics'] ?? false);
                      setState(() {});
                    },
                    child: SavedWidgets.checkBox(threeV.intersected[0].userData['addPhysics'] ?? false)
                  ),
                ],
              )
            ),
            if(expands[6] && (threeV.intersected[0].userData['addPhysics'] ?? false)) Padding(
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
              child: PhysicsGui(threeV: threeV)
            )
          ]
        )
      ),
      if(threeV.intersected.isNotEmpty && threeV.intersected[0].userData['skeleton'] is SkeletonHelper) Container(
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
                  const Text('\t Animation'),
                ],
              )
            ),
            if(expands[3]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: AnimationGui(threeV: threeV,)
            )
          ]
        )
      ),
      if(threeV.intersected.isNotEmpty && threeV.intersected[0].userData['skeleton'] is SkeletonHelper ) Container(
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
                  expands[9] = !expands[9];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[9]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\t Skeleton'),
                ],
              )
            ),
            if(expands[9]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: SkeletonGui(threeV: threeV,)
            )
          ]
        )
      ),
      if(threeV.intersected[0].userData['audio'] == null) addButton('audio'),
      addButton('script')
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
              padding: const EdgeInsets.fromLTRB(10,10,5,5),
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
      ),
      (threeV.scene.userData['audio'] == null)?addButton('audio'):Container(
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
                  expands[10] = !expands[10];
                });
              },
              child: Row(
                children: [
                  Icon(!expands[10]?Icons.expand_more:Icons.expand_less, size: 15,),
                  const Text('\t Audio'),
                ],
              )
            ),
            if(expands[10]) Padding(
              padding: const EdgeInsets.fromLTRB(25,10,5,5),
              child: AudioGui(threeV: threeV)
            )
          ]
        )
      ),
      addButton('script')
    ];
  }

  Widget addButton(String text){
    return InkWell(
      onTap: (){
        if(text == 'audio' && threeV.sceneSelected){
          GetFilePicker.pickFiles(['mp3']).then((value)async{
            if(value != null){
              threeV.scene.userData['audio'] = VideoAudio(path: value.files[0].path!);
              await threeV.fileSort.moveAudio(value.files[0]);
            }
          });
        }
        else if(text == 'audio'){
          GetFilePicker.pickFiles(['mp3']).then((value)async{
            if(value != null && threeV.mainCamera != null){
              threeV.scene.userData['audio'] = three.PositionalAudio(audioSource: VideoAudio(path: value.files[0].path!), listner: threeV.mainCamera!);
              await threeV.fileSort.moveAudio(value.files[0]);
            }
          });
        }
        setState(() {});
      },
      child: DragTarget(
        builder: (context, candidateItems, rejectedItems) {
          return Container(
            margin: EdgeInsets.all(5),
            //width: ,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Row(
                  children: [
                    Icon(Icons.add, size: 20,),
                    Text(text.toUpperCase())
                  ]
                ),
                Icon(Icons.description_outlined, size: 20,),
              ]
            ),
          );
        },
        onAcceptWithDetails: (details) async{
          if((details.data as String).split('.').last.toLowerCase() == 'mp3'){
            if(threeV.sceneSelected){
              threeV.scene.userData['audio'] = VideoAudio(path: (details.data as String));
            }
            else if(threeV.intersected.isNotEmpty){
              threeV.scene.userData['audio'] = three.PositionalAudio(audioSource: VideoAudio(path: (details.data as String)), listner: threeV.mainCamera!);
            }
          }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: threeV.sceneSelected?sceneGui():threeV.intersected.isEmpty?[]:objectGui(),
    );
  }
}