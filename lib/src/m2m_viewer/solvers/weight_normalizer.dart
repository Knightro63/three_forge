import 'package:three_js_core/three_js_core.dart';

/// Handles weight normalization to ensure all vertex skin weights sum to 1.0.
/// After initial weight assignment and smoothing, some vertices may have weights
/// that don't sum correctly. This normalizer detects and corrects those cases.
class WeightNormalizer {
  final BufferGeometry geometry;

  WeightNormalizer(this.geometry);

  int geometryVertexCount() {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return 0;
    return positionAttribute.array.length ~/ 3;
  }

  /// Returns an array of vertex indices whose weights do not sum to 1.0 (within a small epsilon).
  List<int> findVerticesWithIncorrectWeightSum(List<double> skinWeights) {
    const double epsilon = 1e-4; // very small number to signify close enough to 0
    final List<int> incorrectVertices = [];
    final int vertexCount = geometryVertexCount();

    for (int i = 0; i < vertexCount; i++) {
      final int offset = i * 4;
      final double sum = skinWeights[offset] +
          skinWeights[offset + 1] +
          skinWeights[offset + 2] +
          skinWeights[offset + 3];

      if ((sum - 1.0).abs() > epsilon) {
        incorrectVertices.add(i);
      }
    }
    return incorrectVertices;
  }

  /// Normalizes weights for vertices that don't sum to 1.0.
  /// Distributes the remaining weight across non-zero influence slots.
  void normalizeWeights(List<double> allSkinWeights) {
    final List<int> verticesThatDoNotHaveInfluencesAddingToOne = findVerticesWithIncorrectWeightSum(allSkinWeights);

    for (final vertexIndex in verticesThatDoNotHaveInfluencesAddingToOne) {
      final int offset = vertexIndex * 4;

      // If the weight is 0.00, then we can assign the remaining weights to the other bones
      final List<double> weights = [
        allSkinWeights[offset],
        allSkinWeights[offset + 1],
        allSkinWeights[offset + 2],
        allSkinWeights[offset + 3]
      ];

      // Replacing JavaScript Array.prototype.reduce with fold
      final double weightSum = weights.fold(0.0, (a, b) => a + b);
      final double weightPerIndex = (1.0 - weightSum) / 3.0;

      print(weightPerIndex);

      // Assign the weights all at once
      for (int i = 0; i < 4; i++) {
        if (weights[i] != 0.0) {
          allSkinWeights[offset + i] += weightPerIndex;
        }
      }
    }
  }
}
