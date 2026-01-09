import 'package:flutter/material.dart';
import 'package:three_forge/src/history/commands.dart';
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
    'PointsMaterial': three.PointsMaterial(),
    // 'HexTilingMaterial': three.HexTilingMaterial(),
    // 'ProjectedMaterial': three.ProjectedMaterial(),
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

  void setNewMaterial(three.Material? material, three.Material? newMaterial){
    if(threeV.shading == ShadingType.material){
      material = newMaterial;
    }
    else{
      material = newMaterial;
    }
  }

  Future<three.Texture?> setNewTexture(String path) async{
    return await three.TGALoader().fromPath(path)?..name = path.split('/').last.split('.').first;
  }

  Widget map(String name, String? temp, int c, void Function(dynamic) function){
    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${LSIFunctions.capFirstLetter(name)}:'),
            Row(children: [
              EnterTextFormField(
                width: 120,
                readOnly: true,
                label: temp,
                height: 20,
                maxLines: 1,
                textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                color: Theme.of(context).canvasColor,
                controller: mapControllers[c],
              ),
              InkWell(
                onTap: (){
                  function.call('delete');
                },
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(Icons.clear,size: 15,)
                ),
              )
            ],)
          ],
        );
      },
      onAcceptWithDetails: (details) async{
        function.call(details.data);
      },
    );
  }

  Widget color(String name, three.Color color, double opacity, int c){
    return Row(
      children: [
        SizedBox(width:80, child: Text(LSIFunctions.capFirstLetter(name))),
        Container(width: 10,height: 20, color: Color.fromRGBO((color.red*255).toInt(), (color.green*255).toInt(), (color.blue*255).toInt(), opacity),),
        EnterTextFormField(
          //label: '0x${color.getHex().toRadixString(16)}',
          width: 52,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            final int? hex = int.tryParse(val.replaceAll('0x', '').replaceAll('x', ''),radix: 16);
            String nn = LSIFunctions.matString(name);
            if(hex != null){
              threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], nn, hex)..allowDispatch=false);
              color.setFrom(three.Color.fromHex32(hex));
            }
            else{
              threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], nn, Theme.of(context).canvasColor.toARGB32())..allowDispatch=false);
              color.setFrom(three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32()));
            }
            //setState(() {});
          },
          controller: colorControllers[c]..text = '0x${color.getHex().toRadixString(16)}',
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
          //label: numb.toString(),
          width: 52,
          height: 20,
          maxLines: 1,
          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
          color: Theme.of(context).canvasColor,
          onChanged: (val){
            double v = double.tryParse(val) ?? 0;
            String nn = LSIFunctions.matString(name);
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], nn, v)..allowDispatch=false);
            onChange.call(v);
          },
          controller: numControllers[c]..text = numb.toString(),
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
                threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'name', val)..allowDispatch=false);
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
                  final mat = materialClasses[value];
                  threeV.execute(SetMaterialCommand(threeV, threeV.intersected[0], mat)..allowDispatch=false);
                  setNewMaterial(material, mat);
                  threeV.intersected[0].userData['mainMaterial'] = mat;
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
        map('map', material.map?.name,0,(d){if(d == 'delete'){material?.map = null;}else{setNewTexture(d).then((t){material?.map = t;});}}),
        map('specular Map',material.specularMap?.name,00,(d){if(d == 'delete'){material?.specularMap = null;}else{setNewTexture(d).then((t){material?.specularMap = t;});}}),
        map('emissive Map',material.emissiveMap?.name,0,(d){if(d == 'delete'){material?.emissiveMap = null;}else{setNewTexture(d).then((t){material?.emissiveMap = t;});}}),
        //map('matcap',material.map?.name,0,(d){material.map = null;}),
        map('alpha Map',material.alphaMap?.name,0,(d){if(d == 'delete'){material?.alphaMap = null;}else{setNewTexture(d).then((t){material?.alphaMap = t;});}}),
        map('bump Map',material.bumpMap?.name,0,(d){if(d == 'delete'){material?.bumpMap = null;}else{setNewTexture(d).then((t){material?.bumpMap = t;});}}),
        map('normal Map',material.normalMap?.name,0,(d){if(d == 'delete'){material?.normalMap = null;}else{setNewTexture(d).then((t){material?.normalMap = t;});}}),
        map('clearcoat Map',material.clearcoatMap?.name,0,(d){if(d == 'delete'){material?.clearcoatMap = null;}else{setNewTexture(d).then((t){material?.clearcoatMap = t;});}}),
        map('clearcoat Normal Map',material.clearcoatNormalMap?.name,0,(d){if(d == 'delete'){material?.clearcoatNormalMap = null;}else{setNewTexture(d).then((t){material?.clearcoatNormalMap = t;});}}),
        map('clearcoat Roughness Map',material.clearcoatRoughnessMap?.name,0,(d){if(d == 'delete'){material?.clearcoatRoughnessMap = null;}else{setNewTexture(d).then((t){material?.clearcoatRoughnessMap = t;});}}),
        map('displacement Map',material.displacementMap?.name,0,(d){if(d == 'delete'){material?.displacementMap = null;}else{setNewTexture(d).then((t){material?.displacementMap = t;});}}),
        map('roughness Map',material.roughnessMap?.name,0,(d){if(d == 'delete'){material?.roughnessMap = null;}else{setNewTexture(d).then((t){material?.roughnessMap = t;});}}),
        map('metalness Map',material.metalnessMap?.name,0,(d){if(d == 'delete'){material?.metalnessMap = null;}else{setNewTexture(d).then((t){material?.metalnessMap = t;});}}),
        map('iridescence Map',material.iridescenceMap?.name,0,(d){if(d == 'delete'){material?.iridescenceMap = null;}else{setNewTexture(d).then((t){material?.iridescenceMap = t;});}}),
        map('sheenColor Map',material.sheenColorMap?.name,0,(d){if(d == 'delete'){material?.sheenColorMap = null;}else{setNewTexture(d).then((t){material?.sheenColorMap = t;});}}),
        map('sheenRoughness Map',material.sheenRoughnessMap?.name,0,(d){if(d == 'delete'){material?.sheenRoughnessMap = null;}else{setNewTexture(d).then((t){material?.sheenRoughnessMap = t;});}}),
        map('iridescence Thickness Map',material.iridescenceThicknessMap?.name,0,(d){if(d == 'delete'){material?.iridescenceThicknessMap = null;}else{setNewTexture(d).then((t){material?.iridescenceThicknessMap = t;});}}),
        map('env Map',material.envMap?.name,0,(d){if(d == 'delete'){material?.envMap = null;}else{setNewTexture(d).then((t){material?.envMap = t;});}}),
        map('light Map',material.lightMap?.name,0,(d){if(d == 'delete'){material?.lightMap = null;}else{setNewTexture(d).then((t){material?.lightMap = t;});}}),
        map('ao Map',material.aoMap?.name,0,(d){if(d == 'delete'){material?.aoMap = null;}else{setNewTexture(d).then((t){material?.aoMap = t;});}}),
        map('gradient Map',material.gradientMap?.name,0,(d){if(d == 'delete'){material?.gradientMap = null;}else{setNewTexture(d).then((t){material?.gradientMap = t;});}}),
        map('transmission Map',material.transmissionMap?.name,0,(d){if(d == 'delete'){material?.transmissionMap = null;}else{setNewTexture(d).then((t){material?.transmissionMap = t;});}}),
        map('thickness Map',material.thicknessMap?.name,0,(d){if(d == 'delete'){material?.thicknessMap = null;}else{setNewTexture(d).then((t){material?.thicknessMap = t;});}}),
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
                  threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'side', value));
                  material!.side = value;
                });
              },
            ),
          ),
        ),
        number('Size', material.size ?? 0, 15, (d){material!.size = d;}),
        InkWell(
          onTap: (){
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'sizeAttenuation', !material!.sizeAttenuation));
            material.sizeAttenuation = !material.sizeAttenuation;
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
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'flatShading', !material!.flatShading));
            material.flatShading = !material.flatShading;
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
                  threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'blending', value));
                  material!.blending = value;
                });
              },
            ),
          ),
        ),
        number('Opacity', material.opacity, 16, (d){material!.opacity = d;}),
        InkWell(
          onTap: (){
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'transparent', !material!.transparent));
            material.transparent = !material.transparent;
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
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'forceSinglePass', material.forceSinglePass));
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
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'depthTest', material.depthTest));
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
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'depthWrite', !material!.depthWrite));
            material.depthWrite = !material.depthWrite;
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
            threeV.execute(SetMaterialValueCommand(threeV, threeV.intersected[0], 'wireframe', !material!.wireframe));
            material.wireframe = !material.wireframe;
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