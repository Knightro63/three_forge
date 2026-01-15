import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js_video_texture/video_audio.dart';

class AudioGui extends StatefulWidget {
  const AudioGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _ObjectGuiState createState() => _ObjectGuiState();
}

class _ObjectGuiState extends State<AudioGui> {
  late final ThreeViewer threeV;

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
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
  ];

  @override
  Widget build(BuildContext context) {
    VideoAudio object = (threeV.sceneSelected?threeV.scene:threeV.intersected[0]).userData['audio'];
    transformControllersReset();
    double d2 = 76;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (){
            object.autoplay = !object.autoplay;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Autoplay\t\t\t'),
              SavedWidgets.checkBox(object.autoplay)
            ]
          )
        ),
        SizedBox(height: 10,),
        Text('Playback:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        InkWell(
          onTap: (){
            object.hasPlaybackControl = !object.hasPlaybackControl;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Control\t\t\t'),
              SavedWidgets.checkBox(object.hasPlaybackControl)
            ]
          )
        ),
        Row(
          children: [
            SizedBox(child: const Text('Rate:')),
            EnterTextFormField(
              inputFormatters: [DecimalTextInputFormatter()],
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double v = double.tryParse(val) ?? 0;
                threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'renderOrder', v)..allowDispatch=false);
                object.playbackRate = v;
              },
              controller: transfromControllers[1]..text = object.playbackRate.toString(),
            )
          ],
        ),
        SizedBox(height: 10,),
        Text('Loop:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        InkWell(
          onTap: (){
            object.loop = !object.loop;
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loop\t\t\t'),
              SavedWidgets.checkBox(object.loop)
            ]
          )
        ),
        Row(
          children: [
            SizedBox(child: const Text('Start:')),
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
                threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'renderOrder', v)..allowDispatch=false);
                object.loopStart = v;
              },
              controller: transfromControllers[0]..text = object.loopStart.toString(),
            )
          ],
        ),
        Row(
          children: [
            SizedBox(child: const Text('End:  ')),
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
                threeV.execute(SetValueCommand(threeV, threeV.intersected[0], 'renderOrder', v)..allowDispatch=false);
                object.loopEnd = v;
              },
              controller: transfromControllers[2]..text = object.loopEnd.toString(),
            )
          ],
        ),
      ],
    );
  }
}