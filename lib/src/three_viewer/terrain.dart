import 'dart:typed_data';
import 'package:three_forge/src/image/change_image.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_geometry/three_js_geometry.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'dart:math' as math;
import 'dart:async';
import 'package:three_js_terrain/three_js_terrain.dart' as terrain;

class Terrain{
  ThreeViewer scene;
  three.Material? blend;
  late Uint8List heightmap;

  three.Object3D? terrainScene;
  Uint8List? heightMapImage;
  int id;
  void Function(void Function()) update;

  Terrain(this.scene,this.update,this.id);

  void toHeightMap(){
    if (lastOptions.heightmap != null) {
      terrain.Terrain.toHeightmap(terrainScene!.children[0].geometry!.attributes['position'].array.toDartList(), lastOptions);
    }
  }

  three.Object3D buildTree() {
    final green = three.MeshLambertMaterial.fromMap({ 'color': 0x2d4c1e });

    final c0 = three.Mesh(
      CylinderGeometry(2, 2, 12, 6, 1, true),
      three.MeshLambertMaterial.fromMap({ 'color': 0x3d2817 }) // brown
    );
    c0.position.setY(6);

    final c1 = three.Mesh(CylinderGeometry(0, 10, 14, 8), green);
    c1.position.setY(18);
    final c2 = three.Mesh(CylinderGeometry(0, 9, 13, 8), green);
    c2.position.setY(25);
    final c3 = three.Mesh(CylinderGeometry(0, 8, 12, 8), green);
    c3.position.setY(32);

    final s = three.Object3D();
    s.add(c0);
    s.add(c1);
    s.add(c2);
    s.add(c3);
    s.scale.setValues(5, 1.25, 5);

    return s;
  }

  void applySmoothing(smoothing, terrain.TerrainOptions o) {
    three.Object3D m = terrainScene!.children[0];
    Float32List g = terrain.Terrain.toArray1D(m.geometry!.attributes['position'].array.toDartList());
    if (smoothing == 'Conservative (0.5)') terrain.Terrain.smoothConservative(g, o, 0.5);
    if (smoothing == 'Conservative (1)') terrain.Terrain.smoothConservative(g, o, 1);
    if (smoothing == 'Conservative (10)'){ terrain.Terrain.smoothConservative(g, o, 10);}
    else if (smoothing == 'Gaussian (0.5, 7)'){ terrain.Gaussian(g, o, 0.5, 7);}
    else if (smoothing == 'Gaussian (1.0, 7)'){ terrain.Gaussian(g, o, 1, 7);}
    else if (smoothing == 'Gaussian (1.5, 7)'){ terrain.Gaussian(g, o, 1.5, 7);}
    else if (smoothing == 'Gaussian (1.0, 5)'){ terrain.Gaussian(g, o, 1, 5);}
    else if (smoothing == 'Gaussian (1.0, 11)'){ terrain.Gaussian(g, o, 1, 11);}
    else if (smoothing == 'GaussianBox'){ terrain.GaussianBoxBlur(g, o, 1, 3);}
    else if (smoothing == 'Mean (0)'){ terrain.Terrain.smooth(g, o, 0);}
    else if (smoothing == 'Mean (1)'){ terrain.Terrain.smooth(g, o, 1);}
    else if (smoothing == 'Mean (8)'){ terrain.Terrain.smooth(g, o, 8);}
    else if (smoothing == 'Median'){ terrain.Terrain.smoothMedian(g, o);}
    terrain.Terrain.fromArray1D(m.geometry!.attributes['position'].array.toDartList(), g);
    terrain.Terrain.normalize(m, o);
  }

  void customInfluences(Float32List g, terrain.TerrainOptions options) {
    final clonedOptions = terrain.TerrainOptions();
    for (final opt in options.keys) {
      if (options.containsKey(opt)) {
        clonedOptions[opt] = options[opt];
      }
    }
    clonedOptions.maxHeight = options.maxHeight! * 0.67;
    clonedOptions.minHeight = options.minHeight! * 0.67;
    terrain. Generators.diamondSquare(g, clonedOptions);

    var radius = math.min(options.xSize, options.ySize) * 0.21,
        height = options.maxHeight! * 0.8;
    terrain.Terrain.influence(
      g, options,
      terrain.Terrain.influences[terrain.InfluenceType.hill],
      0.25, 0.25,
      radius, height,
      three.AdditiveBlending,
      terrain.Easing.linear
    );
    terrain.Terrain.influence(
      g, options,
      terrain.Terrain.influences[terrain.InfluenceType.mesa],
      0.75, 0.75,
      radius, height,
      three.SubtractiveBlending,
      terrain.Easing.easeInStrong
    );
    terrain.Terrain.influence(
      g, options,
      terrain.Terrain.influences[terrain.InfluenceType.flat],
      0.75, 0.25,
      radius, options.maxHeight,
      three.NormalBlending,
      terrain.Easing.easeIn
    );
    terrain.Terrain.influence(
      g, options,
      terrain.Terrain.influences[terrain.InfluenceType.volcano],
      0.25, 0.75,
      radius, options.maxHeight,
      three.NormalBlending,
      terrain.Easing.easeInStrong
    );
  }

