import 'package:three_js_core/three_js_core.dart';

/// Classifies bones into categories that determine smoothing behavior.
/// - torso: spine, chest, neck — gets wider multi-ring smoothing
/// - limb: arms, legs — gets directional child-only smoothing
/// - extremity: hands, feet, fingers, toes — no smoothing (stay rigid)
/// - other: root, head, unclassified — default smoothing
enum BoneCategory {
  torso,
  limb,
  extremity,
  other,
}

class BoneClassifier {
  final Map<int, BoneCategory> boneCategories = {};

  BoneClassifier(List<Bone> bones) {
    classifyAllBones(bones);
  }

  BoneCategory getCategory(int boneIndex) {
    return boneCategories[boneIndex] ?? BoneCategory.other;
  }

  /// Returns true if the bone pair represents a parent-child relationship
  /// where smoothing should only flow toward the child direction.
  /// This prevents elbow movement from deforming the bicep.
  bool isLimbBoundary(int boneIndexA, int boneIndexB) {
    final catA = getCategory(boneIndexA);
    final catB = getCategory(boneIndexB);
    return catA == BoneCategory.limb || catB == BoneCategory.limb;
  }

  /// Returns true if the boundary is between two extremity bones
  /// (hand↔finger, finger↔finger, foot↔toe). These get no smoothing so
  /// small parts like fingers stay rigid instead of turning mushy.
  /// Requires both sides to be extremities, so the wrist/ankle
  /// (limb↔extremity) is not caught here and keeps its limb smoothing.
  bool isExtremityBoundary(int boneIndexA, int boneIndexB) {
    return getCategory(boneIndexA) == BoneCategory.extremity &&
        getCategory(boneIndexB) == BoneCategory.extremity;
  }

  /// Returns true if the boundary between two bones should get
  /// wider multi-ring smoothing (torso regions).
  bool isTorsoBoundary(int boneIndexA, int boneIndexB) {
    final catA = getCategory(boneIndexA);
    final catB = getCategory(boneIndexB);
    
    // At least one side must be torso, and neither side should be extremity
    return (catA == BoneCategory.torso || catB == BoneCategory.torso) &&
        catA != BoneCategory.extremity &&
        catB != BoneCategory.extremity;
  }

  void classifyAllBones(List<Bone> bones) {
    for (int i = 0; i < bones.length; i++) {
      final category = classifyBone(bones[i]);
      boneCategories[i] = category;
    }
  }

  BoneCategory classifyBone(Bone bone) {
    final name = bone.name.toLowerCase();

    // Extremity bones: hands, feet, fingers, toes
    final extremityKeywords = [
      'hand', 'foot', 'toe', 'ball', 'thumb', 'index', 'middle', 'ring',
      'pinky', 'finger', 'eye', 'tongue', 'wing', 'feather'
    ];
    if (extremityKeywords.any((kw) => name.contains(kw))) {
      return BoneCategory.extremity;
    }

    // Limb bones: upper/lower arms, thighs, calves, shoulders
    final limbKeywords = [
      'arm', 'upperarm', 'lowerarm', 'forearm', 'elbow', 'wrist', 'shoulder',
      'clavicle', 'ankle', 'fin', 'thigh', 'calf', 'shin', 'knee', 'leg',
      'upleg', 'lowleg'
    ];
    if (limbKeywords.any((kw) => name.contains(kw))) {
      return BoneCategory.limb;
    }

    // Torso bones: spine, chest, hips, pelvis, neck, wings, tails
    // tails and feathers aren't technically torso, but we want
    // to give them more smoothing since they aren't as rigid
    final torsoKeywords = [
      'spine', 'chest', 'hips', 'pelvis', 'neck', 'torso', 'abdomen', 'body',
      'tail', 'head', 'mouth', 'stomach', 'chin', 'teeth'
    ];
    if (torsoKeywords.any((kw) => name.contains(kw))) {
      return BoneCategory.torso;
    }

    return BoneCategory.other;
  }
}
