import 'package:flutter/material.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/gui/voxel_painter.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class ObjectGui extends StatefulWidget {
  const ObjectGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _ObjectGuiState createState() => _ObjectGuiState();
}

class _ObjectGuiState extends State<ObjectGui> {
  late final ThreeViewer threeV;

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    super.dispose();
    transfromControllers.clear();
  }

  void transformControllersReset(){
    for(final controllers in transfromControllers){
      controllers.clear();
    }
  }

  final List<TextEditingController> transfromControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    three.Object3D object = threeV.intersected[0];
    transformControllersReset();
    double d2 = 76;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            SizedBox(child: const Text('Name:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: object.name.toString(),
              ///width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'name',val)..allowDispatch=false);
                object.name = val;
              },
              controller: transfromControllers[0]..text = object.name.toString(),
            )
          ],
        ),
        SizedBox(height: 10,),
        Text('Shadow:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        InkWell(
          onTap: (){
            threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'castShadow', !object.castShadow)..allowDispatch=false);
            object.castShadow = !object.castShadow;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cast\t\t\t'),
              SavedWidgets.checkBox(object.castShadow)
            ]
          )
        ),
        InkWell(
          onTap: (){
            threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'receiveShadow', !object.receiveShadow)..allowDispatch=false);
            object.receiveShadow = !object.receiveShadow;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receive\t\t\t'),
              SavedWidgets.checkBox(object.receiveShadow)
            ]
          )
        ),
        SizedBox(height: 20,),
        InkWell(
          onTap: (){
            threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'visible', !object.visible)..allowDispatch=false);
            object.visible = !object.visible;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visible\t\t\t'),
              SavedWidgets.checkBox(object.visible)
            ]
          )
        ),
        InkWell(
          onTap: (){
            threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'frustumCulled', !object.frustumCulled)..allowDispatch=false);
            object.frustumCulled = !object.frustumCulled;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Frustum Culled\t\t\t'),
              SavedWidgets.checkBox(object.frustumCulled)
            ]
          )
        ),
        Row(
          children: [
            SizedBox(child: const Text('Order:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: object.renderOrder.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int v = int.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'renderOrder', v)..allowDispatch=false);
                object.renderOrder = v;
              },
              controller: transfromControllers[1]..text = object.renderOrder.toString(),
            )
          ],
        ),
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Wrap(
              children: [
                const Text('Script:'),
                EnterTextFormField(
                  readOnly: true,
                  //width: 76,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: transfromControllers[2],
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            if(object.userData['scripts'] == null){
              object.userData['scripts'] = <String>[];
            }
            object.userData['scripts'].add(details);
          },
        ),

        if(object is VoxelPainter) SizedBox(height: 10,),
        if(object is VoxelPainter) Text('Voxel Painter'),
        if(object is VoxelPainter) Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        if(object is VoxelPainter) VoxelPainterGui(voxelPainter: object)
      ],
    );
  }
}