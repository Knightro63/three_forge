import 'package:flutter/material.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

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
              //label: threeV.intersected[0].position.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.execute(SetPositionCommand(threeV, threeV.intersected[0], Vector3(double.parse(val))));
                threeV.intersected[0].position.x = double.parse(val);
              },
              controller: transfromControllers[0]..text = threeV.intersected[0].position.x.toString(),
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
                threeV.execute(SetPositionCommand(threeV, threeV.intersected[0], Vector3(threeV.intersected[0].position.x, double.parse(val), threeV.intersected[0].position.z)));
                threeV.intersected[0].position.y = double.parse(val);
              },
              controller: transfromControllers[1]..text = threeV.intersected[0].position.y.toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.intersected[0].position.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.execute(SetPositionCommand(threeV, threeV.intersected[0], Vector3(threeV.intersected[0].position.x, threeV.intersected[0].position.y, double.parse(val))));
                threeV.intersected[0].position.z = double.parse(val);
              },
              controller: transfromControllers[2]..text = threeV.intersected[0].position.z.toString(),
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
              //label: threeV.intersected[0].rotation.x.toDeg().toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double rad = double.parse(val).toRad();
                final Euler newRot = Euler(rad, threeV.intersected[0].rotation.y, threeV.intersected[0].rotation.z);
                threeV.execute(SetRotationCommand(threeV, threeV.intersected[0], newRot));
                threeV.intersected[0].rotation.x = rad;
              },
              controller: transfromControllers[3]..text = threeV.intersected[0].rotation.x.toDeg().toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.intersected[0].rotation.y.toDeg().toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double rad = double.parse(val).toRad();
                final Euler newRot = Euler(threeV.intersected[0].rotation.x, rad, threeV.intersected[0].rotation.z);
                threeV.execute(SetRotationCommand(threeV, threeV.intersected[0], newRot));
                threeV.intersected[0].rotation.y = rad;
              },
              controller: transfromControllers[4]..text = threeV.intersected[0].rotation.y.toDeg().toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.intersected[0].rotation.z.toDeg().toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double rad = double.parse(val).toRad();
                final Euler newRot = Euler(threeV.intersected[0].rotation.x, threeV.intersected[0].rotation.y, rad);
                threeV.execute(SetRotationCommand(threeV, threeV.intersected[0], newRot));
                threeV.intersected[0].rotation.z = rad;
              },
              controller: transfromControllers[5]..text = threeV.intersected[0].rotation.z.toDeg().toString(),
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
              //label: 
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double scale = double.parse(val);
                final Vector3 newScale = Vector3(scale, threeV.intersected[0].scale.y, threeV.intersected[0].scale.z);
                threeV.execute(SetScaleCommand(threeV, threeV.intersected[0], newScale));
                threeV.intersected[0].scale.x = scale;
              },
              controller: transfromControllers[6]..text = threeV.intersected[0].scale.x.toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.intersected[0].scale.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double scale = double.parse(val);
                final Vector3 newScale = Vector3(threeV.intersected[0].scale.x, scale, threeV.intersected[0].scale.z);
                threeV.execute(SetScaleCommand(threeV, threeV.intersected[0], newScale));
                threeV.intersected[0].scale.y = scale;
              },
              controller: transfromControllers[7]..text = threeV.intersected[0].scale.y.toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.intersected[0].scale.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double scale = double.parse(val);
                final Vector3 newScale = Vector3(threeV.intersected[0].scale.x, threeV.intersected[0].scale.y, scale);
                threeV.execute(SetScaleCommand(threeV, threeV.intersected[0], newScale));
                threeV.intersected[0].scale.z = scale;
              },
              controller: transfromControllers[8]..text = threeV.intersected[0].scale.z.toString(),
            )
          ],
        )
      ],
    );
  }
}