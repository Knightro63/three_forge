import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/screens/dashboard.dart';
import 'package:three_forge/screens/loading.dart';
import 'package:three_forge/src/styles/config.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'screens/work.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}):super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Config config = Config();
  Map<String,dynamic>? currentProject;
  bool loading = true;

  @override
  void initState(){
    super.initState();
    config.init().then((_){
      themeType = CSS.themeFromString(config.getSettingKey('theme')?? 'dark');
      theme = CSS.changeTheme(themeType);
      setState(() {});
    });
  }

  void setProject(Map<String,dynamic>? project){
    currentProject = project;
    setState(() {});
  }

  void doneLoading(){
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: loading?LoadingScreen(onDone: doneLoading):currentProject != null?UIScreen(currentProject: currentProject!,setProject: setProject,):Dashboard(setProject: setProject,onDone: doneLoading,config: config,)
    );
  }
}