import 'package:three_js_core/three_js_core.dart';

class BoneCalculationData {
  String name = '';
  Bone boneObject;
  bool hasChildBone = false;
  dynamic assignedVertices;

  BoneCalculationData(Bone bone)
      : boneObject = bone {
    name = bone.name;
    hasChildBone = bone.children.isNotEmpty;
  }
}
