import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_forge/src/m2m_viewer/animation/animation_player.dart';
import 'package:three_forge/src/m2m_viewer/gui/video_preview.dart';
import 'package:three_forge/src/m2m_viewer/animation/transformed_animation_clip_pair.dart';
import 'package:three_forge/src/m2m_viewer/src/animation_utility.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_helpers/skeleton_helper.dart';

class StepAnimations{
  final AnimationMixer mixer = AnimationMixer(Object3D());
  AnimationPlayer animationPlayer = AnimationPlayer();
  final List<TransformedAnimationClipPair> animationClipsLoaded = [];
  AnimationObject? animationObject;
  SkeletonHelper? skeleton;
  double warpArmAmount = 0;
  int currentPlayingIndex = 0;
  bool mirror = false;

  //List<AnimationClip>? animations;
  final List<String> _exportAnimations = [];
  Map<String,int> animationIndices = {};

  final Function setState;
  Directory get baseDir => Directory.current;

  StepAnimations(this.setState);

  List<Widget> animationVideos(
    String key, 
    double width, 
    BuildContext context,
    Map<String,dynamic> contents, 
    String search
  ) {  
    List<Widget> widgets = [];
    
    // Safety guard against missing or misconfigured dictionary keys
    if (contents[key] == null || contents[key]['previews'] == null) {
      return [];
    }

    final String query = search.toLowerCase().trim();

    // Iterate directly through the structured file paths array
    for (final dynamic path in contents[key]['previews']) {
      final String pathString = path.toString();
      final fileName = pathString.split('/').last.split('.').first;
      final name = fileName.replaceAll('_', ' ');

      if(query.isEmpty || name.toLowerCase().contains(query)){
        final height = 200.0;

        widgets.add(
        Container(
            height: height,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    print("Tapped preview element target: ${fileName}");
                    playAnimationFromName(fileName);
                  },
                  child: Container(
                    height: height-45,
                    //child: MediaKitVideoPreview(file: file),
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(!_exportAnimations.contains(pathString)){
                      _exportAnimations.add(pathString);
                    }
                    else{
                      _exportAnimations.remove(pathString);
                    }

                    print(_exportAnimations);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height:25,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SavedWidgets.checkBox(_exportAnimations.contains(pathString)),
                        Text(
                          '${name.toUpperCase()}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    )
                  )
                ),
              ],
            )
          )
        );
      }
    }
    
    return widgets;
  }

  List<Widget> hud(BuildContext context){
    return [
      Positioned(
        bottom: 20,
        child: Container(
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            children: [
              InkWell(
                onTap: (){
                  if(animationPlayer.isPlaying){
                    animationPlayer.pause();
                  }
                  else{
                    animationPlayer.play();
                  }
                },
                child: Container(
                  width: 35,
                  height: 35,
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(animationPlayer.isPlaying?Icons.pause:Icons.play_arrow),
                ),
              ),
              Container(
                width: 65,
                //height: 35,
                alignment: Alignment.center,
                child: Text('${animationPlayer.currentTime}/${animationPlayer.totalTime}'),
              ),
              Container(
                width: MediaQuery.of(context).size.width*.4,
                // child: Slider(
                //   value: animationPlayer.totalTime.toDouble() < animationPlayer.currentTime.toDouble()?0:animationPlayer.currentTime.toDouble(), 
                //   min: 0,
                //   max: animationPlayer.totalTime.toDouble(),
                //   divisions: animationPlayer.totalTime,
                //   onChanged: (c){
                //     if(!animationPlayer.isPlaying){
                //       animationPlayer.currentTime = c.toInt();
                //       setState((){});
                //     }
                //   },
                //   thumbColor: Theme.of(context).primaryColor,
                // ),
              ),
              InkWell(
                onTap: (){
                  //print(animationIndices);
                  skeleton?.visible = skeleton?.visible == true?false:true;
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Transform.rotate(angle: -3.14/4,
                    child: Icon(FontAwesomeIcons.bone.data,size: 15,)
                  ),
                ),
              ),
            ]
          )
        ),
      )
    ];
  }

  void setModel(
    AnimationObject animationObject,
    SkeletonHelper? skeleton,
  ){
    this.animationObject = animationObject;
    this.skeleton = skeleton;
    animationClipsLoaded.clear();
    animationIndices.clear();
  }

  void addAnimations(
    GLTFData gltf, 
    SkeletonType skeletonType
  ){
    animationClipsLoaded.addAll(processLoadedAnimations(gltf.animations!, skeletonType));

    final ao = animationObject!;
    ao.animations.addAll(gltf.animations!);
    mixer.root = animationObject!;
  }

  void onAllAnimationsLoaded() {
    // Sort all animation names alphabetically using explicit types
    animationClipsLoaded.sort((a, b) {
      return a.displayAnimationClip.name.compareTo(b.displayAnimationClip.name);
    });
    getSelectedAnimationIndices();
    playAnimation(); // play the first animation by default
  }

  void getSelectedAnimationIndices() {
    for (int i = 0; i < animationClipsLoaded.length; i++) {
      if (!animationClipsLoaded[i].isChecked) {
        animationClipsLoaded[i].isChecked = true;
        animationIndices[animationClipsLoaded[i].displayAnimationClip.name.toLowerCase()] = i;
      }
    }
  }

  AnimationClipMetadata createDefaultMetadata() {
    return AnimationClipMetadata(
      sourceType: AnimationSourceType.defaultLibrary,
      tags: [],
    );
  }

  List<TransformedAnimationClipPair> processLoadedAnimations(
    List<AnimationClip> rawAnimations,
    SkeletonType skeletonType, [
    AnimationClipMetadata? metadataOverride,
  ]) {
    final clonedAnimations = AnimationUtility.deepCloneAnimationClips(rawAnimations);
    AnimationUtility.cleanTrackData(clonedAnimations, skeletonType);
    AnimationUtility.applySkeletonScaleToPositionKeyframes(clonedAnimations, 1.0);

    final defaultMeta = createDefaultMetadata();
    if (metadataOverride != null) {
      defaultMeta.sourceType = metadataOverride.sourceType;
      defaultMeta.tags = metadataOverride.tags;
    }

    return clonedAnimations.map((clip) {
      return TransformedAnimationClipPair(
        originalAnimationClip: clip,
        displayAnimationClip: AnimationUtility.deepCloneAnimationClip(clip),
        metadata: defaultMeta,
      );
    }).toList();
  }

  void start(){
    _exportAnimations.clear();
  }

  void stop(){
    animationObject = null;
    skeleton = null;
    _exportAnimations.clear();
    mirror = false;
    warpArmAmount = 0;
    animationClipsLoaded.clear();
  }

  List<AnimationClip> exportAnimations(){
    List<AnimationClip> clips = [];

    for(int i = 0; i < _exportAnimations.length;i++){
      String name = _exportAnimations[i].split('/').last.split('.').first;
      print(name);
      final int index = animationIndices[name]!;
      clips.add(animationClipsLoaded[index].displayAnimationClip);
    }

    return clips;
  }

  AnimationClipMetadata? getAnimationMetadata(int index) {
    if (index < 0 || index >= animationClipsLoaded.length) return null;
    return animationClipsLoaded[index].metadata;
  }

  bool isAnimationCustom(int index) {
    return getAnimationMetadata(index)?.sourceType == AnimationSourceType.customImport;
  }

  void rebuildWarpedAnimations() {
    for (final warpedClip in animationClipsLoaded) {
      warpedClip.displayAnimationClip = AnimationUtility.deepCloneAnimationClip(warpedClip.originalAnimationClip);
    }
    if (mirror) {
      AnimationUtility.applyAnimationMirroring(animationClipsLoaded);
    }
    AnimationUtility.applyArmExtensionWarp(animationClipsLoaded, warpArmAmount);
  }

  void resetRootMotionPosition(Object3D skinnedMesh) {
    if (skinnedMesh.skeleton?.bones.isNotEmpty == true) {
      final rootBone = skinnedMesh.skeleton!.bones[0];
      rootBone.position.setValues(0, 0, 0);
      rootBone.updateMatrixWorld(true);
    }
  }

  void playAnimationFromName([String? name]) {
    int index = animationIndices[name] ?? 0;
    print(index);
    playAnimation(index);
  }

  void playAnimation([int index = 0]) {
    animationPlayer.pause();
    animationPlayer.currentTime = 0;
    currentPlayingIndex = index;
    final allAnimationActions = <AnimationAction>[];

    for (final skinnedMesh in (animationObject?.children ?? [])) {
      resetRootMotionPosition(skinnedMesh);
      final clipToPlay = animationClipsLoaded[currentPlayingIndex].displayAnimationClip;
      final animAction = mixer.clipAction(clipToPlay, skinnedMesh);
      animAction?.stop();
      animAction?.play();
      if(animAction != null){
        allAnimationActions.add(animAction);
      }
    }

    if (allAnimationActions.isNotEmpty) {
      final clipToPlay = animationClipsLoaded[currentPlayingIndex].displayAnimationClip;
      animationPlayer.setAnimation(clipToPlay, allAnimationActions);
    }

    animationPlayer.play();
  }
  
  void updateAPoseValue(double newValue) {
    warpArmAmount = newValue;
    rebuildWarpedAnimations();
    playAnimation(currentPlayingIndex);
  }

  void update(double dt){
    mixer.update(dt);
    animationPlayer.update(dt);
    if(animationObject != null){
      setState((){});
    }
  }
}