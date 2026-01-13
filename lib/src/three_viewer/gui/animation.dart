import 'package:flutter/material.dart';
import 'package:three_forge/src/modifers/create_models.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class AnimationGui extends StatefulWidget {
  const AnimationGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _AnimationGuiState createState() => _AnimationGuiState();
}

class _AnimationGuiState extends State<AnimationGui> {
  late final ThreeViewer threeV;
  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    super.dispose();
  }

  // Future<void> addBVH(three.Object3D target, String path) async{
  //   final loader = three.BVHLoader();
  //   final bvh = await loader.fromPath(path);

  //   final retargetOptions = SkeletonUtilsOptions(
  //     hip: 'hip',
  //     scale: 0.01,
  //     getBoneName: ( bone ) {
  //       return 'mixamorig' + bone.name;
  //     }
  //   );
  //   three.Object3D? sk;
  //   target.traverse((callback){
  //     if(callback.skeleton?.bones != null){
  //       sk = callback;
  //     }
  //   });

  //   final three.AnimationClip retargetedClip = SkeletonUtils.retargetClip(
  //     sk!, 
  //     bvh!.skeleton!, 
  //     bvh.clip!,
  //     retargetOptions
  //   );

  //   String name = path.split('/').last.split('.').first;

  //   target.userData['actionMap'][name] = target.userData['mixer'].clipAction(retargetedClip)!;
  //   target.userData['actionMap'][name]!.enabled = true;
  //   target.userData['actionMap'][name]!.setEffectiveTimeScale( 1.0 );
  //   target.userData['actionMap'][name]!.setEffectiveWeight( 1.0 );
  //   target.userData['actionMap'][name]!.play();

  //   setState(() {});
  // }

  Widget animations(Map<String,dynamic> actionMap, String currentAction){
    List<Widget> widgets = [];

    for(final action in actionMap.keys){
      if(threeV.intersected[0].userData['actionMap'][currentAction] != null){
        widgets.add(
          InkWell(
            onTap: (){
              if(currentAction != ''){
                threeV.intersected[0].userData['actionMap'][currentAction]?.setEffectiveWeight( 0.0 );
              }
              threeV.intersected[0].userData['currentAction'] = action;
              threeV.intersected[0].userData['actionMap'][action]?.setEffectiveWeight( 1.0 );
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.all(5),
              height: 25,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: currentAction == action?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor
              ),
              child: Text(
                action,
                style: Theme.of(context).primaryTextTheme.bodySmall,
              )
            ),
          )
        );
      }
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(threeV.intersected[0].userData['actionMap'] == null){
      threeV.intersected[0].userData['actionMap'] = <String,dynamic>{};
    }
    Map<String,dynamic> actionMap = threeV.intersected[0].userData['actionMap'];
    String currentAction = threeV.intersected[0].userData['currentAction'] ?? '';
    bool paused = (actionMap[currentAction] as three.AnimationAction?)?.isRunning() ?? false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        animations(actionMap,currentAction),
        InkWell(
          onTap: (){
            if(!paused){
              (actionMap[currentAction] as three.AnimationAction?)?.play();
            }
            else{
              (actionMap[currentAction] as three.AnimationAction?)?.stop();
            }
            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.all(5),
            height: 25,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).canvasColor
            ),
            child: Icon(!paused?Icons.play_arrow:Icons.stop)
          ),
        ),
        SizedBox(height: 10,),
        const Text('Add Animation'),
        SizedBox(height: 10,),
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Wrap(
              children: [
                const Text('Animation  '),
                EnterTextFormField(
                  readOnly: true,
                  //width: MediaQuery.of(context).size.width,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: controller,
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            if((details.data as String).split('.').last.toLowerCase() == 'fbx'){
              CreateModels.addFBXAnimation(threeV.intersected[0],details.data! as String,threeV);
            }else{
              //addBVH(threeV.intersected[0],details.data! as String);
            }
          },
        ),
      ],
    );
  }
}