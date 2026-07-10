import 'dart:math' as math;
import 'package:three_js_core/three_js_core.dart' as three;
import 'package:three_js_math/three_js_math.dart';

/// Utility helpers to clean up and normalize loaded model geometry.
class ModelCleanupUtility {
  
  static BoundingBox calculateBoundingBox(three.Object3D sceneObject) {
    BoundingBox boundingBox = BoundingBox();
    
    sceneObject.traverse((child) {
      final testBb = BoundingBox().setFromObject(child);
      
      final double currentX = boundingBox.max.x - boundingBox.min.x;
      final double currentY = boundingBox.max.y - boundingBox.min.y;
      final double currentZ = boundingBox.max.z - boundingBox.min.z;
      
      final double testX = testBb.max.x - testBb.min.x;
      final double testY = testBb.max.y - testBb.min.y;
      final double testZ = testBb.max.z - testBb.min.z;
      
      if (testX > currentX || testY > currentY || testZ > currentZ) {
        boundingBox = testBb;
      }
    });
    
    return boundingBox;
  }

  static void scaleModelOnImportIfExtreme(three.Object3D sceneObject) {
    final boundingBox = calculateBoundingBox(sceneObject);
    final double height = boundingBox.max.y - boundingBox.min.y;
    final double width = boundingBox.max.x - boundingBox.min.x;
    final double depth = boundingBox.max.z - boundingBox.min.z;
    
    final double largestDimension = math.max(height, math.max(width, depth));
    
    if (largestDimension > 0.5 && largestDimension < 20.0) {
      print('Model a reasonable size, so no scaling applied: ${boundingBox.max} units is bounding box');
      return;
    } else {
      print('Model is very large or small, so scaling applied: ${boundingBox.max} units is bounding box');
    }
    
    final double scaleFactor = 1.5 / largestDimension;
    
    sceneObject.traverse((child) {
      if (child is three.Mesh) {
        final geometry = child.geometry;
        if (geometry != null) {
          print('Scaling mesh: $child by factor of $scaleFactor');
          geometry.scale(scaleFactor, scaleFactor, scaleFactor);
          geometry.computeBoundingBox();
          geometry.computeBoundingSphere();
        }
      }
    });
  }

  static void moveModelToFloor(three.Object3D meshData) {
    double finalLowestPoint = double.infinity;
    
    meshData.traverse((obj) {
      if (obj is three.Mesh) {
        final boundingBox = BoundingBox().setFromObject(obj);
        if (boundingBox.min.y < finalLowestPoint) {
          finalLowestPoint = boundingBox.min.y;
        }
      }
    });
    
    if (!finalLowestPoint.isFinite || finalLowestPoint == 0.0) return;
    
    meshData.traverse((obj) {
      if (obj is three.Mesh) {
        final geometry = obj.geometry;
        if (geometry != null) {
          final double offset = finalLowestPoint * -1.0;
          geometry.translate(0.0, offset, 0.0);
          geometry.computeBoundingBox();
          geometry.computeBoundingSphere();
        }
      }
    });
  }

  static void translateModelVertices(three.Object3D meshData, double dx, double dy, double dz) {
    meshData.traverse((obj) {
      if (obj is three.Mesh) {
        final geometry = obj.geometry;
        if (geometry != null) {
          geometry.translate(dx, dy, dz);
          geometry.computeBoundingBox();
          geometry.computeBoundingSphere();
        }
      }
    });
  }

  static three.Scene stripOutAllUnnecessaryModelData(
    three.Object3D modelData, 
    String modelDisplayName, 
    bool debugModelLoading,
  ) {
    final newScene = three.Scene();
    newScene.name = modelDisplayName;
    
    modelData.traverse((child) {
      three.Mesh? newMesh;
      
      if (child is three.SkinnedMesh) {
        newMesh = three.Mesh(child.geometry, child.material);
        newMesh.name = child.name;
        newScene.add(newMesh);
      } else if (child is three.Mesh) {
        newMesh = child.clone(true); // deep clone matching JS .clone()
        newMesh.name = child.name;
        newScene.add(newMesh);
      }
      
      if (debugModelLoading && newMesh != null) {
        final materialToUse = three.MeshPhongMaterial();
        materialToUse.side = FrontSide;
        materialToUse.color.setFromHex32(0x00aaee);
        newMesh.material = materialToUse;
      }
    });
    
    return newScene;
  }

  static three.Scene stripOutRetargetingModelData(three.Scene modelData) {
    final filteredScene = three.Scene();
    filteredScene.name = 'Filtered Retargeting Data';
    
    final List<three.SkinnedMesh> skinnedMeshes = [];
    modelData.traverse((child) {
      if (child is three.SkinnedMesh) {
        skinnedMeshes.add(child);
      }
    });
    
    for (final skinnedMesh in skinnedMeshes) {
      final clonedSkinnedMesh = skinnedMesh.clone(true);
      filteredScene.add(clonedSkinnedMesh);
    }
    
    return filteredScene;
  }
}
