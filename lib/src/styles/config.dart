import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_js/three_js.dart';

class Config{
  late final SharedPreferences prefs;

  Future<void> init() async{
    await SharedPreferences.getInstance().then((value){
      prefs = value;

      if ( !prefs.containsKey(name) ) {
        prefs.setString(name,jsonEncode( storage ));
      } 
      else {
        final data = jsonDecode(prefs.getString(name)!);
        storage = data;
      }
    });
  }

	String name = 'three_forge';
	List<String> suggestedLanguage = [ 'fr', 'ja', 'zh', 'ko', 'fa', 'en' ];

	Map<String,dynamic> storage = {
    'settings':{
      'autosave': false,
      'antialias': true,
      'translate': 'w',
      'rotate': 'e',
      'scale': 'r',
      'theme': 'dark',
      'language': 'en'
    },
    'projects': <Map<String,dynamic>>[]
	};

  getSettingKey(String key ) {
    return storage['settings'][ key ];
  }
  Map<String,dynamic> getProject(int key ) {
    return storage['projects'][ key ] as Map<String,dynamic>;
  }
  List<dynamic> getAllProjects() {
    return storage['projects'];
  }
  Future<void> setSettingsKey(Map<String,dynamic> arguments) async{
    for (final key in arguments.keys ) {
      storage['settings'][ key] = arguments[ key ];
    }

    await prefs.setString(name,jsonEncode( storage ));
    console.info( '[${DateTime.now()}]: Saved config to LocalStorage.' );
  }
  Future<void> setKey(Map<String,dynamic> arguments) async{
    for (final key in arguments.keys ) {
      storage[ key] = arguments[ key ];
    }

    await prefs.setString(name,jsonEncode( storage ));
    console.info( '[${DateTime.now()}]: Saved config to LocalStorage.' );
  }
  Future<void> setProject(Map<String,dynamic> project) async{
    storage['projects'].add(project);
    await prefs.setString(name,jsonEncode( storage ));
    console.info( '[${DateTime.now()}]: Saved config to LocalStorage.' );
  }
  Future<void> removeProject(Map<String,dynamic> project) async{
    storage['projects'].remove(project);
    await prefs.setString(name,jsonEncode( storage ));
    console.info( '[${DateTime.now()}]: Saved config to LocalStorage.' );
  }
  Future<void> addMap(String key, List<Map<String,dynamic>> map) async{
    final List<String> sl = [];
    for(final p in map){
      sl.add(json.encode(p));
    }
    await prefs.setStringList(key, sl);
  }

  void clear () {
    prefs.remove(name);
  }
}
