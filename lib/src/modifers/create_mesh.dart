import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_modifers/loop_subdivision.dart';
import 'package:three_js_modifers/simplify_modifer.dart';

class CreateMesh{

  static three.Mesh? create(String type){
    if(type == 'collider_cube'){
      return colliderCube();
    }
    else if(type == 'collider_sphere'){
     return colliderSphere();
    }
    else if(type == 'collider_cylinder'){
      return colliderCylinder();
    }
    else if(type == 'plane'){
      return plane();
    }
    else if(type == 'cube'){
      return cube();
    }
    else if(type == 'circle'){
      return circle();
    }
    else if(type == 'sphere'){
      return sphere();
    }
    else if(type == 'ico_sphere'){
      return icoSphere();
    }
    else if(type == 'cylinder'){
      return cylinder();
    }
    else if(type == 'cone'){
      return cone();
    }
    else if(type == 'torus'){
      return torus();
    }
    else if(type == 'parametric_plane'){
      return parametricPlane();
    }
    else if(type == 'parametric_klein'){
      return parametricKlein();
    }
    else if(type == 'parametric_mobius'){
      return parametricMobius();
    }
    else if(type == 'parametric_torus'){
      return parametricTorus();
    }
    else if(type == 'parametric_sphere'){
      return parametricSphere();
    }
    return  null;
  }

  static void addPhysics(three.Object3D object){
    object.userData['addPhysics'] = true;
    object.userData['physics'] ??= {
      'allowSleep': true,
      'type': 'Static',
      'name': '',
      'isSleeping': false,
      'adjustPosition': true,
      'mass': 0.0,
      'isTrigger': false,
      'linearVelocity': [0,0,0],
      'angularVelocity': [0,0,0],
      'shapes': {}
    };
  }

  static void subdivision(three.Object3D object, bool flatOnly){
    object.userData['subdivisionType'] = !flatOnly?'catmull':'simple';
    final smoothGeometry = LoopSubdivision.modify(
      object.userData['origionalGeometry'], 
      object.userData['subdivisions'], 
      LoopParameters(
        split: true,
        uvSmooth: false,
        preserveEdges: false,
        flatOnly: flatOnly,
      )
    );

    object.geometry = smoothGeometry;
  }

  static void decimate(three.Object3D object){
    if(object.userData['decimate'] != null && object.userData['decimate'] != 0){
      final count = ( object.userData['origionalGeometry']?.attributes['position'].count * (object.userData['decimate']/100) ).floor();
      final smoothGeometry = SimplifyModifier.modify(object.userData['origionalGeometry'], count );

      object.geometry = smoothGeometry;
    }
  }

  static void simplify(three.Object3D object, double percent){
    int count = ( object.geometry?.attributes['position'].count * percent/100 ).floor();
    SimplifyModifier.modify( object.geometry!, count );
  }

  static three.Mesh colliderCube(){
    final object = three.Mesh(three.BoxGeometry(),three.MeshBasicMaterial.fromMap({'wireframe': true, 'color': 0x00ff00}));
    object.name = 'Collider-Cube';
    object.userData['meshType'] = 'collider_cube';
    addPhysics(object);
    return object;
  }
  static three.Mesh colliderSphere(){
    final object = three.Mesh(three.SphereGeometry(1,8,8),three.MeshBasicMaterial.fromMap({'wireframe': true, 'color': 0x00ff00}));
    object.name = 'Collider-Sphere';
    object.userData['meshType'] = 'collider_sphere';
    addPhysics(object);
    return object;
  }
  static three.Mesh colliderCylinder(){
    final object = three.Mesh(three.CylinderGeometry(1,1,2),three.MeshBasicMaterial.fromMap({'wireframe': true, 'color': 0x00ff00}));
    object.name = 'Collider-Cylinder';
    object.userData['meshType'] = 'collider_cylinder';
    addPhysics(object);
    return object;
  }
  static three.Mesh colliderCapsule(){
    final object = three.Mesh(three.CapsuleGeometry(length:2),three.MeshBasicMaterial.fromMap({'wireframe': true, 'color': 0x00ff00}));
    object.name = 'Collider-Capsule';
    object.userData['meshType'] = 'collider_capsule';
    addPhysics(object);
    return object;
  }

