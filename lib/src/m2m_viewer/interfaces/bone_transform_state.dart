import 'package:three_js_math/three_js_math.dart';

class BoneTransformState {
  String name;
  Vector3 position;
  Vector3 rotation;
  Vector3 scale;

  BoneTransformState({
    this.name = '',
    required this.position,
    required this.rotation,
    required this.scale,
  });
}
