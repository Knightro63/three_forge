import 'package:three_js_animations/three_js_animations.dart';

enum AnimationSourceType {
  defaultLibrary,
  customImport
}

class AnimationClipMetadata {
  AnimationClipMetadata({
    required this.sourceType,
    required this.tags,
  });

  AnimationSourceType sourceType;
  List<String> tags;
}

class TransformedAnimationClipPair {
  AnimationClip originalAnimationClip;
  AnimationClip displayAnimationClip;
  AnimationClipMetadata metadata;

  bool isChecked = false;

  TransformedAnimationClipPair({
    required this.displayAnimationClip,
    required this.originalAnimationClip,
    required this.metadata
  });
}