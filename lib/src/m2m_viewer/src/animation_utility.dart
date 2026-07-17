import 'dart:typed_data';
import 'package:three_forge/src/m2m_viewer/animation/transformed_animation_clip_pair.dart';
import 'package:three_forge/src/m2m_viewer/src/rig_config.dart';
import 'package:three_forge/src/m2m_viewer/src/skeleton_type.dart';
import 'package:three_js_animations/three_js_animations.dart';
import 'package:three_js_math/three_js_math.dart';

class AnimationUtility {
  // Fixes position keyframe scaling issues
  static void applySkeletonScaleToPositionKeyframes(
    List<AnimationClip> animationClips, 
    double scaleAmount,
  ) {
    for (final animationClip in animationClips) {
      for (final track in animationClip.tracks) {
        if (track.name.contains('.position')) {
          final values = track.values;
          for (var i = 0; i < values.length; i += 3) {
            values[i] *= scaleAmount;
            values[i + 1] *= scaleAmount;
            values[i + 2] *= scaleAmount;
          }
        }
      }
    }
  }

  static AnimationClip deepCloneAnimationClip(AnimationClip clip) {
    final tracks = clip.tracks.map((track) => track.clone()).toList();
    return AnimationClip(clip.name, clip.duration, tracks);
  }

  static List<AnimationClip> deepCloneAnimationClips(List<AnimationClip> animationClips) {
    return animationClips.map((clip) => deepCloneAnimationClip(clip)).toList();
  }

  /// Removes position tracks from animation clips, keeping only rotation tracks.
  static void cleanTrackData(List<AnimationClip> animationClips, SkeletonType skeletonType) {
    for (final animationClip in animationClips) {
      List<KeyframeTrack> rotationTracks = [];
      final preserveRootPosition = animationClip.name.toLowerCase().endsWith('rm');
      final positionTrackingBoneName = RigConfig.bySkeletonType(skeletonType)?.positionTrackingBoneName;

      if (preserveRootPosition) {
        rotationTracks = animationClip.tracks.where((x) {
          return x.name.contains('quaternion') || 
                 x.name.toLowerCase().contains('$positionTrackingBoneName.position') || 
                 x.name.toLowerCase().contains('root.position');
        }).toList();
      } else {
        rotationTracks = animationClip.tracks.where((x) {
          return x.name.contains('quaternion') || 
                 x.name.toLowerCase().contains('$positionTrackingBoneName.position');
        }).toList();
      }
      animationClip.tracks = rotationTracks;
    }
  }

  static void applyArmExtensionWarp(List<TransformedAnimationClipPair> animationClips, double percentage) {
    for (final warpedClip in animationClips) {
      for (final track in warpedClip.displayAnimationClip.tracks) {
        if (!track.name.contains('quaternion')) {
          continue;
        }

        final isRightArmTrackMatch = track.name.contains('upperarm_l');
        final isLeftArmTrackMatch = track.name.contains('upperarm_r');

        if (isRightArmTrackMatch || isLeftArmTrackMatch) {
          final newTrackValues = Float32List.fromList(List<double>.from(track.values));
          final trackCount = track.times.length;

          for (var i = 0; i < trackCount; i++) {
            const unitsInQuaternions = 4;
            final quaternion = Quaternion();

            if (isRightArmTrackMatch) {
              quaternion.setFromAxisAngle(Vector3(0, 0, -1), percentage / 100);
            }
            if (isLeftArmTrackMatch) {
              quaternion.setFromAxisAngle(Vector3(0, 0, 1), percentage / 100);
            }

            final existingQuaternion = Quaternion(
              newTrackValues[i * unitsInQuaternions + 0],
              newTrackValues[i * unitsInQuaternions + 1],
              newTrackValues[i * unitsInQuaternions + 2],
              newTrackValues[i * unitsInQuaternions + 3],
            );

            existingQuaternion.multiply(quaternion);

            newTrackValues[i * unitsInQuaternions + 0] = existingQuaternion.x;
            newTrackValues[i * unitsInQuaternions + 1] = existingQuaternion.y;
            newTrackValues[i * unitsInQuaternions + 2] = existingQuaternion.z;
            newTrackValues[i * unitsInQuaternions + 3] = existingQuaternion.w;
          }
          track.values = newTrackValues;
        }
      }
    }
  }

