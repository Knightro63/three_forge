import 'package:three_forge/src/objects/create_mesh.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class InsertMesh{
  ThreeViewer threeV;
  InsertMesh(this.threeV);

  Future<void> insert(String type)async{
    if(type == 'collider_cube'){
      colliderCube();
    }
    else if(type == 'collider_sphere'){
     colliderSphere();
    }
    else if(type == 'collider_cylinder'){
      colliderCylinder();
    }
    else if(type == 'plane'){
      plane();
    }
    else if(type == 'cube'){
      cube();
    }
    else if(type == 'circle'){
      circle();
    }
    else if(type == 'sphere'){
      sphere();
    }
    else if(type == 'ico_sphere'){
      icoSphere();
    }
    else if(type == 'cylinder'){
      cylinder();
    }
    else if(type == 'cone'){
      cone();
    }
    else if(type == 'torus'){
      torus();
    }
    else if(type == 'parametric_plane'){
      parametricPlane();
    }
    else if(type == 'parametric_klein'){
      parametricKlein();
    }
    else if(type == 'parametric_mobius'){
      parametricMobius();
    }
    else if(type == 'parametric_torus'){
      parametricTorus();
    }
    else if(type == 'parametric_sphere'){
      parametricSphere();
    }
  }

  void colliderCube(){
    threeV.add(CreateMesh.colliderCube());
  }
  void colliderSphere(){
    threeV.add(CreateMesh.colliderSphere());
  }
  void colliderCylinder(){
    threeV.add(CreateMesh.colliderCylinder());
  }

  void plane(){
    threeV.add(CreateMesh.plane());
  }
  void cube(){
    threeV.add(CreateMesh.cube());
  }
  void circle(){
    threeV.add(CreateMesh.circle());
  }
  void sphere(){
    threeV.add(CreateMesh.sphere());
  }
  void icoSphere(){
    threeV.add(CreateMesh.icoSphere());
  }
  void cylinder(){
    threeV.add(CreateMesh.cylinder());
  }
  void cone(){
    threeV.add(CreateMesh.cone());
  }
  void torus(){
    threeV.add(CreateMesh.torus());
  }

  void parametricPlane(){
    threeV.add(CreateMesh.parametricPlane());
  }

  void parametricKlein(){
    threeV.add(CreateMesh.parametricKlein());
  }
  void parametricMobius(){
    threeV.add(CreateMesh.parametricMobius());   
  }

  void parametricTorus(){
    threeV.add(CreateMesh.parametricTorus()); 
  }

  void parametricSphere(){
    threeV.add(CreateMesh.parametricSphere()); 
  }
}