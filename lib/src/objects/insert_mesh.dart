import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class InsertMesh{
  ThreeViewer threeV;
  InsertMesh(this.threeV);

  void plane(){
    final object = three.Mesh(three.PlaneGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Plane';
    threeV.add(object.add(h));
  }
  void cube(){
    final object = three.Mesh(three.BoxGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.receiveShadow = true;
    object.name = 'Cube';
    threeV.add(object.add(h));
  }
  void circle(){
    final object = three.Mesh(three.CircleGeometry(),three.MeshPhongMaterial.fromMap({'side': three.DoubleSide, 'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Circle';
    threeV.add(object.add(h));
  }
  void sphere(){
    final object = three.Mesh(three.SphereGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Sphere';
    threeV.add(object.add(h));
  }
  void icoSphere(){
    final object = three.Mesh(three.IcosahedronGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Ico Sphere';
    threeV.add(object.add(h));
  }
  void cylinder(){
    final object = three.Mesh(three.CylinderGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Cylinder';
    threeV.add(object.add(h));
  }
  void cone(){
    final object = three.Mesh(three.ConeGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Cone';
    threeV.add(object.add(h));
  }
  void torus(){
    final object = three.Mesh(three.TorusGeometry(),three.MeshPhongMaterial.fromMap({'flatShading': true}));
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Torus';
    threeV.add(object.add(h));
  }

  void parametricPlane(){
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
    threeV.add(object.add(h));
  }

  void parametricKlein(){
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
    threeV.add(object.add(h));  
  }
  void parametricMobius(){
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
    threeV.add(object.add(h));    
  }

  void parametricTorus(){
    final torus = three.ParametricTorusKnotGeometry( 1, 0.2, 50, 20, 2, 3 );
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true});

    object = three.Mesh( torus, material );
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'Torus';
    threeV.add(object.add(h));   
  }

  void parametricSphere(){
    final sphere = three.ParametricSphereGeometry( 1, 20, 10 );
    three.Mesh object;
    final material = three.MeshPhongMaterial.fromMap({'flatShading': true});

    object = three.Mesh( sphere, material );
    final three.BoundingBox box = three.BoundingBox();
    box.setFromObject(object);     
    BoundingBoxHelper h = BoundingBoxHelper(box)..visible = false;
    object.name = 'P-Sphere';
    threeV.add(object.add(h));  
  }
}