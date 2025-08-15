import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/terrain.dart';

class TerrainGui extends StatefulWidget {
  const TerrainGui({Key? key, required this.terrain}):super(key: key);
  final Terrain terrain;

  @override
  _TerrainGuiState createState() => _TerrainGuiState();
}

class _TerrainGuiState extends State<TerrainGui> {
  late final Terrain terrain;

  List<DropdownMenuItem<String>> heightmapSelector = LSIFunctions.setDropDownItems(['Brownian', 'Cosine', 'CosineLayers', 'DiamondSquare', 'Fault', 'heightmap.png', 'Hill', 'HillIsland', 'influences', 'Particles', 'Perlin', 'PerlinDiamond', 'PerlinLayers', 'Simplex', 'SimplexLayers', 'Value', 'Weierstrass', 'Worley']);
  List<DropdownMenuItem<String>> easingSelector = LSIFunctions.setDropDownItems(['Linear', 'EaseIn', 'EaseInWeak', 'EaseOut', 'EaseInOut', 'InEaseOut']);
  List<DropdownMenuItem<String>> smoothingSelector = LSIFunctions.setDropDownItems(['Conservative (0.5)', 'Conservative (1)', 'Conservative (10)', 'Gaussian (0.5, 7)', 'Gaussian (1.0, 7)', 'Gaussian (1.5, 7)', 'Gaussian (1.0, 5)', 'Gaussian (1.0, 11)', 'GaussianBox', 'Mean (0)', 'Mean (1)', 'Mean (8)', 'Median', 'None']);
  List<DropdownMenuItem<String>> textureSelector = LSIFunctions.setDropDownItems(['Blended', 'Grayscale', 'Wireframe']);
  List<DropdownMenuItem<String>> scatteringSelector = LSIFunctions.setDropDownItems(['Altitude', 'Linear', 'Cosine', 'CosineLayers', 'DiamondSquare', 'Particles', 'Perlin', 'PerlinAltitude', 'Simplex', 'Value', 'Weierstrass', 'Worley']);
  List<DropdownMenuItem<String>> edgeTypeSelector = LSIFunctions.setDropDownItems(['Box', 'Radial']);
  List<DropdownMenuItem<String>> edgeDirectionSelector = LSIFunctions.setDropDownItems(['Normal', 'Up', 'Down']);
  List<DropdownMenuItem<String>> edgeCurveSelector = LSIFunctions.setDropDownItems(['Linear', 'EaseIn', 'EaseOut', 'EaseInOut']);

  @override
  void initState() {
    super.initState();
    terrain = widget.terrain;
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Heightmap'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: heightmapSelector,
                  value: terrain.guiSettings['heightmap'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['heightmap'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Easing'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: easingSelector,
                  value: terrain.guiSettings['easing'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['easing'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Smoothing'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: smoothingSelector,
                  value: terrain.guiSettings['smoothing'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.applySmoothing(value, terrain.lastOptions);
                    terrain.scatterMeshes();
                    terrain.toHeightMap();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Segments'),
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
                  min: 7,
                  divisions: 120,
                  max: 127,
                  onChanged: (newRating){
                    terrain.guiSettings['segments'] = newRating;
                    terrain.regenerate();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['segments'] = newRating;
                    terrain.regenerate();
                  },
                  value: terrain.guiSettings['segments'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Steps'),
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
                  min: 1,
                  divisions: 7,
                  max: 8,
                  onChanged: (newRating){
                    terrain.guiSettings['steps'] = newRating;
                    terrain.regenerate();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['steps'] = newRating;
                    terrain.regenerate();
                  },
                  value: terrain.guiSettings['steps'],
                ),
              ),
            )
          ],
        ),
        InkWell(
          onTap: (){
            terrain.guiSettings['flightMode'] = !terrain.guiSettings['flightMode'];
            terrain.regenerate();
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Flight Mode'),
              SavedWidgets.checkBox(terrain.guiSettings['flightMode'])
            ]
          )
        ),
        
        Row(
          children: [
            const Text('Texture'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: textureSelector,
                  value: terrain.guiSettings['texture'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['texture'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Scattering'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: scatteringSelector,
                  value: terrain.guiSettings['scattering'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['scattering'] = value;
                    terrain.scatterMeshes();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Spread'),
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
                  min: 0,
                  divisions: 100,
                  max: 100,
                  onChanged: (newRating){
                    terrain.guiSettings['spread'] = newRating;
                    terrain.scatterMeshes();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['spread'] = newRating;
                    terrain.scatterMeshes();
                  },
                  value: terrain.guiSettings['spread'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('Size'),
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
                  min: 256,
                  divisions: 1204~/256,
                  max: 1024,
                  onChanged: (newRating){
                    terrain.guiSettings['size'] = newRating;
                    terrain.regenerate();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['size'] = newRating;
                    terrain.regenerate();
                  },
                  value: terrain.guiSettings['size'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('MaxHeight'),
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
                  min: 2,
                  divisions: 298,
                  max: 300,
                  onChanged: (newRating){
                    terrain.guiSettings['maxHeight'] = newRating;
                    terrain.scatterMeshes();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['maxHeight'] = newRating;
                    terrain.scatterMeshes();
                  },
                  value: terrain.guiSettings['maxHeight'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('ratio'),
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
                  min: 0.2,
                  divisions: 2~/0.05,
                  max: 2,
                  onChanged: (newRating){
                    terrain.guiSettings['ratio'] = newRating;
                    terrain.scatterMeshes();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['ratio'] = newRating;
                    terrain.scatterMeshes();
                  },
                  value: terrain.guiSettings['ratio'],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text('EdgeType'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: edgeTypeSelector,
                  value: terrain.guiSettings['edgeType'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['edgeType'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('EdgeDirection'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: edgeDirectionSelector,
                  value: terrain.guiSettings['edgeDirection'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['edgeDirection'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('EdgeCurve'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              alignment: Alignment.center,
              width: 100,
              height:20,
              padding: const EdgeInsets.only(left:10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton <dynamic>(
                  dropdownColor: Theme.of(context).canvasColor,
                  isExpanded: true,
                  items: edgeCurveSelector,
                  value: terrain.guiSettings['edgeCurve'],
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    terrain.guiSettings['edgeCurve'] = value;
                    terrain.regenerate();
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('EdgeDistance'),
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
                  min: 0,
                  divisions: 512,
                  max: 512,
                  onChanged: (newRating){
                    terrain.guiSettings['edgeDistance'] = newRating;
                    terrain.scatterMeshes();
                  },
                  onChangeEnd: (newRating) {
                    terrain.guiSettings['edgeDistance'] = newRating;
                    terrain.scatterMeshes();
                  },
                  value: terrain.guiSettings['edgeDistance'],
                ),
              ),
            )
          ],
        ),
        InkWell(
          onTap: (){
            terrain.scatterMeshes();
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.center,
            width: 100,
            height:25,
            padding: const EdgeInsets.only(left:10),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Scatter Meshes'
            ),
          )
        ),
        InkWell(
          onTap: (){
            terrain.regenerate();
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.center,
            width: 100,
            height:25,
            padding: const EdgeInsets.only(left:10),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Regenerate'
            ),
          )
        ),
      ],
    );
  }
}