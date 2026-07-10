import '../interfaces/bone_calculation_data.dart';
import '../interfaces/bone_transform_state.dart';
import '../interfaces/intersection_point_data.dart';
import 'package:three_js_math/three_js_math.dart';
import 'package:three_js_core/three_js_core.dart';

class Utility {
  static double distanceBetweenObjects(Object3D object1, Object3D object2) {
    final object1Position = Vector3();
    final object2Position = Vector3();
    object1.getWorldPosition(object1Position);
    object2.getWorldPosition(object2Position);
    return object1Position.distanceTo(object2Position);
  }

  /// Converts an object's local position to world position
  /// This is similar to "localToWorld()", but makes sure the object's world matrix is up to date
  /// https://stackoverflow.com/questions/70016922/three-js-getworldposition-localtoworld-position-not-correct
  /// @param {*} object
  /// @returns local position for object in a Vector3 object
  static Vector3 worldPositionFromObject(Object3D object) {
    final position = Vector3();
    return object.getWorldPosition(position);
  }

  static Vector3 directionBetweenPoints(Vector3 point1, Vector3 point2) {
    final direction = Vector3();
    direction.sub2(point2, point1).normalize();
    return direction;
  }

  static bool isPointInBox(Vector3 point, Mesh boxMesh) {
    // Transform the point from world space into the objects space
    boxMesh.updateMatrixWorld();
    final localPoint = boxMesh.worldToLocal(point.clone());
    
    if (boxMesh.geometry?.boundingBox == null) {
      print('isPointInBox() - boxMesh does not have a bounding box: $boxMesh');
      return false;
    }
    return boxMesh.geometry!.boundingBox!.containsPoint(localPoint);
  }

  static void removeObjectArray(Object3D obj) {
    obj.traverse((child) {
      if (child is Mesh) {
        child.geometry?.dispose();
        
        // Handling dynamic material map properties in Dart
        if (child.material != null) {
          if (child.material is Map) {
            final matMap = child.material as Map;
            for (final key in matMap.keys) {
              final value = matMap[key];
              if (value != null && value is Function) {
                // Invoking dispose if structured as dynamic function calls
                try {
                  value.call();
                } catch (_) {}
              }
            }
          } else {
            child.material?.dispose();
          }
        }
        obj.remove(child);
      }
    });
  }

  static void removeObjectWithChildren(Object3D obj) {
    if (obj.children.isNotEmpty) {
      // Create a shallow copy of the list before mutating during removal
      final childrenList = List<Object3D>.from(obj.children);
      for (final child in childrenList) {
        removeObjectWithChildren(child);
      }
    }

    if (obj is Mesh) {
      if (obj.geometry != null) {
        obj.geometry!.dispose();
      }
      
      if (obj.material != null) {
        // checks if material array or single instance
        if (obj.material is List) {
          final materialsList = obj.material as List;
          for (final material in materialsList) {
            if (material.map != null) {
              material.map!.dispose();
            }
            material.dispose();
          }
        } else {
          if (obj.material?.map != null) {
            obj.material!.map!.dispose();
          }
          obj.material?.dispose();
        }
      }
    }

    if (obj.parent != null) {
      obj.parent!.remove(obj);
    }
    obj.removeFromParent();
  }
  /// A "leaf" bone is an orientation-only tip at the end of a chain (finger/toe
  /// tips, head top, tail/ear/wing tips). These are not meant to be animated, so
  /// the skinning algorithm ignores them. Identified as childless AND name-marked.
  /// Human rigs mark them with `_leaf`; the animal rigs mark them with `tip`.
  static bool isLeafBone(Bone bone) {
    if (bone.children.isNotEmpty) return false;
    final name = bone.name.toLowerCase();
    return name.contains('leaf') || name.contains('tip');
  }

  static List<Bone> boneListFromHierarchy(Object3D? boneHierarchy) {
    if (boneHierarchy == null) {
      print('boneHierarchy is undefined or null');
      return [];
    }
    final List<Bone> bones = [];
    boneHierarchy.traverse((bone) {
      if (bone is Bone) {
        bones.add(bone);
      }
    });
    return bones;
  }

