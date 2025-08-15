import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class SkyGui extends StatefulWidget {
  const SkyGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _SkyGuiState createState() => _SkyGuiState();
}

class _SkyGuiState extends State<SkyGui> {
  late final ThreeViewer threeV;
  double elevation = 90;
  double azimuth = 180;
  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    super.dispose();
  }

  void updateSun() {
    final phi = three.MathUtils.degToRad( 90 - elevation);
    final theta = three.MathUtils.degToRad( azimuth);

    threeV.sun.setFromSphericalCoords( 1, phi, theta );
    threeV.sky.material!.uniforms[ 'sunPosition' ]['value'].setFrom( threeV.sun );
  }

  @override
  Widget build(BuildContext context) {
    final skyUniforms = threeV.sky.material!.uniforms;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Turbid   '),
            SizedBox(
              height: 35,
              width: 115,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: 0.0,
                  divisions: 20,
                  max: 20,
                  onChanged: (newRating){
                    skyUniforms[ 'turbidity' ]['value'] = newRating;
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    skyUniforms[ 'turbidity' ]['value'] = newRating;
                    setState(() {});
                  },
                  value: skyUniforms[ 'turbidity' ]['value'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Rayleigh'),
            SizedBox(
              height: 35,
              width: 113,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: 0.0,
                  divisions: 400,
                  max: 4,
                  onChanged: (newRating){
                    skyUniforms[ 'rayleigh' ]['value'] = newRating;
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    skyUniforms[ 'rayleigh' ]['value'] = newRating;
                    setState(() {});
                  },
                  value: skyUniforms[ 'rayleigh' ]['value'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('MieCo   '),
            SizedBox(
              height: 35,
              width: 115,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: 0.0,
                  divisions: 100,
                  max: 0.1,
                  onChanged: (newRating){
                    skyUniforms[ 'mieCoefficient' ]['value'] = newRating;
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    skyUniforms[ 'mieCoefficient' ]['value'] = newRating;
                    setState(() {});
                  },
                  value: skyUniforms[ 'mieCoefficient' ]['value'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('MieDir   '),
            SizedBox(
              height: 35,
              width: 115,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: 0.0,
                  divisions: 100,
                  max: 0.1,
                  onChanged: (newRating){
                    skyUniforms[ 'mieDirectionalG' ]['value'] = newRating;
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    skyUniforms[ 'mieDirectionalG' ]['value'] = newRating;
                    setState(() {});
                  },
                  value: skyUniforms[ 'mieDirectionalG' ]['value'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Elevate '),
            SizedBox(
              height: 35,
              width: 115,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: 0.0,
                  divisions: 900,
                  max: 90,
                  onChanged: (newRating){
                    elevation = newRating;
                    updateSun();
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    elevation = newRating;
                    updateSun();
                    setState(() {});
                  },
                  value: elevation,
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Azimuth'),
            SizedBox(
              height: 35,
              width: 115,
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 7,
                ),
                child: Slider(
                  activeColor: Theme.of(context).secondaryHeaderColor,
                  inactiveColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  min: -180,
                  divisions: 3600,
                  max: 180,
                  onChanged: (newRating){
                    azimuth = newRating;
                    updateSun();
                    setState(() {});
                  },
                  onChangeEnd: (newRating) {
                    azimuth = newRating;
                    updateSun();
                    setState(() {});
                  },
                  value: azimuth,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}