  terrain.TerrainOptions lastOptions = terrain.TerrainOptions();
  three.Object3D? decoScene;
  void after(Float32List vertices, terrain.TerrainOptions options) {
    if (guiSettings['edgeDirection'] != 'Normal') {
      (guiSettings['edgeType'] == 'Box' ? terrain.Terrain.edges : terrain.Terrain.radialEdges)(
        vertices,
        options,
        guiSettings['edgeDirection'] == 'Up' ? true : false,
        guiSettings['edgeType'] == 'Box' ? guiSettings['edgeDistance'] : math.min(options.xSize, options.ySize) * 0.5 - guiSettings['edgeDistance'],
        terrain.Easing.fromString(guiSettings['edgeCurve'])
      );
    }
  }

  Map<String,dynamic> guiSettings = {
    'lightColor': 0xe8bdb0,
    'easing': 'Linear',
    'heightmap': 'Perlin',
    'smoothing': 'None',
    'maxHeight': 200.0,
    'segments': 127.0,
    'steps': 8.0,
    'turbulent': true,
    'size': 1024.0,
    'sky': true,
    'texture': 'Blended',
    'edgeDirection': 'Normal',
    'edgeType': 'Box',
    'edgeDistance': 256.0,
    'edgeCurve': 'EaseInOut',
    'ratio': 1.0,
    'flightMode':false,//useFPS;
    'spread': 60.0,
    'scattering': 'PerlinAltitude',//'PerlinAltitude';
  };

