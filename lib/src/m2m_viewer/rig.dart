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
  double scale = 1.0;
  Mesh2Motion get m2m => widget.threeV.m2m;
  List<DropdownMenuItem<String?>> get rigSelector => m2m.rigSelector;
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
    final width = MediaQuery.of(context).size.width*.2-56;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          //width: width,
          height: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: m2m.reference !=null?Image.file(m2m.reference!):null,
        ),
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
                    width: width/3,
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
                    width: width/3,
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
                    width: width/3,
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
                  margin: EdgeInsets.fromLTRB(5,0,0,0),
                  padding: EdgeInsets.fromLTRB(5, 10, 0, 10),
                  width: width-10,
                  height: 25,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  onChanged: (val){
                    this.scale = double.tryParse(val) ?? 0;
                    m2m.scale(scale);
                  },
                  controller: scaleControllers..text = scale.toString(),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
              alignment: Alignment.center,
              height:25,
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
                  value: selectedRig?.name,
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
          ]
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                m2m.changeMirror();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                alignment: Alignment.center,
                height:25,
                padding: const EdgeInsets.only(left:10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mirror Left/Right Joints:\t\t\t'),
                    SavedWidgets.checkBox(m2m.mirror)
                  ]
                )
              )
            ),
            InkWell(
              onTap: (){
                //m2m.changedModelPreviewDisplay();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                alignment: Alignment.center,
                height:25,
                padding: const EdgeInsets.only(left:10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Move Bone Independently:\t\t\t'),
                    SavedWidgets.checkBox(m2m.isTexture)
                  ]
                )
              )
            ),
            InkWell(
              onTap: (){
                m2m.changedModelPreviewDisplay();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                alignment: Alignment.center,
                height:25,
                padding: const EdgeInsets.only(left:10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Weight Painted:\t\t\t'),
                    SavedWidgets.checkBox(!m2m.isTexture)
                  ]
                )
              )
            ),
            InkWell(
              onTap: (){
                m2m.changeHeadWeightCorrection();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                alignment: Alignment.center,
                height:25,
                padding: const EdgeInsets.only(left:10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Use Weight Correction:\t\t\t'),
                    SavedWidgets.checkBox(m2m.useHeadWeightCorrection)
                  ]
                )
              )
            ),
          ]
        ),
        Column(
          children: [
            InkWell(
              onTap: (){
                //widget.threeV.changeScene(ForgeScene.main);
              },
              child: Container(
                //width: 65,
                height: 25,
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text('Save'),
              )
            ),
            InkWell(
              onTap: (){
                widget.threeV.changeScene(ForgeScene.main);
              },
              child: Container(
                //width: 65,
                height: 25,
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text('Exit'),
              )
            ),
          ],
        )
      ]
    );
  }
}