import 'skeleton_type.dart';
import '../src/rig_model_variations.dart';

abstract class RigConfigEntry {
  SkeletonType get skeletonType;
  String get modelFile;
  String get rigFile;
  String get rigDisplayName;
  List<String> get animationFiles;
  String get animationPreviewFolder;
  String get skeletonTemplateImageUrl;
  String get positionTrackingBoneName;
  List<ModelVariation>? get modelVariations;
}

class RigConfigEntryImpl implements RigConfigEntry {
  @override
  final SkeletonType skeletonType;
  @override
  final String modelFile;
  @override
  final String rigFile;
  @override
  final String rigDisplayName;
  @override
  final List<String> animationFiles;
  @override
  final String animationPreviewFolder;
  @override
  final String skeletonTemplateImageUrl;
  @override
  final String positionTrackingBoneName;
  @override
  final List<ModelVariation>? modelVariations;

  RigConfigEntryImpl({
    required this.skeletonType,
    required this.modelFile,
    required this.rigFile,
    required this.rigDisplayName,
    required this.animationFiles,
    required this.animationPreviewFolder,
    required this.skeletonTemplateImageUrl,
    required this.positionTrackingBoneName,
    this.modelVariations,
  });
}

class RigConfig {
  static final List<RigConfigEntry> all = [
    RigConfigEntryImpl(
      skeletonType: SkeletonType.human,
      modelFile: 'models/model-human.glb',
      rigFile: 'rigs/rig-human.glb',
      rigDisplayName: 'Human',
      animationFiles: ['../animations/human-base-animations.glb', '../animations/human-addon-animations.glb'],
      animationPreviewFolder: 'human',
      positionTrackingBoneName: 'pelvis',
      skeletonTemplateImageUrl: 'rigs/reference/human.png',
      modelVariations: humanVariations,
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.fox,
      modelFile: 'models/model-fox.glb',
      rigFile: 'rigs/rig-fox.glb',
      rigDisplayName: 'Fox',
      animationFiles: ['../animations/fox-animations.glb'],
      animationPreviewFolder: 'fox',
      positionTrackingBoneName: 'hips',
      skeletonTemplateImageUrl: 'rigs/reference/fox.png',
      modelVariations: foxVariations,
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.bird,
      modelFile: 'models/model-bird.glb',
      rigFile: 'rigs/rig-bird.glb',
      rigDisplayName: 'Bird',
      animationFiles: ['../animations/bird-animations.glb'],
      animationPreviewFolder: 'bird',
      positionTrackingBoneName: 'hips',
      skeletonTemplateImageUrl: 'rigs/reference/bird.png',
      modelVariations: birdVariations,
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.dragon,
      modelFile: 'models/model-dragon.glb',
      rigFile: 'rigs/rig-dragon.glb',
      rigDisplayName: 'Dragon',
      animationFiles: ['../animations/dragon-animations.glb'],
      animationPreviewFolder: 'dragon',
      positionTrackingBoneName: 'hips',
      skeletonTemplateImageUrl: 'rigs/reference/dragon.png',
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.kaiju,
      modelFile: 'models/model-kaiju.glb',
      rigFile: 'rigs/rig-kaiju.glb',
      rigDisplayName: 'Kaiju',
      animationFiles: ['../animations/kaiju-animations.glb'],
      animationPreviewFolder: 'kaiju',
      positionTrackingBoneName: 'hips',
      skeletonTemplateImageUrl: 'rigs/reference/kaiju.png',
      modelVariations: kaijuVariations,
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.spider,
      modelFile: 'models/model-spider.glb',
      rigFile: 'rigs/rig-spider.glb',
      rigDisplayName: 'Spider',
      animationFiles: ['../animations/spider-animations.glb'],
      animationPreviewFolder: 'spider',
      positionTrackingBoneName: 'hips',
      skeletonTemplateImageUrl: 'rigs/reference/spider.png',
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.snake,
      modelFile: 'models/model-snake.glb',
      rigFile: 'rigs/rig-snake.glb',
      rigDisplayName: 'Snake',
      animationFiles: ['../animations/snake-animations.glb'],
      animationPreviewFolder: 'snake',
      positionTrackingBoneName: 'head',
      skeletonTemplateImageUrl: 'rigs/reference/snake.png',
    ),
    RigConfigEntryImpl(
      skeletonType: SkeletonType.fish,
      modelFile: 'models/model-shark.glb',
      rigFile: 'rigs/rig-shark.glb',
      rigDisplayName: 'Fish',
      animationFiles: ['../animations/shark-animations.glb'],
      animationPreviewFolder: 'shark',
      positionTrackingBoneName: 'pelvis',
      skeletonTemplateImageUrl: 'rigs/reference/shark.png',
      modelVariations: fishVariations,
    ),
  ];

  static RigConfigEntry? byKey(String rigKey) {
    return all.where((r) {
      return r.skeletonType.toString().split('.').last == rigKey;
    }).firstOrNull;
  }

  static RigConfigEntry? bySkeletonType(SkeletonType skeletonType) {
    return all.where((r) => r.skeletonType == skeletonType).firstOrNull;
  }

  static String? rigFileFor(SkeletonType skeletonType) {
    return bySkeletonType(skeletonType)?.rigFile;
  }

  static List<String> getAnimationFilePaths(SkeletonType skeletonType) {
    final config = bySkeletonType(skeletonType);
    if (config == null || config.animationFiles.isEmpty) return [];
    return config.animationFiles;
  }
}
