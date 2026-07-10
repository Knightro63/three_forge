import 'package:flutter/material.dart';
import 'package:three_forge/src/enums.dart';
import 'package:three_forge/src/m2m_viewer/m2m.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class RigGui extends StatefulWidget {
  const RigGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _RigGuiState createState() => _RigGuiState();
}

class _RigGuiState extends State<RigGui> {
  Mesh2Motion get m2m => widget.threeV.m2m;
  List<DropdownMenuItem<three.Object3D?>> get rigSelector => m2m.rigSelector;
  three.Object3D? get selectedRig => m2m.selectedRig;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    m2m.rotateX();
                  },
                  child: Container(
                    width: 45,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text('X'),
                  )
                ),
                InkWell(
                  onTap: (){
                    m2m.rotateY();
                  },
                  child: Container(
                    width: 45,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text('Y'),
                  )
                ),
                InkWell(
                  onTap: (){
                    m2m.rotateZ();
                  },
                  child: Container(
                    width: 45,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text('Z'),
                  )
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Scale:'),
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
                    m2m.animationObject?.scale.setValues(scale,scale,scale);
                  },
                  controller: scaleControllers..text =  m2m.animationObject?.scale.x.toString() ?? '0.0',
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
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
                  items: rigSelector,
                  value: selectedRig,
                  isDense: true,
                  focusColor: Theme.of(context).secondaryHeaderColor,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                  onChanged:(value){
                    m2m.selected(value);
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
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