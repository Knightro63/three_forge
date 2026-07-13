import 'package:flutter/material.dart';
import 'package:three_forge/src/enums.dart';
import 'package:three_forge/src/m2m_viewer/m2m.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class AnimateGui extends StatefulWidget {
  const AnimateGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _AnimateGuiState createState() => _AnimateGuiState();
}

class _AnimateGuiState extends State<AnimateGui> {
  Mesh2Motion get m2m => widget.threeV.m2m;
  three.Object3D? get selectedRig => m2m.armature;

  final TextEditingController scaleControllers = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width*.2-56;
    final List vids = m2m.animationVideos('human', width, context, scaleControllers.text);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Search:'),
          EnterTextFormField(
            inputFormatters: [DecimalTextInputFormatter()],
            //label: 
            margin: EdgeInsets.fromLTRB(5,0,0,0),
            padding: EdgeInsets.fromLTRB(5, 10, 0, 10),
            width: width-10,
            height: 25,
            maxLines: 1,
            textStyle: Theme.of(context).primaryTextTheme.bodySmall,
            color: Theme.of(context).canvasColor,
            onChanged: (val){
              // this.scale = double.tryParse(val) ?? 0;
              // m2m.scale(scale);
              setState(() {
                
              });
            },
            controller: scaleControllers,
          )
        ],
      ),
        SizedBox(
          height: size.height-100, // Restrain the height of your horizontal list
          child: GridView.builder(
            itemCount: vids.length,
            cacheExtent: 20.0, // Pre-loads items slightly off-screen
            // Grid configuration that acts like a wrapping layout
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, // Maximum width of a video card before wrapping
              mainAxisSpacing: 10.0,   // Spacing between rows
              crossAxisSpacing: 10.0,  // Spacing between columns
              childAspectRatio: 9/12, // Forces standard video widescreen dimensions
            ),
            itemBuilder: (BuildContext context, int index) {
              final videoData = vids[index];
              
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: videoData,
              );
            },
          ),
        ),
        InkWell(
          onTap: (){
            widget.threeV.changeScene(ForgeScene.main);
          },
          child: Container(
            //width: 65,
            height: 25,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text('Exit'),
          )
        ),
      ]
    );
  }
}