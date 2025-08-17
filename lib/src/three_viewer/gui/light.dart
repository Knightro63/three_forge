import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
// import 'package:three_js_helpers/three_js_helpers.dart';

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
    lightsControllers.clear();
  }

  void controllersReset(){
    for(final controllers in lightsControllers){
      controllers.clear();
    }
  }
  void updateLightHelper(three.Light light){
    // if(light is three.DirectionalLight){
    //   (light.userData['helper'] as DirectionalLightHelper).copy(DirectionalLightHelper(light,light.intensity,three.Color.fromHex32(0xffff00)));
    // }
    // else if(light is three.SpotLight){
    //   (light.userData['helper'] as SpotLightHelper).copy(SpotLightHelper(light,0xffff00));
    // }
    // else if(light is three.PointLight){
    //   (light.userData['helper'] as PointLightHelper).copy(PointLightHelper(light,light.intensity,0xffff00));
    // }
    // else if(light is three.RectAreaLight){
    //   (light.userData['helper'] as RectAreaLightHelper).copy(RectAreaLightHelper(light,three.Color.fromHex32(0xffff00)));
    // }
    // else if(light is three.HemisphereLight){
    //   (light.userData['helper'] as HemisphereLightHelper).copy(HemisphereLightHelper(light,light.intensity,three.Color.fromHex32(0xffff00)));
    // }
    // light.userData['helper'].traverse((object) {
    //   if (object is three.Mesh) {
    //     if (object.material is three.MeshStandardMaterial) {
    //       object.material?.needsUpdate = true;
    //     }
    //   }
    // });
  }

  final List<TextEditingController> lightsControllers = [
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
    three.Light light = threeV.intersected[0] as three.Light;
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
              label: '0x${light.color?.getHex().toRadixString(16) ?? 'ffffff'}',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  light.color = three.Color.fromHex32(hex);
                }
                else{
                  light.color = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: lightsControllers[0],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Intensity')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.intensity.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.intensity = double.tryParse(val) ?? 1;
                updateLightHelper(light);
              },
              controller: lightsControllers[1],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Ground\nColor')),
            EnterTextFormField(
              label: '0x${light.groundColor?.getHex().toRadixString(16) ?? 'ffffff'}',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  light.groundColor = three.Color.fromHex32(hex);
                }
                else{
                  light.groundColor = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: lightsControllers[2],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Distance')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.distance?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.distance = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[3],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Decay')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.decay?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.decay = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[4],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Width')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.width?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.width = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[5],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Height')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.height?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.height = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[6],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Angle')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.angle?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.angle = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[7],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: Text('Penubra')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: light.penumbra?.toString() ?? '0',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                light.penumbra = double.tryParse(val);
                updateLightHelper(light);
              },
              controller: lightsControllers[8],
            )
          ],
        )
      ],
    );
  }
}