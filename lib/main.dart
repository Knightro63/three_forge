import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/screens/dashboard.dart';
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
  // This widget is the root of your application.
  Map<String,dynamic>? currentProject;

  void setProject(Map<String,dynamic>? project){
    currentProject = project;
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CSS.darkTheme,//ThemeData.dark(),
      home: currentProject != null?UIScreen(currentProject: currentProject!,setProject: setProject,):Dashboard(setProject: setProject,)
    );
  }
}