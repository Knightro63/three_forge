import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/decimal_index_formatter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class AudioGui extends StatefulWidget {
  const AudioGui({Key? key, required this.audio, required this.threeV}):super(key: key);
  final ThreeViewer threeV;
  final three.Audio audio;

  @override
  _ObjectGuiState createState() => _ObjectGuiState();
}

class _ObjectGuiState extends State<AudioGui> {
  late final ThreeViewer threeV = widget.threeV;
  late final three.Audio audio = widget.audio;

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

  final List<TextEditingController> transfromControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    transformControllersReset();
    double d2 = 76;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (){
            audio.autoplay = !audio.autoplay;
            threeV.execute(SetValueCommand(threeV, audio, 'autoplay', audio.autoplay));
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Autoplay\t\t\t'),
              SavedWidgets.checkBox(audio.autoplay)
            ]
          )
        ),
        SizedBox(height: 10,),
        Text('Playback:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        InkWell(
          onTap: (){
            audio.hasPlaybackControl = !audio.hasPlaybackControl;
            threeV.execute(SetValueCommand(threeV, audio, 'hasPlaybackControl', audio.hasPlaybackControl));
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Control\t\t\t'),
              SavedWidgets.checkBox(audio.hasPlaybackControl)
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
                threeV.execute(SetValueCommand(threeV, audio, 'playbackRate', v)..allowDispatch=false);
                audio.playbackRate = v;
              },
              controller: transfromControllers[0]..text = audio.playbackRate.toString(),
            )
          ],
        ),
        SizedBox(height: 10,),
        Text('Loop:\t\t\t'),
        Container(margin: EdgeInsets.only(bottom: 7), height: 2,color: Theme.of(context).primaryTextTheme.bodySmall!.color,),
        InkWell(
          onTap: (){
            audio.loop = !audio.loop;
            threeV.execute(SetValueCommand(threeV, audio, 'loop', audio.loop));
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loop\t\t\t'),
              SavedWidgets.checkBox(audio.loop)
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
                threeV.execute(SetValueCommand(threeV, audio, 'loopStart', v)..allowDispatch=false);
                audio.loopStart = v;
              },
              controller: transfromControllers[1]..text = audio.loopStart.toString(),
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
                threeV.execute(SetValueCommand(threeV, audio, 'loopEnd', v)..allowDispatch=false);
                audio.loopEnd = v;
              },
              controller: transfromControllers[2]..text = audio.loopEnd.toString(),
            )
          ],
        ),
      ],
    );
  }
}