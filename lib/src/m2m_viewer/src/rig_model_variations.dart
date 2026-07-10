abstract class VariationSpec {
  String get variant;
  String get displayName;
  String? get attribution;
  String? get license;
}

class VariationSpecImpl implements VariationSpec {
  @override
  final String variant;
  @override
  final String displayName;
  @override
  final String? attribution;
  @override
  final String? license;

  VariationSpecImpl({
    required this.variant,
    required this.displayName,
    this.attribution,
    this.license,
  });
}

abstract class ModelVariation {
  String get modelFile;
  String get displayName;
  String get attribution;
  String get previewImage;
  String get license;
}

class ModelVariationImpl implements ModelVariation {
  @override
  final String modelFile;
  @override
  final String displayName;
  @override
  final String attribution;
  @override
  final String previewImage;
  @override
  final String license;

  ModelVariationImpl({
    required this.modelFile,
    required this.displayName,
    required this.attribution,
    required this.previewImage,
    required this.license,
  });
}

ModelVariation createVariation(String type, VariationSpec spec) {
  return ModelVariationImpl(
    modelFile: 'models-variation/$type-${spec.variant}.glb',
    displayName: spec.displayName,
    attribution: spec.attribution ?? '',
    license: spec.license ?? 'CC0',
    previewImage: 'models-variation/profiles/${spec.variant}.png',
  );
}

const humanType = 'human';

final List<ModelVariation> humanVariations = [
  createVariation(humanType, VariationSpecImpl(variant: 'base', displayName: 'Mannequin', attribution: 'Quaternius', license: 'CC0')),
  createVariation(humanType, VariationSpecImpl(variant: 'female', displayName: 'Female Mannequin', attribution: 'Quaternius', license: 'CC0')),
  createVariation(humanType, VariationSpecImpl(variant: 'zombie', displayName: 'Zombie', attribution: 'Kenney.nl', license: 'CC0')),
  createVariation(humanType, VariationSpecImpl(variant: 'sophia', displayName: 'Sophia', attribution: 'Tysan Tan', license: 'CC-SA 4.0')),
  createVariation(humanType, VariationSpecImpl(variant: 'jay', displayName: 'Jay', attribution: 'Blender Studio', license: 'CC-BY')),
  createVariation(humanType, VariationSpecImpl(variant: 'sintel', displayName: 'Sintel', attribution: 'Blender Studio', license: 'CC-BY')),
  createVariation(humanType, VariationSpecImpl(variant: 'bunny', displayName: 'Bunny', attribution: 'Blender Studio', license: 'CC-BY')),
];

const foxType = 'fox';

final List<ModelVariation> foxVariations = [
  createVariation(foxType, VariationSpecImpl(variant: 'fox', displayName: 'Fox')),
  createVariation(foxType, VariationSpecImpl(variant: 'dog', displayName: 'Dog')),
  createVariation(foxType, VariationSpecImpl(variant: 'horse', displayName: 'Horse')),
  createVariation(foxType, VariationSpecImpl(variant: 'cat', displayName: 'Carrot', attribution: 'David Revoy', license: 'CC-BY')),
  createVariation(foxType, VariationSpecImpl(variant: 'panda', displayName: 'Panda')),
];

const birdType = 'bird';

final List<ModelVariation> birdVariations = [
  createVariation(birdType, VariationSpecImpl(variant: 'seagull', displayName: 'Seagull')),
  createVariation(birdType, VariationSpecImpl(variant: 'eagle', displayName: 'Bald Eagle')),
];

const kaijuType = 'kaiju';

final List<ModelVariation> kaijuVariations = [
  createVariation(kaijuType, VariationSpecImpl(variant: 'kaiju', displayName: 'Kaiju')),
  createVariation(kaijuType, VariationSpecImpl(variant: 't-rex', displayName: 'T-Rex')),
];

const fishType = 'fish';

final List<ModelVariation> fishVariations = [
  createVariation(fishType, VariationSpecImpl(variant: 'shark', displayName: 'Shark')),
  createVariation(fishType, VariationSpecImpl(variant: 'whale', displayName: 'Whale')),
];
