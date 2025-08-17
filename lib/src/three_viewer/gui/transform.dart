import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class TransformGui extends StatefulWidget {
  const TransformGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _TransformGuiState createState() => _TransformGuiState();
}

class _TransformGuiState extends State<TransformGui> {
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

  void controllersReset(){
    for(final controllers in transfromControllers){
      controllers.clear();
    }
  }

  final List<TextEditingController> transfromControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    controllersReset();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].position.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].position.x = double.parse(val);
              },
              controller: transfromControllers[0],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].position.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].position.y = double.parse(val);
              },
              controller: transfromControllers[1],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].position.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].position.z = double.parse(val);
              },
              controller: transfromControllers[2],
            )
          ],
        ),

        const SizedBox(height: 10,),
        const Text('Rotate'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].rotation.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].rotation.x = double.parse(val);
              },
              controller: transfromControllers[3],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].rotation.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].rotation.y = double.parse(val);
              },
              controller: transfromControllers[4],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].rotation.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].rotation.z = double.parse(val);
              },
              controller: transfromControllers[5],
            )
          ],
        ),

        const SizedBox(height: 10,),
        const Text('Scale'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].scale.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].scale.x = double.parse(val);
              },
              controller: transfromControllers[6],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].scale.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].scale.y = double.parse(val);
              },
              controller: transfromControllers[7],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.intersected[0].scale.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.intersected[0].scale.z = double.parse(val);
              },
              controller: transfromControllers[8],
            )
          ],
        )
      ],
    );
  }
}