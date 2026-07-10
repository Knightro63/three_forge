import 'dart:math' as math;
import '../src/utilities.dart';
import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_math/three_js_math.dart';

class Generators {
  static MeshPhongMaterial createMaterial({bool wireframeValue = true, int colorHex = 0x00ff00}) {
    final material = MeshPhongMaterial.fromMap({
      'color': colorHex, 
      'wireframe': wireframeValue
    });
    material.side = DoubleSide;
    material.specular = Color();
    material.shininess = 0.0;
    return material;
  }

  static Bone createBoneHierarchy() {
    // offset root bone down to move entire bone structure
    final bone0 = Bone();
    bone0.name = 'rootBone';
    final bone1 = Bone();
    bone1.name = 'childBone';
    final bone2 = Bone();
    bone2.name = 'grandchildBone';
    final bone3 = Bone();
    bone3.name = 'greatGrandchildBone';
    
    bone0.add(bone1);
    bone1.add(bone2);
    bone2.add(bone3);

    // this is the local position...relative to the parent
    bone0.position.y = -0.8;
    bone1.position.y = 0.5;
    bone2.position.y = 0.5;
    bone3.position.y = 0.5;
    return bone0;
  }

  static Skeleton createSkeleton(Object3D boneHierarchy) {
    final boneList = Utility.boneListFromHierarchy(boneHierarchy);
    final skeleton = Skeleton(boneList);
    return skeleton;
  }
  
  static Mesh createBonePlaneMesh(Bone boneStart, Bone boneEnd, int raysToCast) {
    // create plane mesh to do the ray casting
    // we also want to offset it half the bone distance up the bone
    // for a better approximation with what counts
    final Mesh planeMesh = Generators.createTestPlaneMesh(size: 0.02);
    planeMesh.position.setFrom(Utility.worldPositionFromObject(boneStart));
    planeMesh.lookAt(Utility.worldPositionFromObject(boneEnd));
    planeMesh.translateZ(Utility.distanceBetweenObjects(boneStart, boneEnd) * 0.5);

    // create reference points around the plane that will be used for raycasting
    final planePointGeometry = SphereGeometry(0.002, 3, 3);
    final planePointMaterial = Generators.createMaterial(wireframeValue: true, colorHex: 0x00ffff);

    for (int i = 0; i < raysToCast; i++) {
      // have the points go around the plane in even circle increments
      const double distance = 0.005; // set radial distance from origin close to help with close vertices
      final double angle = (i / raysToCast) * (math.pi * 2.0);
      final double x = math.cos(angle) * distance;
      final double y = math.sin(angle) * distance;
      const double z = 0.0;

      final pointMesh = Mesh(planePointGeometry, planePointMaterial);
      pointMesh.name = 'Point mesh PLANE';
      pointMesh.position.setValues(x, y, z);
      planeMesh.add(pointMesh);
    }
    return planeMesh;
  }

  /// Create x markers at a location in space
  static Group createXMarkers(List<Vector3> points, {double size = 0.1, int color = 0xff0000, String name = ''}) {
    final group = Group();
    group.name = 'X markers: $name';
    final material = LineBasicMaterial.fromMap({'color': color, 'depthTest': false});

    for (final point in points) {
      // Create first diagonal line (\ direction)
      final geometry1 = BufferGeometry().setFromPoints([
        Vector3(point.x - size, point.y - size, point.z),
        Vector3(point.x + size, point.y + size, point.z)
      ]);
      final line1 = Line(geometry1, material);

      // Create second diagonal line (/ direction)
      final geometry2 = BufferGeometry().setFromPoints([
        Vector3(point.x - size, point.y + size, point.z),
        Vector3(point.x + size, point.y - size, point.z)
      ]);
      final line2 = Line(geometry2, material);

      group.add(line1);
      group.add(line2);
    }
    return group;
  }

  static Group createSpheresForPoints(List<Vector3> points, {int color = 0x00ffff, String name = ''}) {
    const double debugSphereSize = 0.006;
    final group = Group();
    group.name = 'Point display: $name';
    final sphereGeometry = SphereGeometry(debugSphereSize, 10, 10);
    final sphereMaterial = MeshBasicMaterial.fromMap({'color': color, 'depthTest': false});

    for (final point in points) {
      final sphere = Mesh(sphereGeometry, sphereMaterial);
      sphere.position.setFrom(point); // Position the sphere at the point
      group.add(sphere);
    }
    return group;
  }

  static Mesh createTestPlaneMesh({double size = 0.08, int color = 0x0000ff}) {
    final double planeWidth = size;
    final double planeHeight = size;
    const int planeWidthSegments = 2;
    const int planeHeightSegments = 2;
    
    final planeGeometry = PlaneGeometry(planeWidth, planeHeight, planeWidthSegments, planeHeightSegments);
    final planeMaterial = Generators.createMaterial(wireframeValue: false, colorHex: color);
    final meshObject = Mesh(planeGeometry, planeMaterial);
    meshObject.name = 'Plane Intersection Mesh';
    return meshObject;
  }

