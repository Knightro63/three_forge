import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'dart:math' as math;

class SceneGui extends StatefulWidget {
  const SceneGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _SceneGuiState createState() => _SceneGuiState();
}

class _SceneGuiState extends State<SceneGui> {
  late final ThreeViewer threeV;
  bool sameastext = true;
  bool fog = false;
  List<DropdownMenuItem<int>> mappingSelector = [];
  int mappingValue = three.EquirectangularReflectionMapping;
  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
    fog = threeV.scene.fog != null;
    sameastext = threeV.threeJs.scene.userData['sameTexture'] ?? true;
    mappingSelector.add(DropdownMenuItem(
      value: three.UVMapping,
      child: Text(
        'UVMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    mappingSelector.add(DropdownMenuItem(
      value: three.CubeReflectionMapping,
      child: Text(
        'CubeReflectionMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    mappingSelector.add(DropdownMenuItem(
      value: three.CubeRefractionMapping,
      child: Text(
        'CubeRefractionMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    mappingSelector.add(DropdownMenuItem(
      value: three.EquirectangularReflectionMapping,
      child: Text(
        'EquirectangularReflectionMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    mappingSelector.add(DropdownMenuItem(
      value: three.EquirectangularRefractionMapping,
      child: Text(
        'EquirectangularRefractionMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
    mappingSelector.add(DropdownMenuItem(
      value: three.CubeUVReflectionMapping,
      child: Text(
        'CubeUVReflectionMapping', 
        overflow: TextOverflow.ellipsis,
      )
    ));
  }
  @override
  void dispose(){
    super.dispose();
    sceneControllers.clear();
  }

  void controllersReset(){
    for(final controllers in sceneControllers){
      controllers.clear();
    }
  }

  void setAsSame(){
    threeV.threeJs.scene.userData['sameTexture'] = sameastext;
    if(sameastext){
      threeV.threeJs.scene.environment = threeV.threeJs.scene.background;
      threeV.scene.environment = threeV.threeJs.scene.background;
    }
    else{
      threeV.threeJs.scene.environment = null;
      threeV.scene.environment = null;
    }
  }

  Future<void> insertTexture(String path) async{
    String fileType = path.split('.').last;
    String name = path.split('/').last;
    String dirPath = path.replaceAll(name, '');
    
    if(fileType == 'hdr'){
      final three.DataTexture rgbeLoader = await three.RGBELoader().setPath( dirPath ).fromAsset(name);
      rgbeLoader.userData['path'] = path;
      rgbeLoader.mapping = mappingValue;
      threeV.threeJs.scene.background = rgbeLoader;
      threeV.scene.background = rgbeLoader;
      threeV.threeJs.scene.backgroundRotation = three.Euler(math.pi);
      threeV.scene.backgroundRotation = three.Euler(math.pi);
      setAsSame();
    }
    else if(fileType == 'gltf'){
      final cubeRenderTarget = three.WebGLCubeRenderTarget( 256 );
      final cubeCamera = three.CubeCamera( 1, 1000, cubeRenderTarget );

      // envmap
      List<String> genCubeUrls( prefix, postfix ) {
        return [
          prefix + 'px' + postfix, prefix + 'nx' + postfix,
          '${prefix}ny$postfix', '${prefix}py$postfix',
          prefix + 'pz' + postfix, prefix + 'nz' + postfix
        ];
      }

      final urls = genCubeUrls( dirPath, '.jpg' );

      three.CubeTextureLoader(flipY: true).fromAssetList(urls).then(( cubeTexture ) {
        threeV.threeJs.scene.background = cubeTexture;
        threeV.scene.background = cubeTexture;
        cubeTexture?.userData['path'] = path;
        setAsSame();
        cubeCamera.update( threeV.threeJs.renderer!, threeV.threeJs.scene );
      });
    }
  }

  final List<TextEditingController> sceneControllers = [
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
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    controllersReset();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Color'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.background is three.Color?'0x'+(threeV.scene.background as three.Color).getHex().toRadixString(16):'',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  print(hex);
                  threeV.scene.background = three.Color.fromHex32(hex);
                }
                else{
                  threeV.scene.background = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: sceneControllers[0],
            )
          ],
        ),
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Row(
              children: [
                const Text('Text  '),
                EnterTextFormField(
                  readOnly: true,
                  inputFormatters: [DecimalTextInputFormatter()],
                  label: threeV.scene.background is three.Texture?'Texture':'',
                  width: 80,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: sceneControllers[1],
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            insertTexture(details.data! as String);
          },
        ),
        InkWell(
          onTap: (){
            sameastext = !sameastext;
            setAsSame();
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Use Same Env\t\t\t'),
              SavedWidgets.checkBox(sameastext)
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
              items: mappingSelector,
              value: mappingValue,//ddInfo[i],
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                setState(() {
                  mappingValue = value;
                  if(threeV.threeJs.scene.background is three.Texture){
                    threeV.threeJs.scene.background.mapping = mappingValue == 0?null:mappingValue;
                    threeV.scene.background.mapping = mappingValue == 0?null:mappingValue;
                  }
                });
              },
            ),
          ),
        ),
        if(!sameastext)DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Row(
              children: [
                const Text('Env   '),
                EnterTextFormField(
                  readOnly: true,
                  label: threeV.scene.environment is three.Texture?'Texture':'',
                  width: 80,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: sceneControllers[2],
                )
              ],
            );
          },
          onAcceptWithDetails: (details){
            insertTexture(details.data! as String);
          },
        ),
        const SizedBox(height: 10,),
        const Text('Intensity'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('Text   '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.backgroundIntensity.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.backgroundIntensity = double.parse(val);
              },
              controller: sceneControllers[3],
            )
          ],
        ),
        Row(
          children: [
            const Text('Env    '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.environmentIntensity.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.environmentIntensity = double.parse(val);
              },
              controller: sceneControllers[4],
            )
          ],
        ),

        const SizedBox(height: 10,),
        const Text('Text Rot'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.backgroundRotation.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.backgroundRotation.x = double.parse(val);
              },
              controller: sceneControllers[5],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.backgroundRotation.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.backgroundRotation.y = double.parse(val);
              },
              controller: sceneControllers[6],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.backgroundRotation.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.backgroundRotation.z = double.parse(val);
              },
              controller: sceneControllers[7],
            )
          ],
        ),
      
        const SizedBox(height: 10,),
        const Text('Env Rot'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.environmentRotation.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.environmentRotation.x = double.parse(val);
              },
              controller: sceneControllers[6],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.environmentRotation.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.environmentRotation.y = double.parse(val);
              },
              controller: sceneControllers[8],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.environmentRotation.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                threeV.scene.environmentRotation.z = double.parse(val);
              },
              controller: sceneControllers[9],
            )
          ],
        ),

        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            fog = !fog;
            if(!fog){
              threeV.scene.fog = null;
            }
            else{
              threeV.scene.fog = threeV.fog;
            }
            setState(() {
              
            });
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fog\t\t\t'),
              SavedWidgets.checkBox(fog)
            ]
          )
        ),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('Color'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.fog != null?'0x'+threeV.scene.fog!.color.getHex().toRadixString(16):'',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  print(hex);
                  threeV.scene.fog!.color.setFromHex32(hex);
                }
                else{
                  threeV.scene.fog!.color.setFromHex32(Theme.of(context).canvasColor.value);
                }
              },
              controller: sceneControllers[10],
            )
          ],
        ),
        Row(
          children: [
            const Text('Near '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.fog?.near.toString() ?? '',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double hex = double.tryParse(val) ?? 10;
                threeV.scene.fog?.near = hex;
              },
              controller: sceneControllers[11],
            )
          ],
        ),
        Row(
          children: [
            const Text('Far    '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              label: threeV.scene.fog?.far.toString() ?? '',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double hex = double.tryParse(val) ?? 10;
                threeV.scene.fog?.far = hex;
              },
              controller: sceneControllers[12],
            )
          ],
        ),
        const SizedBox(height: 10,),
        const Text('Add'),
        const SizedBox(height: 5,),
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Row(
              children: [
                const Text('Audio'),
                EnterTextFormField(
                  readOnly: true,
                  label: threeV.scene.userData['audio'] ?? 'Audio',
                  width: 80,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: sceneControllers[13],
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            threeV.scene.userData['audio'] = details.data;
          },
        ),
      ],
    );
  }
}