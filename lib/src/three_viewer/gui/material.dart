import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class MaterialGui extends StatefulWidget {
  const MaterialGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _MaterialGuiState createState() => _MaterialGuiState();
}

class _MaterialGuiState extends State<MaterialGui> {
  late final ThreeViewer threeV;
  List<DropdownMenuItem<int>> blendingSelector = [];
  List<DropdownMenuItem<int>> sideSelector = [];

  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
    sideSelector.add(DropdownMenuItem(
      value: three.FrontSide,
      child: Text(
        'FrontSide', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    sideSelector.add(DropdownMenuItem(
      value: three.BackSide,
      child: Text(
        'BackSide', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    sideSelector.add(DropdownMenuItem(
      value: three.DoubleSide,
      child: Text(
        'DoubleSide', 
        overflow: TextOverflow.ellipsis,
      )
    ));


    blendingSelector.add(DropdownMenuItem(
      value: three.NoBlending,
      child: Text(
        'NoBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    blendingSelector.add(DropdownMenuItem(
      value: three.NormalBlending,
      child: Text(
        'NormalBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    blendingSelector.add(DropdownMenuItem(
      value: three.AdditiveBlending,
      child: Text(
        'AdditiveBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    blendingSelector.add(DropdownMenuItem(
      value: three.SubtractiveBlending,
      child: Text(
        'SubtractiveBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    blendingSelector.add(DropdownMenuItem(
      value: three.MultiplyBlending,
      child: Text(
        'MultiplyBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    blendingSelector.add(DropdownMenuItem(
      value: three.CustomBlending,
      child: Text(
        'CustomBlending', 
        overflow: TextOverflow.ellipsis,
      )
    ));
  }
  @override
  void dispose(){
    super.dispose();
    transfromControllers.clear();
  }

  void transformControllersReset(){
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
    three.Material? material = threeV.intersected[0].userData['mainMaterial'];

    if(threeV.shading == ShadingType.material){
      material = threeV.intersected[0].material;
    }

    const double d = 57;
    double d2 = 65;
    return material == null?Container():Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width:d, child: const Text('Name')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: material.name.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                material!.name = val;
              },
              controller: transfromControllers[1],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d-10, child: const Text('Color')),
            Container(width: 10,height: 20,color: Color.fromRGBO((material.color.red*255).toInt(), (material.color.green*255).toInt(), (material.color.blue*255).toInt(), material.opacity),),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: '0x${material.color.getHex().toRadixString(16)}',
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  material!.color = three.Color.fromHex32(hex);
                }
                else{
                  material!.color = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: transfromControllers[0],
            )
          ],
        ),
        InkWell(
          onTap: (){
            material!.vertexColors = !material.vertexColors;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vertex Colors\t\t\t'),
              SavedWidgets.checkBox(material.vertexColors)
            ]
          )
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
          //width: 100,
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
              items: sideSelector,
              value: material.side,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                setState(() {
                  material!.side = value;
                });
              },
            ),
          ),
        ),
        InkWell(
          onTap: (){
            material!.flatShading = !material.flatShading;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Flat Shading\t\t\t'),
              SavedWidgets.checkBox(material.flatShading)
            ]
          )
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
          //width: 100,
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
              items: blendingSelector,
              value: material.blending,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                setState(() {
                  material!.blending = value;
                });
              },
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Opacity')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: material.opacity.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                material!.opacity = double.parse(val);
                setState(() {});
              },
              controller: transfromControllers[5],
            )
          ],
        ),
        InkWell(
          onTap: (){
            material!.transparent = !material.transparent;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transparent\t\t\t'),
              SavedWidgets.checkBox(material.transparent)
            ]
          )
        ),
        InkWell(
          onTap: (){
            material!.forceSinglePass = !material.forceSinglePass;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Force SP\t\t\t'),
              SavedWidgets.checkBox(material.forceSinglePass)
            ]
          )
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Alpha Test')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: material.alphaTest.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                material!.alphaTest = double.parse(val);
              },
              controller: transfromControllers[6],
            )
          ],
        ),
        InkWell(
          onTap: (){
            material!.depthTest = !material.depthTest;
            setState(() {
              
            });
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Depth Test\t\t\t'),
              SavedWidgets.checkBox(material.depthTest)
            ]
          )
        ),
        InkWell(
          onTap: (){
            material!.depthWrite = !material.depthWrite;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Depth Write\t\t\t'),
              SavedWidgets.checkBox(material.depthWrite)
            ]
          )
        ),
      ],
    );
  }
}