import 'package:three_js/three_js.dart';
import 'package:three_js_video_texture/video_audio.dart';

class CreateAudio{
  static Object3D? createAudio(String type, String path,[Object3D? listener]){
    if(type == 'Positional'){
      return listener == null?null:positional(path,listener);
    }
    else if(type == 'Audio'){
      return surround(path);
    }

    return null;
  }

  static PositionalAudio positional(String path, Object3D listener){
    final a = surround(path);
    final audio = PositionalAudio(audioSource: a, listner: listener);
    audio.name = 'Positional Audio';
    final helper = PositionalAudioHelper(audio);
    audio.userData['skeleton'] = helper;
    return audio;
  }

  static VideoAudio surround(String path){
    final audio = VideoAudio(path: path);
    audio.name = 'Audio';
    return audio;
  }
}