import 'dart:typed_data';
import 'package:three_forge/src/m2m_viewer/src/model_cleanup_utility.dart';
import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_math/three_js_math.dart';

class StepLoadModel{
  Object3D originalModelData = Scene();
  
  bool debugModelLoading = false;
  String modelDisplayName = 'Imported Model';
  
  final List<BufferGeometry> geometryList = [];
  final List<Material> materialList = [];
  bool addedEventListeners = false;
  bool meshHasBrokenMaterial = false;
  bool preserveSkinnedMesh = false;
  
  Object3D? finalMeshData; // mesh data used when creating the skinned mesh
  Object3D? finalRetargetableModelData; // model data used for retargeting process

  int vertexCount = 0;
  int triangleCount = 0;
  int objectsCount = 0;
  final List<Float32List> originalGeometryPositions = [];

  /// Skinned mesh data that will be used for retargeting
  Object3D? getFinalRetargetableModelData() {
    return finalRetargetableModelData;
  }

  // function that goes through all our geometry data and calculates how many triangles we have
  void calculateMeshMetrics(List<BufferGeometry> bufferGeometry) {
    int localTriangleCount = 0;
    int localVertexCount = 0;

    // Enforce explicit int loop variables replacing JavaScript .forEach loops cleanly
    for (int i = 0; i < bufferGeometry.length; i++) {
      final geometry = bufferGeometry[i];
      final Float32BufferAttribute? positionAttribute = geometry.attributes['position'];
      if (positionAttribute != null) {
        localTriangleCount += positionAttribute.count ~/ 3;
        localVertexCount += positionAttribute.count;
      }
    }

    triangleCount = localTriangleCount;
    vertexCount = localVertexCount;
    objectsCount = bufferGeometry.length;
  }

  void calculateGeometryAndMaterials(Object3D sceneToAnalyze) {
    // clear geometry and material list in place
    geometryList.clear();
    materialList.clear();
    
    sceneToAnalyze.traverse((child) {
      if (child.type == 'Mesh') {
        final Mesh meshChild = child as Mesh;
        final BufferGeometry geometryToAdd = buildGeometryListFromMesh(meshChild);
        geometryList.add(geometryToAdd);

        // material is broken somehow, so just use a normal material to help communicate this
        if (meshHasBrokenMaterial) {
          final MeshPhongMaterial newMaterial = MeshPhongMaterial();
          newMaterial.color.setFromHex32(0x00aaee);
          materialList.add(newMaterial);
          return;
        }

        // handle multiple materials (array) or single material
        if (meshChild.material is List) {
          final List<Material> materials = meshChild.material as List<Material>;
          final List<Material> clonedMaterials = [];
          for (int i = 0; i < materials.length; i++) {
            clonedMaterials.add(materials[i].clone());
          }
          materialList.add(clonedMaterials as Material);
        } else {
          // single material case
          final Material newMaterial = (meshChild.material as Material).clone();
          materialList.add(newMaterial);
        }
      }
    });
  }

  /// bring in a mesh object, extract geometry data and return only attributes we need
  /// Removes Interleaved buffer attributes and converts to normal buffer attributes
  BufferGeometry buildGeometryListFromMesh(Mesh child) {
    if (child.geometry == null) return BufferGeometry();
    
    final BufferGeometry geometryToAdd = child.geometry!.clone();
    geometryToAdd.name = child.name;

    final positionAttribute = child.geometry!.attributes['position'];
    final normalAttribute = child.geometry!.attributes['normal'];
    final uvAttribute = child.geometry!.attributes['uv'];
    final uv2Attribute = child.geometry!.attributes['uv2'];
    final skinIndexAttribute = child.geometry!.attributes['skinIndex'];
    final skinWeightAttribute = child.geometry!.attributes['skinWeight'];

    // If the geometry data is stored as Interleaved buffer, convert to regular BufferGeometry
    if (positionAttribute != null && positionAttribute is InterleavedBufferAttribute == true) {
      geometryToAdd.setAttributeFromString('position', positionAttribute.clone());
      if (normalAttribute != null) geometryToAdd.setAttributeFromString('normal', normalAttribute.clone());
      if (uvAttribute != null) geometryToAdd.setAttributeFromString('uv', uvAttribute.clone());
      
      if (uv2Attribute != null) {
        geometryToAdd.setAttributeFromString('uv2', uv2Attribute.clone());
      }
      
      if (skinIndexAttribute != null) {
        geometryToAdd.deleteAttributeFromString('skinIndex');
      }
      if (skinWeightAttribute != null) {
        geometryToAdd.deleteAttributeFromString('skinWeight');
      }
    }
    return geometryToAdd;
  }
  
  void clearLoadedModelData() {
    originalModelData = Scene();
    finalMeshData = Scene();
    geometryList.clear();
    materialList.clear();
    originalGeometryPositions.clear();
    vertexCount = 0;
    triangleCount = 0;
    objectsCount = 0;
    meshHasBrokenMaterial = false;
    preserveSkinnedMesh = false;
  }

