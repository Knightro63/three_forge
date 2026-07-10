import '../src/skeleton_type.dart';
import '../src/generators.dart';
import '../solvers/skinning_algorithm.dart';
import 'package:three_js_math/three_js_math.dart';
import 'package:three_js_core/three_js_core.dart';

class Weights{
  List<int> indicies;
  List<double> weights;

  Weights(this.indicies,this.weights);
}

class StepWeightSkin{
  Object3D? skinningArmature;
  SkinningAlgorithm? boneSkinningFormula;
  Skeleton? bindingSkeleton;
  List<SkinnedMesh> skinnedMeshes = []; 
  List<BufferGeometry> allMeshGeometry = [];
  List<Material> allMeshMaterials = []; 
  final Group weightPaintedMeshPreview = Group();

  StepWeightSkin() {
    weightPaintedMeshPreview.name = 'Weight Painted Mesh Preview';
    weightPaintedMeshPreview.renderOrder = -1;
  }

  void createBoneFormulaObject(Object3D editableArmature, SkeletonType skeletonType) {
    skinningArmature = editableArmature.clone();
    skinningArmature!.name = 'Armature for skinning';
    boneSkinningFormula = SkinningAlgorithm(skinningArmature!.children[0], skeletonType);
  }

  Skeleton? get skeleton => bindingSkeleton;

  /// Add in all mesh geometry data to be skinned.
  void addToGeometryDataToSkin(BufferGeometry geometry) {
    geometry.name = 'Mesh ${allMeshGeometry.length}';
    allMeshGeometry.add(geometry);
  }

  List<BufferGeometry> getGeometryDataToSkin() {
    return allMeshGeometry;
  }

  void setMeshGeometry(BufferGeometry geometry) {
    if (boneSkinningFormula == null) {
      print('Tried to set_mesh_geometry() in weight skinning step, but bone_skinning_formula is undefined!');
      return;
    }
    boneSkinningFormula!.setGeometry(geometry);
  }

  void createBindingSkeleton() {
    if (skinningArmature == null) {
      print('Tried to create_binding_skeleton() but skinning_armature has no children!');
      return;
    }
    bindingSkeleton = Generators.createSkeleton(skinningArmature!.children[0]);
    //bindingSkeleton!.name = 'Mesh Binding Skeleton';
  }

  /// We might need to do the skinnning process multiple times
  /// so we need to clear out the data from the previous
  /// skinned mesh process
  void resetAllSkinProcessData() {
    skinnedMeshes = [];
    allMeshMaterials = [];
    allMeshGeometry = [];

    // Properly dispose of all children in the weight painted mesh preview to prevent memory leaks
    for (var child in weightPaintedMeshPreview.children) {
      if (child is SkinnedMesh) {
        if (child.geometry != null) {
          child.geometry!.dispose();
        }
        if (child.material != null) {
          if (child.material is List) {
            for (var mat in (child.material as List)) {
              if (mat is Material) mat.dispose();
            }
          } else if (child.material is Material) {
            (child.material as Material).dispose();
          }
        }
      }
    }
    weightPaintedMeshPreview.clear();
  }

  void addMeshMaterial(Material material) {
    allMeshMaterials.add(material);
  }

  SkinnedMesh createSkinnedMesh(BufferGeometry geometry, Material material, int idx) {
    if (bindingSkeleton == null) {
      throw Exception('binding_skeleton must be initialized before creating skinned meshes. Call create_binding_skeleton() first.');
    }
    final skinnedMesh = SkinnedMesh(geometry, material);
    skinnedMesh.name = 'Skinned Mesh ${idx.toString()}';
    skinnedMesh.castShadow = true;
    
    skinnedMesh.add(bindingSkeleton!.bones[0]);
    skinnedMesh.bind(bindingSkeleton!);
    return skinnedMesh;
  }

  List<SkinnedMesh> finalSkinnedMeshes() {
    return skinnedMeshes;
  }

  Group? weightPaintedMeshGroup() {
    return weightPaintedMeshPreview;
  }

  /// Configure head weight correction settings for the solver
  void setHeadWeightCorrectionSettings(bool enabled, double height) {
    if (boneSkinningFormula == null) return;
    boneSkinningFormula!.setHeadWeightCorrectionEnabled(enabled);
    boneSkinningFormula!.setPreviewPlaneHeight(height);
  }

  Weights calculateWeights() {
    if (boneSkinningFormula == null) return Weights([],[]);
    return boneSkinningFormula!.calculateIndexesAndWeights();
  }

  void calculateWeightsForAllMeshData({bool regenerateWeightPaintedMesh = false}) {
    if (allMeshGeometry.isEmpty) {
      print('Tried to calculate_weights_for_all_mesh_data() but all_mesh_geometry is empty!');
      return;
    }
    if (boneSkinningFormula == null) return;

    for (int idx = 0; idx < allMeshGeometry.length; idx++) {
      final geometryData = allMeshGeometry[idx];
      boneSkinningFormula!.setGeometry(geometryData);
      
      final weightsResult = calculateWeights();
      final finalSkinIndices = weightsResult.indicies;
      final finalSkinWeights = weightsResult.weights;

      geometryData.setAttributeFromString('skinIndex', Uint16BufferAttribute.fromList(finalSkinIndices, 4));
      geometryData.setAttributeFromString('skinWeight', Float32BufferAttribute.fromList(finalSkinWeights, 4));

      final associatedMaterial = allMeshMaterials[idx];
      final tempSkinnedMesh = createSkinnedMesh(geometryData, associatedMaterial, idx);
      skinnedMeshes.add(tempSkinnedMesh);

      if (regenerateWeightPaintedMesh) {
        final weightPaintedMesh = Generators.createWeightPaintedMesh(finalSkinIndices, geometryData);
        final wireframeMesh = Generators.createWireframeMeshFromGeometry(geometryData);
        weightPaintedMeshPreview.add(weightPaintedMesh);
        weightPaintedMeshPreview.add(wireframeMesh);
      }
    }

    print('Final skinned meshes: $skinnedMeshes');
    print('Preview weight painted mesh re-generated: $weightPaintedMeshPreview');
  }
}