  static IntersectionPointData intersectionPointsBetweenPositionsAndMesh(
    dynamic positions, // Accepts BufferAttribute or InterleavedBufferAttribute equivalents in Dart
    Mesh envelopeMesh,
  ) {
    final List<Vector3> vertexPositionsInsideBoneEnvelope = [];
    final List<int> vertexIndexesInsideBoneEnvelope = [];
    final int vertexCount = positions.array.length ~/ 3;

    for (int i = 0; i < vertexCount; i++) {
      final vertexPosition = Vector3().fromBuffer(positions, i);
      final bool isIntersecting = Utility.isPointInBox(vertexPosition, envelopeMesh);
      
      if (isIntersecting) {
        vertexPositionsInsideBoneEnvelope.add(vertexPosition);
        vertexIndexesInsideBoneEnvelope.add(i);
      }
    }
    return IntersectionPointData(vertexPositionsInsideBoneEnvelope, vertexIndexesInsideBoneEnvelope);
  }

  /// From a mouse event, return a normalized vector2 for screen space between -1 and 1 (0 being center of screen)
  /// This is used for turning a mouse event into a raycaster when determining screen space intersections
  /// Top right of screen would return 1, 1. Bottom left would return -1, -1
  /// @param {*} mouseEvent
  /// @returns x and y coordinates normalized between -1 and 1
  static Vector2 normalizedMousePosition(dynamic mouseEvent) {
    // In Flutter, window properties are accessed via View bindings or context size. 
    // Assuming context-independent logic placeholder fallback sizing or direct mouseEvent positioning coordinates.
    final mouse = Vector2();
    // Replacing browser window dependency safely
    // If you have specific viewport bounds passed down, use those sizes instead of 1000.0 placeholders
    const viewportWidth = 1000.0; 
    const viewportHeight = 1000.0;

    mouse.x = (mouseEvent.clientX / viewportWidth) * 2 - 1;
    mouse.y = -(mouseEvent.clientY / viewportHeight) * 2 + 1;
    return mouse;
  }

  /// Store all the debugging objects in a separate group so they can be easily organized
  /// and removed when needed
  /// @param {*} scene
  /// @returns
  static Group regenerateDebuggingScene(Scene scene) {
    const String debuggingObjectName = 'Skinning Debug Container';

    // clear out debugging container if it exists
    final existingDebuggingContainer = scene.getObjectByName(debuggingObjectName);
    if (existingDebuggingContainer != null) {
      Utility.removeObjectArray(existingDebuggingContainer);
      existingDebuggingContainer.clear();
      scene.remove(existingDebuggingContainer);
    }

    // add a reusable container for debugging
    final debuggingSceneObject = Group();
    debuggingSceneObject.name = debuggingObjectName;
    scene.add(debuggingSceneObject);
    return debuggingSceneObject;
  }

  static List<BoneTransformState> storeBoneTransforms(Skeleton skeleton) {
    final List<BoneTransformState> boneTransforms = [];
    
    for (final bone in skeleton.bones) {
      final newRotation = Vector3().setFromEuler(bone.rotation);
      final newTransformState = BoneTransformState(
        name: bone.name,
        position: bone.position.clone(),
        rotation: newRotation,
        scale: bone.scale.clone(),
      );
      boneTransforms.add(newTransformState);
    }
    return boneTransforms;
  }

  static void restoreBoneTransforms(Skeleton skeleton, List<BoneTransformState> originalBoneTransforms) {
    for (final boneTransform in originalBoneTransforms) {
      Bone? bone;
      try {
        bone = skeleton.bones.firstWhere((b) => b.name == boneTransform.name);
      } catch (_) {
        bone = null;
      }

      if (bone != null) {
        bone.position.setFrom(boneTransform.position);
        final euler = Euler();
        euler.setFromVector3(boneTransform.rotation);
        bone.rotation.copy(euler);
        bone.scale.setFrom(boneTransform.scale);
      }
    }
  }