  void resetModelPosition() {
    int i = 0;
    finalMeshData?.traverse((obj) {
      if (obj.type == 'Mesh') {
        final mesh = obj as Mesh;
        if (mesh.geometry != null) {
          final positionAttribute = mesh.geometry!.attributes['position'];
          if (positionAttribute != null && i < originalGeometryPositions.length) {
            final Float32List original = originalGeometryPositions[i++];
            
            // Set the position data array safely into the native Float32List buffer
            final Float32List currentArray = positionAttribute.array as Float32List;
            for (int k = 0; k < original.length; k++) {
              if (k < currentArray.length) {
                currentArray[k] = original[k];
              }
            }
            
            positionAttribute.needsUpdate = true;
            mesh.geometry!.computeBoundingBox();
            mesh.geometry!.computeBoundingSphere();
          }
        }
      }
    });
    finalMeshData?.position.setValues(0.0, 0.0, 0.0);
  }

  /// [preserve] Whether to maintain whole architecture skeletons structures
  void setPreserveSkinnedMesh(bool preserve) {
    preserveSkinnedMesh = preserve;
  }

  void loadGeometry(Object3D object){
    processLoadedScene(object);
  }

  void processLoadedScene(Object3D loadedScene) {
    if (preserveSkinnedMesh) {
      originalModelData = loadedScene;
    } else {
      originalModelData = loadedScene.clone();
      originalModelData.name = 'Cloned Scene';
    }
    
    originalModelData.traverse((child) {
      child.castShadow = true;
    });

    // strip out things differently if we need to preserve skinned meshes or regular meshes
    Object3D cleanSceneWithOnlyModels;
    if (preserveSkinnedMesh) {
      cleanSceneWithOnlyModels = originalModelData;
    } else {
      cleanSceneWithOnlyModels = ModelCleanupUtility.stripOutAllUnnecessaryModelData(
        originalModelData, 
        modelDisplayName, 
        debugModelLoading,
      );
    }

    // if there are no valid meshes, or skinned meshes, show error dialog
    if (cleanSceneWithOnlyModels.children.isEmpty) {
      if (preserveSkinnedMesh) {
        print('Error loading model No SkinnedMesh found in model file for retargeting');
      } else {
        print('Error loading model No Mesh found in model file');
      }
      return;
    }

    if (preserveSkinnedMesh) {
      finalRetargetableModelData = cleanSceneWithOnlyModels;
      return;
    }

    // loop through each child in scene and reset rotation using explicit int loop controls
    final List<Object3D> childrenList = cleanSceneWithOnlyModels.children;
    for (int i = 0; i < childrenList.length; i++) {
      final child = childrenList[i];
      child.traverse((node) {
        node.rotation.set(0.0, 0.0, 0.0);
        node.scale.setValues(1.0, 1.0, 1.0);
        node.updateMatrix();
        node.updateMatrixWorld(true);
      });
    }

    ModelCleanupUtility.scaleModelOnImportIfExtreme(cleanSceneWithOnlyModels);
    calculateGeometryAndMaterials(cleanSceneWithOnlyModels!);
    calculateMeshMetrics(geometryList);

    print('Vertex count:$vertexCount Triangle Count:$triangleCount Object Count:$objectsCount');

    finalMeshData = modelMeshes();
    originalGeometryPositions.clear();
    
    finalMeshData?.traverse((obj) {
      if (obj.type == 'Mesh') {
        final mesh = obj as Mesh;
        if (mesh.geometry != null) {
          final positionAttribute = mesh.geometry!.attributes['position'];
          if (positionAttribute != null) {
            final positions = positionAttribute.array as Float32List;
            originalGeometryPositions.add(Float32List.fromList(positions));
          }
        }
      }
    });

    print('final mesh data should be prepared at this point: $finalMeshData');
  }

  Object3D? modelMeshes() {
    if (finalMeshData?.children.isNotEmpty == true) {
      return finalMeshData!;
    }

    final newScene = Scene();
    newScene.name = modelDisplayName;

    // do a for loop to add all the meshes to the scene from the geometry and material list
    for (int i = 0; i < geometryList.length; i++) {
      final mesh = Mesh(geometryList[i], materialList[i]);
      newScene.add(mesh);
    }
    
    finalMeshData = newScene;
    return finalMeshData;
  }

  List<BufferGeometry> modelsGeometryList() {
    final List<BufferGeometry> geometriesToReturn = [];
    finalMeshData?.traverse((child) {
      if (child.type == 'Mesh') {
        final mesh = child as Mesh;
        if (mesh.geometry != null) {
          geometriesToReturn.add(mesh.geometry!.clone());
        }
      }
    });
    return geometriesToReturn;
  }

  List<Material> modelsMaterialList() {
    return materialList;
  }
}

