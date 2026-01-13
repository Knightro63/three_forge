import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';

const String startingYaml = '''
name: `app_name`
description: "`app_description`"
publish_to: 'none' # Remove this line if you wish to publish to pub.dev
version: `app_version`

environment:
  sdk: `app_sdk_environment

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
  ThreeViewer threeV;

  CreateYaml(this.threeV);

  Future<String> create() async{
    String mod = startingYaml;
    mod.replaceAll('`app_name`', threeV.fileSort.sceneName);
    mod.replaceAll('`app_description`', threeV.fileSort.description);
    mod.replaceAll('`app_version`', threeV.fileSort.versionName);

    final FileLoader loader = FileLoader();

    final tjsVersion = await loader.fromNetwork(Uri.parse('https://img.shields.io/pub/v/three_js'));
    print(tjsVersion);
    mod.replaceAll('`three_js_version`', '^');

    String addDep = '';
    String? addAudio;
    String? addVideo;
    String? addAssets;

    for(final o in threeV.scene.children){
      if(o.userData['terrain_id'] == null){
        final dep = await loader.fromNetwork(Uri.parse('https://img.shields.io/pub/v/three_js_terrain'));
        addDep += 'three_js_terrain: ^\n';
      }
      else if(o.userData['audio'] != null && addAudio == null){
        final dep = await loader.fromNetwork(Uri.parse('https://img.shields.io/pub/v/three_js_audio_latency'));
        addAudio = 'three_js_audio_latency: ^\n';
      }
      else if(o.userData['video'] != null && addVideo == null){
        final dep = await loader.fromNetwork(Uri.parse('https://img.shields.io/pub/v/three_js_video_texture'));
        addVideo = 'three_js_video_texture: ^\n';
      }
      else if(o.userData['path'] != null){
        //"/Documents/Temp/example_project/assets/animations/Dribble.fbx"
        List<String> split = (o.userData['path'] as String).split(threeV.dirPath);
        addAssets = '- \n';
      }
    }

    if(addVideo != null){
      addDep += addVideo;
    }
    else if(addAudio != null){
      addDep += addAudio;
    }

    if(addDep != ''){
      mod = mod.replaceAll('`other_dependencies`', 'addDep');
    }
    else{
      mod = mod.replaceAll('`other_dependencies`', '');
    }

    if(addAssets != null){

    }
    else{
      mod = mod.replaceAll('`your_assets`', '');
    }

    return mod;
  }
}