  static void applyAnimationMirroring(List<TransformedAnimationClipPair> animationClips) {
    for (final warpedClip in animationClips) {
      final tracks = warpedClip.displayAnimationClip.tracks;
      final clipName = warpedClip.displayAnimationClip.name;
      final trackSwaps = <Map<String, dynamic>>[];

      for (var i = 0; i < tracks.length; i++) {
        final track = tracks[i];
        final trackName = track.name;

        if (trackName.toLowerCase().endsWith('_l.quaternion')) {
          final rightTrackName = trackName.replaceAll(RegExp(r'_l\.quaternion$', caseSensitive: false), '_r.quaternion');
          final rightTrackIndex = tracks.indexWhere((t) => t.name.toLowerCase() == rightTrackName.toLowerCase());

          if (rightTrackIndex != -1) {
            trackSwaps.add({
              'leftIndex': i,
              'rightIndex': rightTrackIndex,
              'clipDetails': '$clipName:$trackName'
            });
          }
        }
      }

      for (final swap in trackSwaps) {
        final leftTrack = tracks[swap['leftIndex'] as int];
        final rightTrack = tracks[swap['rightIndex'] as int];

        final leftValues = Float32List.fromList(List<double>.from(leftTrack.values));
        final rightValues = Float32List.fromList(List<double>.from(rightTrack.values));
        final leftTimes = Float32List.fromList(List<double>.from(leftTrack.times));
        final rightTimes = Float32List.fromList(List<double>.from(rightTrack.times));

        final mirroredLeftValues = mirrorQuaternionTrackValues(leftValues);
        final mirroredRightValues = mirrorQuaternionTrackValues(rightValues);

        leftTrack.values = mirroredRightValues;
        leftTrack.times = rightTimes;
        rightTrack.values = mirroredLeftValues;
        rightTrack.times = leftTimes;
      }
    }

    applyCenterBoneMirroring(animationClips);
    applyHipsPositionMirroring(animationClips);
  }

  static Float32List mirrorQuaternionTrackValues(Float32List values) {
    final mirroredValues = Float32List.fromList(values);
    const unitsInQuaternions = 4;

    for (var i = 0; i < values.length; i += unitsInQuaternions) {
      final quat = Quaternion(values[i], values[i + 1], values[i + 2], values[i + 3]);

      quat.x = -quat.x;
      quat.w = -quat.w;

      mirroredValues[i] = quat.x;
      mirroredValues[i + 1] = quat.y;
      mirroredValues[i + 2] = quat.z;
      mirroredValues[i + 3] = quat.w;
    }
    return mirroredValues;
  }

  static void applyCenterBoneMirroring(List<TransformedAnimationClipPair> animationClips) {
    for (final warpedClip in animationClips) {
      final tracks = warpedClip.displayAnimationClip.tracks;
      for (final track in tracks) {
        final trackNameLower = track.name.toLowerCase();

        if (track.name.contains('quaternion')) {
          final isCenterBone = trackNameLower.contains('spine') ||
              trackNameLower.contains('hips') ||
              trackNameLower.contains('pelvis') ||
              trackNameLower.contains('neck') ||
              trackNameLower.contains('head') ||
              trackNameLower.contains('torso') ||
              trackNameLower.contains('chest');
              
          if (!isCenterBone) continue;

          final values = track.values;
          const unitsInQuaternions = 4;

          for (var i = 0; i < values.length; i += unitsInQuaternions) {
            final quat = Quaternion(values[i].toDouble(), values[i + 1].toDouble(), values[i + 2].toDouble(), values[i + 3].toDouble());

            quat.y = -quat.y;
            quat.z = -quat.z;

            values[i] = quat.x;
            values[i + 1] = quat.y;
            values[i + 2] = quat.z;
            values[i + 3] = quat.w;
          }
        }
      }
    }
  }

  static void applyHipsPositionMirroring(List<TransformedAnimationClipPair> animationClips) {
    for (final warpedClip in animationClips) {
      final tracks = warpedClip.displayAnimationClip.tracks;
      for (final track in tracks) {
        final trackNameLower = track.name.toLowerCase();

        if (track.name.contains('position') && (trackNameLower.contains('hips') || trackNameLower.contains('pelvis'))) {
          final values = track.values;
          const unitsInPosition = 3;

          for (var i = 0; i < values.length; i += unitsInPosition) {
            values[i] = -values[i]; // invert X axis position matrix mapping
          }
        }
      }
    }
  }
}
