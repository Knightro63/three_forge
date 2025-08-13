import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_modifers/loop_subdivision.dart';
import 'package:three_js_modifers/simplify_modifer.dart';

class ModiferGui extends StatefulWidget {
  const ModiferGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _ModiferGuiState createState() => _ModiferGuiState();
}

class _ModiferGuiState extends State<ModiferGui> {
  late final ThreeViewer threeV;
  bool subdivisionCC = true;
  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    super.dispose();
  }

  final TextEditingController modiferController = TextEditingController();

  void subdivision(three.Object3D object){
    final smoothGeometry = LoopSubdivision.modify(
      object.userData['origionalGeometry'], 
      object.userData['subdivisions'], 
      LoopParameters(
        split: true,
        uvSmooth: false,
        preserveEdges: false,
        flatOnly: !subdivisionCC,
      )
    );

    object.geometry = smoothGeometry;
  }

  void simplify(three.Object3D object, double percent){
    int count = ( object.geometry?.attributes['position'].count * percent/100 ).floor();
    SimplifyModifier.modify( object.geometry!, count );
  }

  @override
  Widget build(BuildContext context) {
    modiferController.clear();
    three.Object3D intersected = threeV.intersected!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subdivision'),
        Row(
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  subdivisionCC = true;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0,5,0,5),
                height: 17,
                width: 65,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: subdivisionCC?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(5),
                  //border: Border.all(color: CSS.darkTheme.secondaryHeaderColor)
                ),
                child: Text(
                  'Catmull',
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                ),
              ),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  subdivisionCC = false;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0,5,0,5),
                //padding: const EdgeInsets.all(5),
                height: 17,
                width: 65,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !subdivisionCC?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(5),
                  //border: Border.all(color: CSS.darkTheme.secondaryHeaderColor)
                ),
                child: Text(
                  'Simple',
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                ),
              ),
            )
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Levels: '),
            InkWell(
              onTap: (){
                setState(() {
                  if(intersected.userData['subdivisions'] != null && intersected.userData['subdivisions'] > 0){
                    intersected.userData['subdivisions'] -= 1;
                  }
                  else if(intersected.userData['subdivisions'] == null){
                    intersected.userData['subdivisions'] = 0;
                  }

                  subdivision(intersected);
                });
              },
              child: const Icon(Icons.arrow_back_ios_new_rounded,size:10),
            ),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              label: (intersected.userData['subdivisions'] ?? 0).toString(),
              width: 45,
              height: 20,
              maxLines: 1,
              margin: const EdgeInsets.all(0),
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                intersected.userData['subdivisions'] = val;
              },
              controller: modiferController,
            ),
            InkWell(
              onTap: (){
                setState(() {
                  intersected.userData['origionalGeometry'] ??= intersected.geometry?.clone();

                  if(intersected.userData['subdivisions'] != null){
                    intersected.userData['subdivisions'] += 1;
                  }
                  else if(intersected.userData['subdivisions'] == null){
                    intersected.userData['subdivisions'] = 1;
                  }

                  subdivision(intersected);
                });
              },
              child: const Icon(Icons.arrow_forward_ios_rounded,size:10),
            )
          ],
        )
      ],
    );
  }
}