import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/navigation/screen_navigator.dart';
import 'package:three_forge/src/three_viewer.dart/file_navigation.dart';
import 'package:three_forge/src/three_viewer.dart/hud.dart';
import 'package:three_forge/src/three_viewer.dart/intersected_gui.dart';
import 'package:three_forge/src/three_viewer.dart/scene_collection.dart';
import 'package:three_forge/src/three_viewer.dart/viewer.dart';
import '../src/navigation/right_click.dart';
import 'package:three_js/three_js.dart' as three;
import '../src/navigation/navigation.dart';
import '../src/styles/globals.dart';

class UIScreen extends StatefulWidget {
  const UIScreen({Key? key, required this.currentProject, required this.setProject}):super(key: key);
  final Map<String,dynamic> currentProject;
  final void Function(Map<String,dynamic>?) setProject;

  @override
  _UIPageState createState() => _UIPageState();
}

class _UIPageState extends State<UIScreen> {
  late final ScreenNavigator screenNav = ScreenNavigator(scene, setState, callBacks);
  late final ThreeViewer threeV;
  
  bool resetNav = false;

  late RightClick rightClick;
  late three.Scene scene = threeV.scene;

  @override
  void initState(){
    rightClick = RightClick(
      context: context,
      style: null,
      onTap: rightClickActions,
    );
    threeV = ThreeViewer(setState,rightClick);
    super.initState();
  }
  @override
  void dispose(){
    threeV.dispose();
    rightClick.dispose();
    super.dispose();
  }
  void rightClickActions(RightClickOptions options){
    switch (options) {
      case RightClickOptions.delete:
        threeV.control.detach();
        scene.remove(threeV.intersected!);
        threeV.intersected = null;
        break;
      case RightClickOptions.copy:
        threeV.copy = threeV.intersected;
        break;
      case RightClickOptions.paste:
        scene.add(threeV.intersected);
        break;
      default:
    }
    rightClick.closeMenu();
    setState(() {});
  }

  void callBacks({required LSICallbacks call}){
    switch (call) {
      case LSICallbacks.resetCamera:
        setState(() {
          resetNav = !resetNav;
          threeV.resetCamera();
        });
        break;
      case LSICallbacks.updatedNav:
        setState(() {
          resetNav = !resetNav;
        });
        break;
      case LSICallbacks.clear:
        setState(() {
          resetNav = !resetNav;
            for(final obj in scene.children){
              obj.dispose();
          }
        });
        break;
      case LSICallbacks.updateLevel:
        setState(() {

        });
        break;
      case LSICallbacks.quit:
        setState(() {
          resetNav = !resetNav;
        });
        widget.setProject(null);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    double safePadding = MediaQuery.of(context).padding.top;
    deviceHeight = MediaQuery.of(context).size.height-safePadding-25;
    return MaterialApp(
      theme: CSS.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(deviceWidth,50), 
          child:Navigation(
            height: 25,
            callback: callBacks,
            reset: resetNav,
            navData: screenNav.navigator
          ),
        ),
        body: Row(
          children: [
            Column(
              children: [
                Hud(threeV, setState),
                FileNavigation()
             ],
            ),
            Container(
              width: MediaQuery.of(context).size.width*.2,
              color: CSS.darkTheme.cardColor,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height/3,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CSS.darkTheme.canvasColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: threeV.mounted?SceneCollection(threeV,setState):Container(),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/3 - 40,
                    margin: const EdgeInsets.fromLTRB(5,0,5,5),
                    decoration: BoxDecoration(
                      color: CSS.darkTheme.canvasColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: threeV.mounted && threeV.intersected != null?IntersectedGui(setState,threeV.intersected):Container(),
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}