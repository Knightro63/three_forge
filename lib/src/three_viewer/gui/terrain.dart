import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/src/terrain.dart';

class TerrainGui extends StatefulWidget {
  const TerrainGui({Key? key, required this.terrain}):super(key: key);
  final Terrain terrain;

  @override
  _TerrainGuiState createState() => _TerrainGuiState();
}

class _TerrainGuiState extends State<TerrainGui> {
  late final Terrain terrain;

  List<DropdownMenuItem<String>> heightmapSelector = LSIFunctions.setDropDownItems(['Brownian', 'Cosine', 'CosineLayers', 'DiamondSquare', 'Fault', 'Hill', 'HillIsland', 'influences', 'Particles', 'Perlin', 'PerlinDiamond', 'PerlinLayers', 'Simplex', 'SimplexLayers', 'Value', 'Weierstrass', 'Worley']);
  List<DropdownMenuItem<String>> easingSelector = LSIFunctions.setDropDownItems(['Linear', 'EaseIn', 'EaseInWeak', 'EaseOut', 'EaseInOut', 'InEaseOut']);
  List<DropdownMenuItem<String>> smoothingSelector = LSIFunctions.setDropDownItems(['Conservative (0.5)', 'Conservative (1)', 'Conservative (10)', 'Gaussian (0.5, 7)', 'Gaussian (1.0, 7)', 'Gaussian (1.5, 7)', 'Gaussian (1.0, 5)', 'Gaussian (1.0, 11)', 'GaussianBox', 'Mean (0)', 'Mean (1)', 'Mean (8)', 'Median', 'None']);
  List<DropdownMenuItem<String>> edgeCurveSelector = LSIFunctions.setDropDownItems(['Linear', 'EaseIn', 'EaseOut', 'EaseInOut']);

  final List<TextEditingController> controllers = [
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
  void initState() {
    super.initState();
    terrain = widget.terrain;
  }
  @override
  void dispose(){
    super.dispose();
  }
  
  void controllerReset(){
    for(final c in controllers){
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Image'),
                EnterTextFormField(
                  readOnly: true,
                  label: 'Image',
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: controllers[0],
                )
              ],
            );
          },
          onAcceptWithDetails: (details){
            terrain.guiSettings['heightmap'] = details.data! as String;
          },
        ),
        const Text('Heightmap'),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
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
        const Text('Easing'),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
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
        const Text('Smoothing'),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
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
                terrain.guiSettings['smoothing'] = value;
                terrain.applySmoothing(value, terrain.lastOptions);
                terrain.toHeightMap();
                setState(() {});
              },
            ),
          ),
        ),
        const Text('Segments'),
        EnterTextFormField(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          label: terrain.guiSettings['segments'].toString(),
          width: 80,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val);
            if(hex != null && hex > 7){
              terrain.guiSettings['segments'] = hex*1.0;
            }
            else{
              terrain.guiSettings['segments'] = 7.0;
            }
            terrain.regenerate();
          },
          controller: controllers[1],
        ),
        const Text('Steps'),
        EnterTextFormField(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          label: terrain.guiSettings['steps'].toString(),
          width: 80,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val);
            if(hex != null && hex > 1){
              terrain.guiSettings['steps'] = hex*1;
            }
            else{
              terrain.guiSettings['steps'] = 1;
            }
            terrain.regenerate();
          },
          controller: controllers[2],
        ),
        InkWell(
          onTap: (){
            terrain.guiSettings['turbulent'] = !terrain.guiSettings['turbulent'];
            terrain.regenerate();
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Turbulent\t\t\t'),
              SavedWidgets.checkBox(terrain.guiSettings['turbulent'])
            ]
          )
        ),
        SizedBox(height: 10,),
        const Text('Size'),
        EnterTextFormField(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          label: terrain.guiSettings['size'].toString(),
          width: 80,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val);
            if(hex != null && hex > 256){
              terrain.guiSettings['size'] = hex;
            }
            else{
              terrain.guiSettings['size'] = 256;
            }
            terrain.regenerate();
          },
          controller: controllers[3],
        ),
        const Text('MaxHeight'),
        EnterTextFormField(
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          label: terrain.guiSettings['maxHeight'].toString(),
          width: 80,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val);
            if(hex != null && hex > 2){
              terrain.guiSettings['maxHeight'] = hex*1.0;
            }
            else{
              terrain.guiSettings['maxHeight'] = 2.0;
            }
            terrain.regenerate();
          },
          controller: controllers[4],
        ),
        const Text('Ratio'),
        EnterTextFormField(
          inputFormatters: [DecimalTextInputFormatter()],
          label: terrain.guiSettings['ratio'].toString(),
          width: 80,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final double? hex = double.tryParse(val);
            if(hex != null && hex > 1.0){
              terrain.guiSettings['ratio'] = hex*1.0;
            }
            else{
              terrain.guiSettings['ratio'] = 1.0;
            }
            terrain.regenerate();
          },
          controller: controllers[5],
        ),
        const Text('EdgeCurve'),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
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
        InkWell(
          onTap: (){
            terrain.regenerate();
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.center,
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