  static three.Mesh plane(){
    final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Plane';
    object.userData['meshType'] = 'plane';
    object.add(h);
    return object;
  }
  static three.Mesh cube(){
    final object = three.Mesh(three.BoxGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Cube';
    object.userData['meshType'] = 'cube';
    object.add(h);
    return object;
  }
  static three.Mesh circle(){
    final object = three.Mesh(three.CircleGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Circle';
    object.userData['meshType'] = 'circle';
    object.add(h);
    return object;
  }
  static three.Mesh sphere(){
    final object = three.Mesh(three.SphereGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Sphere';
    object.userData['meshType'] = 'sphere';
    object.add(h);
    return object;
  }
  static three.Mesh icoSphere(){
    final object = three.Mesh(three.IcosahedronGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Ico Sphere';
    object.userData['meshType'] = 'ico_sphere';
    object.add(h);
    return object;
  }
  static three.Mesh cylinder(){
    final object = three.Mesh(three.CylinderGeometry(1,1,2),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Cylinder';
    object.userData['meshType'] = 'cylinder';
    object.add(h);
    return object;
  }
  static three.Mesh cone(){
    final object = three.Mesh(three.ConeGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Cone';
    object.userData['meshType'] = 'cone';
    object.add(h);
    return object;
  }
  static three.Mesh capsule(){
    final object = three.Mesh(three.CapsuleGeometry(length:2),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Capsule';
    object.userData['meshType'] = 'capsule';
    object.add(h);
    return object;
  }
  static three.Mesh torus(){
    final object = three.Mesh(three.TorusGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Torus';
    object.userData['meshType'] = 'torus';
    object.add(h);
    return object;
  }

  static three.Mesh parametricPlane(){
    three.ParametricGeometry geometry;
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true,'side': three.DoubleSide});

    geometry = three.ParametricGeometry( three.ParametricGeometries.plane( 1, 1 ), 10, 10 );
    geometry.center();
    object = three.Mesh( geometry, material);

    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'P-Plane';
    object.userData['meshType'] = 'parametric_plane';
    object.add(h);
    return object;
  }

  static three.Mesh parametricKlein(){
    three.ParametricGeometry geometry;
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true,'side': three.DoubleSide});

    geometry = three.ParametricGeometry( three.ParametricGeometries.klein, 20, 20 );
    object = three.Mesh( geometry, material );
    object.scale.scale( 0.2 );

    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Klein';
    object.userData['meshType'] = 'parametric_klein';
    object.add(h);
    return object;
  }
  static three.Mesh parametricMobius(){
    three.ParametricGeometry geometry;
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true,'side': three.DoubleSide});

    geometry = three.ParametricGeometry( three.ParametricGeometries.mobius, 20, 20 );
    object = three.Mesh( geometry, material );
    object.scale.scale( 0.5 );

    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Mobius';
    object.userData['meshType'] = 'parametric_mobius';
    object.add(h);
    return object; 
  }

  static three.Mesh parametricTorus(){
    final torus = three.ParametricTorusKnotGeometry( 1, 0.2, 50, 20, 2, 3 );
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true});

    object = three.Mesh( torus, material );
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Torus';
    object.userData['meshType'] = 'parametric_torus';
    object.add(h);
    return object;  
  }

  static three.Mesh parametricSphere(){
    final sphere = three.ParametricSphereGeometry( 1, 20, 10 );
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true});

    object = three.Mesh( sphere, material );
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'P-Sphere';
    object.userData['meshType'] = 'parametric_sphere';
    object.add(h);
    return object; 
  }
}