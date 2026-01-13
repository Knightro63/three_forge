import 'package:three_js_math/three_js_math.dart';
import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_geometry/three_js_geometry.dart';
import 'dart:math' as math;

/// Creates a visual aid consisting of a spherical [Mesh] for a
/// [HemisphereLight].
/// 
/// ```
/// final light = HemisphereLight( 0xffffbb, 0x080820, 1 );
/// final helper = HemisphereLightHelper( light, 5 );
/// scene.add( helper );
/// ```
class EmptyHelper extends Object3D {
  final _vectorHemisphereLightHelper = Vector3();

  Color color;
  late Object3D object;

  /// [object] - The empty being visualized.
  /// 
  /// [size] - The size of the mesh used to visualize the light.
  /// 
  /// [color] - (optional) if this is not the set the helper will take
  /// the color of the light.
  EmptyHelper(this.object, double size, this.color) : super() {
    object.updateMatrixWorld(false);

    matrix = object.matrixWorld;
    matrixAutoUpdate = false;

    final geometry = OctahedronGeometry(size);
    geometry.rotateY(math.pi * 0.5);

    material = MeshBasicMaterial.fromMap({"wireframe": true, "fog": false, "toneMapped": false, 'color': color});

    add(Mesh(geometry, material));
    update();
  }

  @override
  void dispose() {
    children[0].geometry!.dispose();
    children[0].material?.dispose();
  }

  void update() {
    final mesh = children[0];
    material?.color.setFrom(color);

    mesh.lookAt(_vectorHemisphereLightHelper
        .setFromMatrixPosition(object.matrixWorld)
        .negate());
  }
}
