import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_js/three_js.dart' as three;

class ShadowLightGui extends StatefulWidget {
  const ShadowLightGui({Key? key, required this.lightShadow}):super(key: key);
  final three.LightShadow lightShadow;

  @override
  _ShadowLightGuiState createState() => _ShadowLightGuiState();
}

class _ShadowLightGuiState extends State<ShadowLightGui> {
  late final three.LightShadow lightShadow;
  
  @override
  void initState() {
    super.initState();
    lightShadow = widget.lightShadow;
  }
  @override
  void dispose(){
    super.dispose();
    lightsControllers.clear();
  }

  void controllersReset(){
    for(final controllers in lightsControllers){
      controllers.clear();
    }
  }

  final List<TextEditingController> lightsControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    controllersReset();
    const double d = 60;
    double d2 = 65;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        const Text('Map'),
        const SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Width')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: lightShadow.mapSize.width.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                lightShadow.mapSize.width = double.tryParse(val) ?? 0;
              },
              controller: lightsControllers[0],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Height')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: lightShadow.mapSize.height.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                lightShadow.mapSize.height = double.tryParse(val) ?? 0;
              },
              controller: lightsControllers[1],
            )
          ],
        ),
        const SizedBox(height: 10,),
        const Text('Shadow'),
        const SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Bias')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: lightShadow.bias.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                lightShadow.bias = double.tryParse(val) ?? 0;
              },
              controller: lightsControllers[2],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: Text('Radius')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: lightShadow.radius.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                lightShadow.radius = double.tryParse(val) ??0;
              },
              controller: lightsControllers[3],
            )
          ],
        )
      ],
    );
  }
}