  static List<dynamic> createDefaultLights(double lightStrength) {
    const int shadowMapSize = 2048;
    final light1 = DirectionalLight(0x777777, lightStrength);
    light1.castShadow = true;
    light1.shadow?.mapSize = Vector2(shadowMapSize.toDouble(), shadowMapSize.toDouble());
    
    // Decreases moire effect on mesh
    light1.shadow?.bias = -0.0001;
    light1.position.setValues(-2.0, 2.0, 2.0);

    final light2 = AmbientLight(0xffffff, 1.2); // backfill light
    
    final backfillLight = DirectionalLight(0x777777, lightStrength * 0.5);
    backfillLight.castShadow = false; // one shadow is enough
    backfillLight.position.setValues(2.0, 2.0, -2.0);

    return [light1, light2, backfillLight];
  }

  static PerspectiveCamera createCamera() {
    const double fieldOfView = 15.0; // in millimeters. Lower makes the camera more isometric
    // Decoupled from browser window layout dimensions
    const double aspect = 1.0; 
    
    final camera = PerspectiveCamera(fieldOfView, aspect, 0.1, 10000.0);
    camera.position.z = 10.0;
    camera.position.y = 5.0;
    camera.position.x = 5.0;
    return camera;
  }

  static List<Mesh> createEquidistantSpheresAroundCircle({int sphereCount = 6, int color = 0x00ff00, double distance = 0.3}) {
    final List<Mesh> planePoints = [];
    final planePointGeometry = SphereGeometry(0.03, 12, 12);
    final planePointMaterial = Generators.createMaterial(wireframeValue: true, colorHex: color);

    for (int i = 0; i < sphereCount; i++) {
      // Have the points go around the plane in an even circle increments
      final double angle = (i / sphereCount) * (math.pi * 2.0);
      final double x = math.cos(angle) * distance;
      final double y = math.sin(angle) * distance;
      const double z = 0.0;

      final pointMesh = Mesh(planePointGeometry, planePointMaterial);
      pointMesh.position.setValues(x, y, z);
      planePoints.add(pointMesh);
    }
    return planePoints;
  }

  static void createWindowResizeListener(dynamic renderer, Camera camera) {
    // Note: Web 'window.addEventListener' hooks do not apply directly to standard cross-platform Flutter windows.
    // In Flutter, handle viewport resizing natively via LayoutBuilder or context size listeners inside your widget.
    print('Window resize listener stubbed for cross-platform compatibility.');
  }


  static Mesh createWireframeMeshFromGeometry(BufferGeometry origGeometry) {
    final wireframeMaterial = MeshBasicMaterial.fromMap({
      'color': 0x337baa, // light blue color
      'wireframe': true,
      'opacity': 0.2,
      'transparent': true
    });
    final clonedGeometry = origGeometry.clone();
    return Mesh(clonedGeometry, wireframeMaterial);
  }

  /// This function will create a mesh to show the weights of the vertices
  /// It will use the skinIndices to assign colors to the vertices
  static Mesh createWeightPaintedMesh(List<int> skinIndices, BufferGeometry origGeometry) {
    // Clone the geometry to avoid modifying the original
    final clonedGeometry = origGeometry.clone();
    final positionAttribute = clonedGeometry.attributes['position'];
    if (positionAttribute == null) return Mesh(clonedGeometry, MeshBasicMaterial());

    final int vertexCount = positionAttribute.array.length ~/ 3;

    // Assign a random color for each bone
    final List<Vector3> boneColors = Generators.generateDeterministicBoneColors(120);

    // Loop through each vertex and assign color based on the bone index
    // Equivalent allocation to JS Float32Array
    final List<double> colors = List<double>.filled(vertexCount * 3, 0.0);

    for (int i = 0; i < vertexCount; i++) {
      final int boneIndex = skinIndices[i * 4].toInt(); // Primary bone assignment
      Vector3? color = boneIndex < boneColors.length ? boneColors[boneIndex] : null;

      if (color == null) {
        print('No color found for bone index $boneIndex. Using default color. Code needs to increase the number of bone colors generated');
        color = Vector3(1.0, 1.0, 1.0); // white color
      }

      colors[i * 3] = color.x; // red
      colors[i * 3 + 1] = color.y; // green
      colors[i * 3 + 2] = color.z; // blue
    }

    clonedGeometry.setAttributeFromString('color', Float32BufferAttribute.fromList(colors, 3));

    // Create a mesh with vertex colors
    final material = MeshBasicMaterial.fromMap({
      'vertexColors': true,
      'wireframe': false,
      'opacity': 1.0,
      'transparent': false
    });
    return Mesh(clonedGeometry, material);
  }

  static List<Vector3> generateDeterministicBoneColors(int count) {
    // base color, can be any value between 0 and 1
    double r = 0.2;
    double g = 0.5;
    double b = 0.8;
    // Darkening factor (0 < factor < 1)
    const double darken = 0.8; // lower value is darker

    // Generate a list of colors based on the count
    final List<Vector3> colors = [];
    const List<double> step = [-0.1, 0.1, 0.3];

    for (int i = 0; i < count; i++) {
      // Ensure values wrap between 0 and 1 using remainder math
      r = (r + step[0] + 1.0) % 1.0;
      g = (g + step[1] + 1.0) % 1.0;
      b = (b + step[2] + 1.0) % 1.0;

      // Apply darkening factor
      colors.add(Vector3(r * darken, g * darken, b * darken));
    }
    return colors;
  }
}
