import 'package:three_js_animations/three_js_animations.dart';

class AnimationPlayer {
  AnimationClip? currentAnimationClip;
  List<AnimationAction> currentAnimationActions = [];
  bool isPlaying = false;

  /// When the user grabs the scrubber, the animation is paused.
  /// If it was playing before the scrubber was grabbed, it will
  /// resume playing after the user lets go.
  bool wasPlayingBeforeUserScrubbed = false;
  bool isUserScrubbing = false;
  bool hasAddedEventListeners = false;

  String? currentAnimationName;
  int totalTime = 0;
  int currentTime = 0;

  AnimationPlayer(){
    if (!hasAddedEventListeners) {
      hasAddedEventListeners = true;
    }
  }

  String animationNameClean(String input) {
    return input.replaceAll('_', ' ');
  }

  void setAnimation(AnimationClip animationClip, List<AnimationAction> animationActions) {
    currentAnimationClip = animationClip;
    currentAnimationActions = animationActions;

    // Calculate total frames (assuming 30 FPS)
    const fps = 30;
    final totalFrames = (animationClip.duration * fps).floor();

    // Update UI
    if (currentAnimationName != null) {
      currentAnimationName = animationNameClean(animationClip.name);
    }

    totalTime = totalFrames;

    // Set initial playing state based on first animation action
    isPlaying = animationActions.isNotEmpty ? animationActions[0].isRunning() : false;
  }

  void clearAnimation() {
    currentAnimationClip = null;
    currentAnimationActions = [];
    isPlaying = false;

    // Update UI
    if (currentAnimationName != null) {
      currentAnimationName = 'No animation selected';
    }
    currentTime = 0;
    totalTime = 0;

  }

  void togglePlayPause() {
    if (currentAnimationActions.isEmpty) {
      return;
    }
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (currentAnimationActions.isEmpty) {
      return;
    }
    // Apply play/unpause to all animation actions
    for (final action in currentAnimationActions) {
      if (action.paused == true) {
        action.paused = false;
      } else {
        action.play();
      }
    }
    isPlaying = true;
  }

  void pause() {
    if (currentAnimationActions.isEmpty) {
      return;
    }
    // Apply pause to all animation actions
    for (final action in currentAnimationActions) {
      action.paused = true;
    }
    isPlaying = false;
  }

  void handleScrubberInput(dynamic event) {
    if (currentAnimationActions.isEmpty || currentAnimationClip == null) {
      return;
    }
    final target = event.target;
    final frameNumber = double.tryParse(target.value ?? '0') ?? 0.0;

    // Convert frame to time (assuming 30 FPS)
    const fps = 30;
    final scrubTime = frameNumber / fps;

    // Set the animation time for all actions
    for (final action in currentAnimationActions) {
      action.time = scrubTime;
    }

    currentTime = frameNumber.round();
  }

  void update(double deltaTime) {
    if (currentAnimationActions.isEmpty || currentAnimationClip == null || isUserScrubbing) {
      return;
    }

    // Use the first action for time tracking (they should all be synchronized)
    final firstAction = currentAnimationActions[0];

    // Convert current time to frame number (assuming 30 FPS)
    const fps = 30;
    final currentFrame = firstAction.time * fps;

    currentTime = currentFrame.round();

    // Check if animation has finished and loop it
    if (firstAction.time >= currentAnimationClip!.duration) {
      for (final action in currentAnimationActions) {
        action.time = 0;
      }
    }
  }

  bool getIsPlaying() {
    return isPlaying;
  }
}
