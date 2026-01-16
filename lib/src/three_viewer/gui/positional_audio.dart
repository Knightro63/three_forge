import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/gui/audio.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js_exporters/three_js_exporters.dart';
import 'package:three_js_video_texture/video_audio.dart';
import 'package:three_js/three_js.dart' as three;

class PositionalAudioGui extends StatefulWidget {
  const PositionalAudioGui({Key? key, required this.audio, required this.threeV}):super(key: key);
  final ThreeViewer threeV;
  final three.PositionalAudio audio;

  @override
  _PositionalAudioGuiState createState() => _PositionalAudioGuiState();
}

class _PositionalAudioGuiState extends State<PositionalAudioGui> {
  late final ThreeViewer threeV = widget.threeV;
  late final three.PositionalAudio audio = widget.audio;

  @override
  void initState() {
    super.initState();
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

  TextEditingController audioController = TextEditingController();
  final List<TextEditingController> transfromControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  Widget addListener(String text){
    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          margin: EdgeInsets.all(5),
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: EnterTextFormField(
            controller: audioController,
            width: MediaQuery.of(context).size.width*.2-40,
            height: 20,
            label: '${text}',
            readOnly: true,
            padding: EdgeInsets.only(left: 5),
            margin: EdgeInsets.only(left: 0,top: 1,bottom: 2),
            radius: 5,
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
      onAcceptWithDetails: (details){
        if(details.data is three.Object3D){
          audio.listner = (details.data as three.Object3D);
        }
        setState(() {});
      },
    );
  }

  Widget addButton(String text){
    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return Container(
          margin: EdgeInsets.all(5),
          //width: ,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.add, size: 15,),
                  EnterTextFormField(
                    controller: audioController,
                    width: MediaQuery.of(context).size.width*.2-87,
                    height: 20,
                    label: '${text}',
                    readOnly: true,
                    padding: EdgeInsets.only(left: 5),
                    margin: EdgeInsets.only(left: 0,top: 1,bottom: 2),
                    radius: 5,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              InkWell(
                onTap: (){
                  GetFilePicker.pickFiles(['mp3']).then((value)async{
                    if(value != null){
                      if(threeV.sceneSelected){ 
                        if(threeV.scene.userData['audio'] == null){
                          threeV.scene.userData['audio'] = <three.Object3D>[];
                        }
                        threeV.scene.userData['audio'].add(VideoAudio(path: value.files[0].path!));
                      }
                      else{
                        if(threeV.intersected[0].userData['audio'] == null){
                          threeV.intersected[0].userData['audio'] = <three.Object3D>[];
                        }
                        threeV.intersected[0].userData['audio'].add(VideoAudio(path: value.files[0].path!));
                      }
                      await threeV.fileSort.moveAudio(value.files[0]);
                    }
                  });
                  setState(() {});
                },
                child: Row(
                  children: [
                    Container(
                      height: 20,
                      width: 2,
                      margin: EdgeInsets.only(right: 5),
                      color: Theme.of(context).canvasColor,
                    ),
                    Icon(Icons.folder, size: 20,),
                  ],
                )
              )
            ]
          ),
        );
      },
      onAcceptWithDetails: (details) async{
        if((details.data as String).split('.').last.toLowerCase() == 'mp3'){
          if(threeV.intersected[0].userData['audio'] == null){
            threeV.intersected[0].userData['audio'] = <three.Object3D>[];
          }

          threeV.intersected[0].userData['audio'].add(VideoAudio(path: (details.data as String)));
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    transformControllersReset();
    double d2 = 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Text('Audio Source:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        addButton('Audio Source'),
        AudioGui(audio: audio.audioSource, threeV: threeV),
        SizedBox(height: 10,),
        Text('Positional Audio:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        Row(
          children: [
            SizedBox(child: const Text('Ref Dist:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'refDistance', v)..allowDispatch=false);
                audio.refDistance = v;
              },
              controller: transfromControllers[0]..text = audio.refDistance.toString(),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(child: const Text('Max Dist:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'maxDistance', v)..allowDispatch=false);
                audio.maxDistance = v;
              },
              controller: transfromControllers[1]..text = audio.maxDistance.toString(),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(child: const Text('Roll-Off:')),
            EnterTextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final int v = int.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'rolloffFactor', v)..allowDispatch=false);
                audio.rolloffFactor = v;
              },
              controller: transfromControllers[2]..text = audio.rolloffFactor.toString(),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(child: const Text('Gain:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'coneOuterGain', v)..allowDispatch=false);
                audio.coneOuterGain = v;
              },
              controller: transfromControllers[3]..text = audio.coneOuterGain.toString(),
            )
          ],
        ),
        SizedBox(height: 10,),
        Text('Angle\t\t\t'),
        Row(
          children: [
            SizedBox(child: const Text('Inner:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'coneInnerAngle', v)..allowDispatch=false);
                audio.coneInnerAngle = v;
              },
              controller: transfromControllers[4]..text = audio.coneInnerAngle.toString(),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(child: const Text('Outer:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, audio, 'coneOuterAngle', v)..allowDispatch=false);
                audio.coneOuterAngle = v;
              },
              controller: transfromControllers[5]..text = audio.coneOuterAngle.toString(),
            )
          ],
        ),
        SizedBox(height: 10,),
        Text('Listener\t\t\t'),
        addListener(audio.listner.name)
      ],
    );
  }
}