import 'dart:typed_data';
import 'package:three_forge/src/image/change_image.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

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
  String _currenPath = '';

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

  Map<String,dynamic> guiSettings = {
    'easing': 'Linear',
    'heightmap': 'Perlin',
    'imagePath': '',
    'smoothing': 'None',
    'maxHeight': 200.0,
    'segments': 127.0,
    'steps': 8.0,
    'turbulent': true,
    'size': 1024.0,
    'edgeCurve': 'EaseInOut',
    'ratio': 1.0,
  };

  Future<void> getHeightMapFromImage(String assetImage) async{
    final ByteData fileData = await rootBundle.load(assetImage);
    final bytes = fileData.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytes);
    heightmap = image!.getBytes();
  }

  Future<void> setup() async{

    three.TextureLoader loader = three.TextureLoader();
    final t1 = await loader.fromAsset('assets/terrain/sand1.jpg');
    t1?.wrapS = t1.wrapT = three.RepeatWrapping;
    // sand = three.Mesh(
    //   three.PlaneGeometry(16384+1024, 16384+1024, 64, 64),
    //   three.MeshLambertMaterial.fromMap({'map': t1})
    // );
    // sand.position.y = -101;
    // sand.rotation.x = -0.5 * math.pi;
    // threeJs.scene.add(sand);

    final t2 = await loader.fromAsset('assets/terrain/grass1.jpg');
    final t3 = await loader.fromAsset('assets/terrain/stone1.jpg');
    final t4 = await loader.fromAsset('assets/terrain/snow1.jpg');

    blend = terrain.Terrain.generateBlendedMaterial([
      terrain.TerrainTextures(texture: t1!),
      terrain.TerrainTextures(texture: t2!, levels: [-80, -35, 20, 50]),
      terrain.TerrainTextures(texture: t3!, levels: [20, 50, 60, 85]),
      terrain.TerrainTextures(texture: t4!, glsl: '1.0 - smoothstep(65.0 + smoothstep(-256.0, 256.0, vPosition.x) * 10.0, 80.0, vPosition.z)'),
      terrain.TerrainTextures(texture: t3, glsl: 'slope > 0.7853981633974483 ? 0.2 : 1.0 - smoothstep(0.47123889803846897, 0.7853981633974483, slope) + 0.2'), // between 27 and 45 degrees
    ]);

    regenerate();
  }

  void regenerate(){
    three.Vector3 scale = terrainScene?.scale ?? three.Vector3(0.05,0.05,0.05);
    three.Vector3 position = terrainScene?.position ?? three.Vector3(0,-1.25,0);
    three.Euler rotation = terrainScene?.rotation ?? three.Euler(- math.pi / 2,0,0);

    var s = guiSettings['segments'].toInt();//int.parse(segments, 10),
    bool h = guiSettings['imagePath'] != '';
    double size = guiSettings['size'].toDouble();
    if(_currenPath != guiSettings['imagePath'] || !h){
      var o = terrain.TerrainOptions(
        easing: terrain.Easing.fromString(guiSettings['easing'])!,
        heightmap: h? heightmap:guiSettings['heightmap'] == 'influences' ? customInfluences :terrain.Terrain.fromString(guiSettings['heightmap']),
        material: blend,
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
      terrainScene!.position.setFrom(position);
      terrainScene!.rotation.copy(rotation);
      terrainScene!.name = 'terrain_$id';

      scene.add(terrainScene);

      heightMapImage = terrain.Terrain.toHeightmap(terrainScene!.children[0].geometry!.attributes['position'].array.toDartList(), o);
      heightMapImage = rgba2bitmap(heightMapImage!, o.xSegments+1, o.ySegments+1);
      lastOptions = o;

      update((){});
      _currenPath = guiSettings['imagePath'];
    }
  }
}