  Future<void> getHeightMapFromImage(String assetImage) async{
    final ByteData fileData = await rootBundle.load(assetImage);
    final bytes = fileData.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytes);
    heightmap = image!.getBytes();
  }

  Future<void> setup() async{
    three.TextureLoader loader = three.TextureLoader();
    final t1 = await loader.fromAsset('assets/terrain/grass1.jpg');
    t1?.wrapS = t1.wrapT = three.RepeatWrapping;

    final t3 = await loader.fromAsset('assets/terrain/grass1.jpg');
    final t2 = await loader.fromAsset('assets/terrain/stone1.jpg');
    final t4 = await loader.fromAsset('assets/terrain/sand1.jpg');
    t3?.repeat.setValues( 250,250 );
    t4?.repeat.setValues( 250,250 );

    blend = terrain.Terrain.generateBlendedMaterial([
      terrain.TerrainTextures(texture: t1!),
      terrain.TerrainTextures(texture: t2!, levels: [-80, -35, 20, 50]),
      terrain.TerrainTextures(texture: t3!, levels: [20, 50, 60, 85]),
      terrain.TerrainTextures(texture: t4!, glsl: '1.0 - smoothstep(65.0 + smoothstep(-256.0, 256.0, vPosition.x) * 10.0, 80.0, vPosition.z)'),
      terrain.TerrainTextures(texture: t3, glsl: 'slope > 0.7853981633974483 ? 0.2 : 1.0 - smoothstep(0.47123889803846897, 0.7853981633974483, slope) + 0.2'), // between 27 and 45 degrees
    ]);
    

    regenerate();
  }

  void scatterMeshes() {
    if(true ){
      var mesh = buildTree();
      var s = guiSettings['segments'].toInt(),
          sprd,
          randomness;
      var o = terrain.TerrainOptions(
        xSegments: s,
        ySegments: (s * guiSettings['ratio']).round(),
      );
      if (guiSettings['scattering'] == 'Linear') {
        sprd = guiSettings['spread'] * 0.0005;
        randomness = (k){return math.Random().nextDouble();};
      }
      else if (guiSettings['scattering'] == 'Altitude') {
        sprd = altitudeSpread;
      }
      else if (guiSettings['scattering'] == 'PerlinAltitude') {
        sprd = ((){
          var h = terrain.Terrain.scatterHelper(terrain.Generators.perlin, o, 2, 0.125)(),
              hs = terrain.Easing.inEaseOut(guiSettings['spread'] * 0.01);
          return (three.Vector3 v, double k, three.Vector3 v2, int i) {
            var rv = h[k.toInt()],
                place = false;
            if (rv < hs) {
              place = true;
            }
            else if (rv < hs + 0.2) {
              place = terrain.Easing.easeInOut((rv - hs) * 5) * hs < math.Random().nextDouble();
            }
            return math.Random().nextDouble() < altitudeProbability(v.z) * 5 && place;
          };
        })();
      }
      else {
        // sprd = terrain.Easing.inEaseOut(guiSettings['spread']*0.01) * (guiSettings['scattering'] == 'Worley' ? 1 : 0.5);
        // final l = terrain.Terrain.scatterHelper(terrain.Terrain.fromString(guiSettings['scattering'])!, o, 2, 0.125);
        //randomness = (k){return l()[k.toInt()];};
      }
      var geo = terrainScene!.children[0].geometry!;
      if(decoScene != null){
        terrainScene!.remove(decoScene!);
      }
      decoScene = terrain.Terrain.scatterMeshes(geo, terrain.ScatterOptions(
        mesh: mesh,
        w: s.toDouble(),
        h: (s * guiSettings['ratio']).roundToDouble(),
        spread: sprd is double ?sprd:0.025,
        spreadFunction: sprd is double ?null:sprd,
        smoothSpread: guiSettings['scattering'] == 'Linear' ? 0 : 0.2,
        randomness: randomness,
        maxSlope: 0.6283185307179586, // 36deg or 36 / 180 * Math.PI, about the angle of repose of earth
        maxTilt: 0.15707963267948966, //  9deg or  9 / 180 * Math.PI. Trees grow up regardless of slope but we can allow a small variation
      ));
      if (decoScene != null) {
        terrainScene!.add(decoScene);
      }
    }
    update((){});
  }

  void regenerate(){
    three.Vector3 scale = terrainScene?.scale ?? three.Vector3(0.05,0.05,0.05);
    var mat = three.MeshBasicMaterial.fromMap({'color': 0x5566aa, 'wireframe': true});
    var gray = three.MeshPhongMaterial.fromMap({ 'color': 0x88aaaa, 'specular': 0x444455, 'shininess': 10 });

    var s = guiSettings['segments'].toInt(),//int.parse(segments, 10),
        h = guiSettings['heightmap'] == 'heightmap.png';
    double size = guiSettings['size'].toDouble();
    var o = terrain.TerrainOptions(
      after: after,
      easing: terrain.Easing.fromString(guiSettings['easing'])!,
      heightmap: h? heightmap:guiSettings['heightmap'] == 'influences' ? customInfluences :terrain.Terrain.fromString(guiSettings['heightmap']),//heightMapImage,//h ? heightmapImage : (heightmap == 'influences' ? customInfluences : THREE.Terrain[heightmap]),
      material: guiSettings['texture'] == 'Wireframe' ? mat : (guiSettings['texture'] == 'Blended' ? blend : gray),
      maxHeight: guiSettings['maxHeight'] - 100,
      minHeight: -100,
      steps: guiSettings['steps'].toInt(),
      stretch: true,
      turbulent: guiSettings['turbulent'],
      xSize: size,
      ySize: (size * guiSettings['ratio']).roundToDouble(),
      xSegments: s,
      ySegments: (s * guiSettings['ratio']).round(),
    );
    if(terrainScene != null){
      scene.remove(terrainScene!);
    }
    terrainScene = terrain.Terrain.create(o);
    applySmoothing(guiSettings['smoothing'], o);
    
    terrainScene!.scale.setFrom(scale);
    terrainScene!.position.y = -1.25;
    terrainScene!.rotation.x = - math.pi / 2;
    terrainScene!.name = 'terrain_$id';

    scene.add(terrainScene);

    heightMapImage = terrain.Terrain.toHeightmap(terrainScene!.children[0].geometry!.attributes['position'].array.toDartList(), o);
    heightMapImage = rgba2bitmap(heightMapImage!, o.xSegments+1, o.ySegments+1);
    lastOptions = o;


    //scatterMeshes();
    update((){});
  }
  double altitudeProbability(double z) {
    if (z > -80 && z < -50){ return terrain.Easing.easeInOut((z + 80) / (-50 + 80)) * guiSettings['spread'] * 0.002;}
    else if (z > -50 && z < 20) {return guiSettings['spread'] * 0.002;}
    else if (z > 20 && z < 50) {return terrain.Easing.easeInOut((z - 20) / (50 - 20)) * guiSettings['spread'] * 0.002;}
    return 0;
  }
  bool altitudeSpread(three.Vector3 v,double k,three.Vector3 v2,int i){//double v, double k) {
    return k % 4 == 0 && math.Random().nextDouble() < altitudeProbability(v.z);
  }
}
