import 'package:three_forge/src/m2m_viewer/steps/step_weight_skin.dart';

import '../src/skeleton_type.dart';
import './extremity_weight_corrector.dart';
import './head_weight_corrector.dart';
import './weight_calculator.dart';
import './weight_normalizer.dart';
import './weight_smoother.dart';
import '../src/utilities.dart';
import 'package:three_js_core/three_js_core.dart';

/// SkinningAlgorithm
/// Orchestrates the bone weight calculation pipeline:
/// 1. Calculate initial bone weights (WeightCalculator)
/// 2. Smooth boundary weights (WeightSmoother)
/// 3. Normalize weights to sum to 1.0 (WeightNormalizer)
/// 4. Apply head weight correction if enabled (HeadWeightCorrector)
/// 5. Optionally render debug visualizations (SolverDebugVisualizer)
class SkinningAlgorithm {
  List<Bone> bonesMasterData = [];
  BufferGeometry geometry = BufferGeometry();
  SkeletonType? skeletonType;

  // Head weight correction properties
  bool useHeadWeightCorrection = false;
  double previewPlaneHeight = 1.4;

  SkinningAlgorithm.fromBones(this.bonesMasterData, this.skeletonType);

  SkinningAlgorithm(Object3D boneHier, this.skeletonType) {
    bonesMasterData = Utility.boneListFromHierarchy(boneHier);
  }

  void setGeometry(BufferGeometry geom) {
    geometry = geom;
  }

  void setHeadWeightCorrectionEnabled(bool enabled) {
    useHeadWeightCorrection = enabled;
  }

  void setPreviewPlaneHeight(double height) {
    previewPlaneHeight = height;
  }

  Weights calculateIndexesAndWeights() {
    final List<int> skinIndices = [];
    final List<double> skinWeights = [];

    // Step 1: Calculate initial bone-to-vertex weight assignments
    final weightCalculator = WeightCalculator(bonesMasterData, geometry, skeletonType);
    weightCalculator.initializeCaches();
    
    // Dart equivalent to console.time
    final stopwatch = Stopwatch()..start();
    
    weightCalculator.calculateMedianBoneWeights(skinIndices, skinWeights);

    // Step 1b: Pull parent-side vertices off extremity bones (e.g. knuckle
    // vertices grabbed by a finger). Runs before smoothing so the corrected
    // assignments are what the smoother sees.
    final extremityCorrector = ExtremityWeightCorrector(geometry, bonesMasterData);
    extremityCorrector.applyExtremityWeightCorrection(skinIndices, skinWeights);

    // Step 2: Smooth weight boundaries between adjacent bones
    final weightSmoother = WeightSmoother(geometry, bonesMasterData);
    weightSmoother.smoothBoneWeightBoundaries(skinIndices, skinWeights);
    
    // Dart equivalent to console.timeEnd
    stopwatch.stop();
    print('calculate_closest_bone_weights: ${stopwatch.elapsedMilliseconds}ms');

    // Step 4: Normalize weights so all vertices sum to 1.0
    final weightNormalizer = WeightNormalizer(geometry);
    weightNormalizer.normalizeWeights(skinWeights);

    // Step 5: Apply head weight correction if enabled
    if (useHeadWeightCorrection) {
      final headWeightCorrector = HeadWeightCorrector(
        geometry,
        bonesMasterData,
        previewPlaneHeight,
      );
      print('applying the head weight correction...');
      headWeightCorrector.applyHeadWeightCorrection(skinIndices, skinWeights);
    }

    print('do we have any leftover incorrect weights: ${weightNormalizer.findVerticesWithIncorrectWeightSum(skinWeights)}');
    
    return Weights(skinIndices, skinWeights);
  }
}
