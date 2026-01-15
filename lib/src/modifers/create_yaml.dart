import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

const String startingYaml = '''
name: `app_name`
description: "`app_description`"
publish_to: 'none' # Remove this line if you wish to publish to pub.dev
version: `app_version`

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  three_js: `three_js_version`
  `other_dependencies`

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    `your_assets`
''';

class CreateYaml {
  static Future<String> create(ThreeViewer threeV) async{
    final FileLoader loader = FileLoader();

    Future<String> getVersion(String uri) async{
      final tjsVersion = await loader.fromNetwork(Uri.parse(uri));
      final version = String.fromCharCodes(tjsVersion!.data).split('"><title>').first.split('pub: v').last;
      return version;
    }

    String mod = startingYaml;
    mod = mod.replaceAll('`app_name`', threeV.fileSort.appName);
    mod = mod.replaceAll('`app_description`', threeV.fileSort.description);
    mod = mod.replaceAll('`app_version`', threeV.fileSort.versionName);
    mod = mod.replaceAll('`three_js_version`', '^${await getVersion('https://img.shields.io/pub/v/three_js')}');

    String addDep = '';
    String? addAudio;
    String? addVideo;
    List<String> addAssets = [];

    for(final o in threeV.scene.children){
      if(o.userData['terrain_id'] != null){
        addDep += 'three_js_terrain: ^${await getVersion('https://img.shields.io/pub/v/three_js_terrain')}\n';
      }
      else if(o.userData['audio'] != null && addAudio == null){
        addAudio = 'three_js_audio_latency: ^${await getVersion('https://img.shields.io/pub/v/three_js_audio_latency')}\n';
      }
      else if(o.userData['video'] != null && addVideo == null){
        addVideo = 'three_js_video_texture: ^${await getVersion('https://img.shields.io/pub/v/three_js_video_texture')}\n';
      }
      else if(o.userData['path'] != null){
        String path = (o.userData['path'] as String).split(threeV.dirPath).last;
        String toRemove = path.split('/').last;
        addAssets.add(path.replaceAll(toRemove, ''));
      }
    }

    if(addVideo != null){
      addDep += addVideo;
    }
    else if(addAudio != null){
      addDep += addAudio;
    }

    if(addDep != ''){
      mod = mod.replaceAll('`other_dependencies`', addDep);
    }
    else{
      mod = mod.replaceAll('`other_dependencies`', '');
    }

    if(addAssets.isNotEmpty){
      String setAssets = '';
      for(final a in addAssets){
        setAssets += '- $a';
      }
      mod = mod.replaceAll('`your_assets`', setAssets);
    }
    else{
      mod = mod.replaceAll('`your_assets`', '');
    }

    return mod;
  }
}