  static String calculateBoneBaseName(String boneName) {
    // remove bone name part if they have a suffix
    String normalizedBoneName = boneName.toLowerCase().replaceAll(RegExp(r'(_r|_l|_right|_left)$'), '');
    // remove bone name part if they have a prefix
    normalizedBoneName = normalizedBoneName.replaceAll(RegExp(r'^(r_|l_|right_|left_)'), '');
    return normalizedBoneName;
  }

  // Find the closest bone for raycaster using screen-space distance to account for camera zoom
  static RaycastClosestBoneResult raycastClosestBoneTest(
    Camera camera, 
    dynamic mouseEvent, 
    Skeleton skeleton
  ) {
    final mousePosition = mouseEvent;//Utility.normalizedMousePosition(mouseEvent);
    Bone? closestBone;
    int closestBoneIndex = 0;
    double closestDistance = double.infinity;

    for (int boneIndex = 0; boneIndex < skeleton.bones.length; boneIndex++) {
      final bone = skeleton.bones[boneIndex];
      final worldPosition = Utility.worldPositionFromObject(bone);
      
      // Project bone position to screen space then find distance
      final boneScreenPosition = worldPosition.clone().project(camera);
      final screenDistance = mousePosition.distanceTo(Vector2(boneScreenPosition.x, boneScreenPosition.y));
      
      if (screenDistance < closestDistance) {
        closestBone = bone;
        closestDistance = screenDistance;
        closestBoneIndex = boneIndex;
      }
    }

    return RaycastClosestBoneResult(closestBone, closestBoneIndex, closestDistance);
  }

  static void scaleArmatureByScalar(Object3D armature, double scalar) {
    armature.traverse((bone) {
      if (bone.type == 'Bone') {
        bone.position.scale(scalar);
      }
    });
  }

  static String cleanBoneNameForMessaging(String boneName) {
    return boneName.replaceAll('mixamorig_', '');
  }

  static int findClosestBoneIndexFromVertexIndex(
    int vertexIndex, 
    BufferGeometry geometry, 
    List<BoneCalculationData> bones
  ) {
    final positionAttribute = geometry.attributes['position'];
    if (positionAttribute == null) return 0;

    final vertexPosition = Vector3().fromBuffer(positionAttribute, vertexIndex);
    double closestBoneDistance = 10000.0;
    int closestBoneIndex = 0;

    for (int idx = 0; idx < bones.length; idx++) {
      final bone = bones[idx];
      double distance = Utility.worldPositionFromObject(bone.boneObject).distanceTo(vertexPosition);
      
      // if bone has a child, we are going to calculate the distance by getting the half way
      // point between bone and child bone...to hopefully yield better results
      if (bone.hasChildBone) {
        final childBone = bone.boneObject.children[0] as Bone;
        final childBonePosition = Utility.worldPositionFromObject(childBone);
        final bonePosition = Utility.worldPositionFromObject(bone.boneObject);
        final halfWayPoint = bonePosition.add(childBonePosition).divideScalar(2);
        final distanceToHalfWayPoint = halfWayPoint.distanceTo(vertexPosition);
        
        if (distanceToHalfWayPoint < closestBoneDistance) {
          distance = distanceToHalfWayPoint;
        }
      }

      if (distance < closestBoneDistance) {
        closestBoneDistance = distance;
        closestBoneIndex = idx;
      }
    }

    return closestBoneIndex;
  }

  static double parseInputNumber(String? value) {
    if (value == null) {
      return 0.0;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0.0;
    }
    final valueNumeric = double.tryParse(trimmed);
    if (valueNumeric == null || !valueNumeric.isFinite) {
      return 0.0;
    }
    return valueNumeric;
  }

  /// Dart implementation of lookup-by-value parsing logic for enums.
  /// Matches the functionality of JS runtime object entries lookup reflection safely.
  static T? enumFromValue<T extends Enum>(dynamic val, List<T> values) {
    try {
      return values.firstWhere((e) => e.name == val || e.toString() == val);
    } catch (_) {
      return null;
    }
  }
}

/// Structured tuple fallback wrapper for Raycast calculations
class RaycastClosestBoneResult {
  final Bone? bone;
  final int index;
  final double distance;

  RaycastClosestBoneResult(this.bone, this.index, this.distance);
}
