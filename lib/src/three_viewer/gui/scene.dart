import 'package:flutter/material.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/objects/insert_models.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

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
  late final InsertModels insertModel;
  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
    insertModel = InsertModels(threeV);
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
        InkWell(
          onTap: (){
            threeV.threeJs.renderer?.antialias = !threeV.threeJs.renderer!.antialias;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Antialias\t\t\t'),
              SavedWidgets.checkBox(threeV.threeJs.renderer!.antialias)
            ]
          )
        ),
        Row(
          children: [
            const Text('Color'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  threeV.execute(
                    MultiCmdsCommand(threeV,[
                      SetValueCommand(threeV, threeV.scene, 'background', hex)..allowDispatch=false,
                      SetValueCommand(threeV, threeV.threeJs.scene, 'background', hex)..allowDispatch=false
                    ])
                  );
                  threeV.scene.background = three.Color.fromHex32(hex);
                  threeV.threeJs.scene.background = three.Color.fromHex32(hex);
                }
                else{
                 threeV.execute(
                    MultiCmdsCommand(threeV,[
                      SetValueCommand(threeV, threeV.scene, 'background', Theme.of(context).canvasColor.toARGB32())..allowDispatch=false,
                      SetValueCommand(threeV, threeV.threeJs.scene, 'background', Theme.of(context).canvasColor.toARGB32())..allowDispatch=false
                    ])
                  );
                  threeV.scene.background = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                  threeV.threeJs.scene.background = three.Color.fromHex64(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: sceneControllers[0]..text = threeV.scene.background is three.Color?'0x'+(threeV.scene.background as three.Color).getHex().toRadixString(16):'',
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
            insertModel.insertTexture(details.data! as String, mappingValue,sameastext);
          },
        ),
        InkWell(
          onTap: (){
            sameastext = !sameastext;
            insertModel.setAsSame(sameastext);
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
            insertModel.insertTexture(details.data! as String, mappingValue,sameastext);
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
              //label: threeV.scene.backgroundIntensity.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val) ?? 1;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'backgroundIntensity', v)..allowDispatch=false);
                threeV.scene.backgroundIntensity = v;
              },
              controller: sceneControllers[3]..text = threeV.scene.backgroundIntensity.toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Env    '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.scene.environmentIntensity.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val) ?? 1;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'environmentIntensity', v)..allowDispatch=false);
                threeV.scene.environmentIntensity = v;
              },
              controller: sceneControllers[4]..text = threeV.scene.environmentIntensity.toString(),
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
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'backgroundRotation', three.Euler(v))..allowDispatch=false);
                threeV.scene.backgroundRotation.x = v;
              },
              controller: sceneControllers[5]..text = threeV.scene.backgroundRotation.x.toDeg().toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.scene.backgroundRotation.y.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'backgroundRotation', three.Euler(threeV.scene.backgroundRotation.x,v))..allowDispatch=false);
                threeV.scene.backgroundRotation.y = v;
              },
              controller: sceneControllers[6]..text = threeV.scene.backgroundRotation.y.toDeg().toString(),
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.scene.backgroundRotation.z.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'backgroundRotation', three.Euler(threeV.scene.backgroundRotation.x,threeV.scene.backgroundRotation.y,v))..allowDispatch=false);
                threeV.scene.backgroundRotation.z = v;
              },
              controller: sceneControllers[7]..text = threeV.scene.backgroundRotation.z.toDeg().toString(),
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
              //label: threeV.scene.environmentRotation.x.toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'environmentRotation', three.Euler(v))..allowDispatch=false);
                threeV.scene.environmentRotation.x = v;
              },
              controller: sceneControllers[6]..text = threeV.scene.environmentRotation.x.toDeg().toString(),
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
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'environmentRotation', three.Euler(threeV.scene.environmentRotation.x,v))..allowDispatch=false);
                threeV.scene.environmentRotation.y = v;
              },
              controller: sceneControllers[8]..text = threeV.scene.environmentRotation.x.toDeg().toString(),
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
                final v = double.tryParse(val)?.toRad() ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.scene, 'environmentRotation', three.Euler(threeV.scene.environmentRotation.x,threeV.scene.environmentRotation.y,v))..allowDispatch=false);
                threeV.scene.environmentRotation.z = v;
              },
              controller: sceneControllers[9]..text = threeV.scene.environmentRotation.x.toDeg().toString(),
            )
          ],
        ),

        const SizedBox(height: 10,),
        InkWell(
          onTap: (){
            fog = !fog;
            if(!fog){
              threeV.execute(SetValueCommand(threeV, threeV.scene, 'fog', null));
              threeV.scene.fog = null;
            }
            else{
              threeV.execute(SetValueCommand(threeV, threeV.scene, 'fog', threeV.fog));
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
              //label: threeV.scene.fog != null?'0x'+threeV.scene.fog!.color.getHex().toRadixString(16):'',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int? hex = int.tryParse(val.replaceAll('0x', ''),radix: 16);
                if(hex != null){
                  threeV.execute(SetFogValueCommand(threeV, threeV.scene.fog, 'color', hex)..allowDispatch = false);
                  threeV.scene.fog!.color.setFromHex32(hex);
                }
                else{
                  threeV.execute(SetFogValueCommand(threeV, threeV.scene.fog, 'color', Theme.of(context).canvasColor.toARGB32())..allowDispatch = false);
                  threeV.scene.fog!.color.setFromHex32(Theme.of(context).canvasColor.toARGB32());
                }
              },
              controller: sceneControllers[10]..text = threeV.scene.fog != null?'0x'+threeV.scene.fog!.color.getHex().toRadixString(16):'',
            )
          ],
        ),
        Row(
          children: [
            const Text('Near '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.scene.fog?.near.toString() ?? '',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                if(threeV.scene.fog != null){
                  final double hex = double.tryParse(val) ?? 10;
                  threeV.execute(SetFogValueCommand(threeV, threeV.scene.fog, 'near', hex)..allowDispatch = false);
                  threeV.scene.fog?.near = hex;
                }
              },
              controller: sceneControllers[11]..text = threeV.scene.fog?.near.toString() ?? '',
            )
          ],
        ),
        Row(
          children: [
            const Text('Far    '),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              //label: threeV.scene.fog?.far.toString() ?? '',
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                if(threeV.scene.fog != null){
                  final double hex = double.tryParse(val) ?? 10;
                  threeV.execute(SetFogValueCommand(threeV, threeV.scene.fog, 'far', hex)..allowDispatch = false);
                  threeV.scene.fog?.far = hex;
                }
              },
              controller: sceneControllers[12]..text = threeV.scene.fog?.far.toString() ?? '',
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