import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer.dart/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class LightGui extends StatefulWidget {
  const LightGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _LightGuiState createState() => _LightGuiState();
}

class _LightGuiState extends State<LightGui> {
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
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    controllersReset();
    three.Light light = threeV.intersected! as three.Light;
    const double d = 60;
    double d2 = 65;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width:d, child: const Text('Color')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: '0x${light.color?.getHex().toRadixString(16) ?? 'ffffff'}',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  print(hex);
                  light.color = three.Color.fromHex32(hex);
                }
                else{
                  light.color = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: transfromControllers[0],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Intensity')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.intensity.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.intensity = double.parse(val);
              },
              controller: transfromControllers[1],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Ground\nColor')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: '0x${light.groundColor?.getHex().toRadixString(16) ?? 'ffffff'}',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  print(hex);
                  light.groundColor = three.Color.fromHex32(hex);
                }
                else{
                  light.groundColor = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: transfromControllers[2],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Distance')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.distance?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.distance = double.parse(val);
              },
              controller: transfromControllers[3],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Decay')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.decay?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.decay = double.parse(val);
              },
              controller: transfromControllers[4],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Width')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.width?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.width = double.parse(val);
              },
              controller: transfromControllers[5],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Height')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.height?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.height = double.parse(val);
              },
              controller: transfromControllers[6],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Angle')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.angle?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.angle = double.parse(val);
              },
              controller: transfromControllers[7],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: Text('Penubra')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: light.penumbra?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.penumbra = double.parse(val);
              },
              controller: transfromControllers[8],
            )
          ],
        )
      ],
    );
  }
}