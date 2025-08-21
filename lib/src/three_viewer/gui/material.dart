import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
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
  List<DropdownMenuItem<String>> materialSelector = LSIFunctions.setDropDownItems(['MeshBasicMaterial','MeshDepthMaterial','MeshNormalMaterial','MeshLambertMaterial','MeshMatcapMaterial','MeshPhongMaterial','MeshToonMaterial','MeshStandardMaterial','MeshPhysicalMaterial','RawShaderMaterial','ShaderMaterial']);
  List<DropdownMenuItem<int>> blendingSelector = [];
  List<DropdownMenuItem<int>> sideSelector = [];
  
  final materialClasses = {
    'LineBasicMaterial': three.LineBasicMaterial(),
    'LineDashedMaterial': three.LineDashedMaterial(),
    'MeshBasicMaterial': three.MeshBasicMaterial(),
    'MeshDepthMaterial': three.MeshDepthMaterial(),
    'MeshNormalMaterial': three.MeshNormalMaterial(),
    'MeshLambertMaterial': three.MeshLambertMaterial(),
    'MeshMatcapMaterial': three.MeshMatcapMaterial(),
    'MeshPhongMaterial': three.MeshPhongMaterial(),
    'MeshToonMaterial': three.MeshToonMaterial(),
    'MeshStandardMaterial': three.MeshStandardMaterial(),
    'MeshPhysicalMaterial': three.MeshPhysicalMaterial(),
    'RawShaderMaterial': three.RawShaderMaterial(),
    'ShaderMaterial': three.ShaderMaterial(),
    'ShadowMaterial': three.ShadowMaterial(),
    'SpriteMaterial': three.SpriteMaterial(),
    'PointsMaterial': three.PointsMaterial()
  };

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;

    for(int i = 0; i < 22; i++){
      mapControllers.add(TextEditingController());
      if(i < 6){
        colorControllers.add(TextEditingController());
      }

      if(i < 19){
        numControllers.add(TextEditingController());
      }
    }

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
  }

  final List<TextEditingController> mapControllers = [];
  final List<TextEditingController> colorControllers = [];
  final List<TextEditingController> numControllers = [];
  TextEditingController nameController = TextEditingController();

  void controllerReset(){
    for(int i = 0; i < 22; i++){
      mapControllers[i].clear();
      if(i < 6){
        colorControllers[i].clear();
      }

      if(i < 19){
        numControllers[i].clear();
      }
    }
    nameController.clear();
  }

  void setNewMaterial(String key){
    if(threeV.shading == ShadingType.material){
      threeV.intersected[0].material = materialClasses[key];
    }
    else{
      threeV.intersected[0].userData['mainMaterial'] = materialClasses[key] ;
    }
  }

  Widget map(String name, int c, void Function(dynamic) function){
    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${LSIFunctions.capFirstLetter(name)}:'),
            EnterTextFormField(
              readOnly: true,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              controller: mapControllers[c],
            )
          ],
        );
      },
      onAcceptWithDetails: (details) async{
        function.call(details);
      },
    );
  }

  Widget color(String name, three.Color color, double opacity, int c){
    return Row(
      children: [
        SizedBox(width:80, child: Text(LSIFunctions.capFirstLetter(name))),
        Container(width: 10,height: 20, color: Color.fromRGBO((color.red*255).toInt(), (color.green*255).toInt(), (color.blue*255).toInt(), opacity),),
        EnterTextFormField(
          label: '0x${color.getHex().toRadixString(16)}',
          width: 52,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
            if(hex != null){
              color.setFrom(three.Color.fromHex32(hex));
            }
            else{
              color.setFrom(three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32()));
            }
            setState(() {
              
            });
          },
          controller: colorControllers[c],
        )
      ],
    );
  }

  Widget number(String name, double numb, int c, void Function(double) onChange){
    return Row(
      children: [
        SizedBox(width:90, child: Text(LSIFunctions.capFirstLetter(name))),
        EnterTextFormField(
          inputFormatters: [DecimalTextInputFormatter()],
          label: numb.toString(),
          width: 52,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            onChange.call(double.parse(val));
          },
          controller: numControllers[c],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    controllerReset();
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
              controller: nameController,
            )
          ],
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
              items: materialSelector,
              value: material.runtimeType.toString(),
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                setState(() {
                  setNewMaterial(value);
                });
              },
            ),
          ),
        ),
        color('Color', material.color, material.opacity, 0),
        if(material.specular != null)color('Specular', material.specular!, 1.0, 1),
        if(material.shininess != null)number('Shininess', material.shininess!, 0, (d){material!.shininess = d;}),
        if(material.emissive != null)color('Emissive', material.emissive!, 1.0, 2),

        if(material.reflectivity != null)number('Reflectivity', material.reflectivity!, 1, (d){material!.reflectivity = d;}),
        if(material.ior != null)number('ior', material.ior!, 2, (d){material!.ior = d;}),
        number('roughness', material.roughness, 3, (d){material!.roughness = d;}),
        number('metalness', material.metalness, 4, (d){material!.metalness = d;}),
        number('clearcoat', material.clearcoat, 5, (d){material!.clearcoat = d;}),
        if(material.clearcoatRoughness != null)number('Clearcoat Roughness', material.clearcoatRoughness!, 6, (d){material!.clearcoatRoughness = d;}),
        if(material is three.MeshPhysicalMaterial)number('dispersion', material.dispersion, 7, (d){(material as three.MeshPhysicalMaterial).dispersion = d;}),
        if(material is three.MeshPhysicalMaterial)number('iridescence', material.iridescence, 8, (d){(material as three.MeshPhysicalMaterial).iridescence = d;}),
        if(material is three.MeshPhysicalMaterial)number('Reflectivity', material.iridescenceIOR, 9, (d){(material as three.MeshPhysicalMaterial).iridescenceIOR = d;}),

        number('sheen', material.sheen, 10, (d){material!.sheen = d;}),
        number('sheen Roughness', material.sheenRoughness, 11, (d){material!.sheenRoughness = d;}),
        if(material.sheenColor != null)color('sheenColor', material.sheenColor!, 1.0, 3),
        number('transmission', material.transmission, 12, (d){material!.transmission = d;}),
        if(material.attenuationDistance != null)number('attenuation Distance', material.attenuationDistance!, 13, (d){material!.attenuationDistance = d;}),
        if(material.attenuationColor != null)color('attenuationColor', material.attenuationColor!, 1.0, 4),
        if(material.thickness != null)number('thickness', material.thickness!, 14, (d){material!.thickness = d;}),
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
        SizedBox(height: 20,),
        map('map',0,(d){}),
        map('specular Map',0,(d){}),
        map('emissive Map',0,(d){}),
        map('matcap',0,(d){}),
        map('alpha Map',0,(d){}),
        map('bump Map',0,(d){}),
        map('normal Map',0,(d){}),
        map('clearcoat Map',0,(d){}),
        map('clearcoat Normal Map',0,(d){}),
        map('clearcoat Roughness Map',0,(d){}),
        map('displacement Map',0,(d){}),
        map('roughness Map',0,(d){}),
        map('metalness Map',0,(d){}),
        map('iridescence Map',0,(d){}),
        map('sheenColor Map',0,(d){}),
        map('sheenRoughness Map',0,(d){}),
        map('iridescence Thickness Map',0,(d){}),
        map('env Map',0,(d){}),
        map('light Map',0,(d){}),
        map('ao Map',0,(d){}),
        map('gradient Map',0,(d){}),
        map('transmission Map',0,(d){}),
        map('thickness Map',0,(d){}),
        SizedBox(height: 20,),

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
        number('Size', material.size ?? 0, 15, (d){material!.size = d;}),
        InkWell(
          onTap: (){
            material!.sizeAttenuation = !material.sizeAttenuation;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Size Atten\t\t\t'),
              SavedWidgets.checkBox(material.sizeAttenuation)
            ]
          )
        ),
        InkWell(
          onTap: (){
            material!.flatShading = !material.flatShading;
            material.needsUpdate = true;
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
        number('Opacity', material.opacity, 16, (d){material!.opacity = d;}),
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
        number('Alpha Test', material.alphaTest, 17, (d){material!.alphaTest = d;}),
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
        InkWell(
          onTap: (){
            material!.wireframe = !material.wireframe;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wireframe\t\t\t'),
              SavedWidgets.checkBox(material.wireframe)
            ]
          )
        ),
      ],
    );
  }
}