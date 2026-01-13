import 'dart:async';

import 'package:flutter/material.dart';
import 'package:three_forge/src/navigation/screen_navigator.dart';
import 'package:three_forge/src/three_viewer/file_navigation.dart';
import 'package:three_forge/src/three_viewer/hud.dart';
import 'package:three_forge/src/three_viewer/gui/intersected.dart';
import 'package:three_forge/src/three_viewer/scene_collection.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import '../src/navigation/right_click.dart';
import 'package:three_js/three_js.dart' as three;
import '../src/navigation/navigation.dart';
import '../src/styles/globals.dart';
import 'dart:io';

class UIScreen extends StatefulWidget {
  const UIScreen({Key? key, required this.currentProject, required this.setProject}):super(key: key);
  final Map<String,dynamic> currentProject;
  final void Function(Map<String,dynamic>?) setProject;

  @override
  _UIPageState createState() => _UIPageState();
}

class _UIPageState extends State<UIScreen> {
  late final ScreenNavigator screenNav = ScreenNavigator(threeV, setState, callBacks);
  late final ThreeViewer threeV;
  
  bool resetNav = false;

  late RightClick rightClick;
  late three.Scene scene = threeV.scene;
  late three.Group helper = threeV.helper;
  bool isPlaying = false;
  bool loading = false;
  bool didDispose = false;
  String consoleLog = '';
  Map<String,String> devices = {};

  String? selectedDevice;
  StreamSubscription? _stdoutSub;
  Process? process;

  @override
  void initState(){
    rightClick = RightClick(
      context: context,
      style: null,
      onTap: rightClickActions,
    );
    threeV = ThreeViewer(setState,rightClick,widget.currentProject['location']);
    getDevices();
    super.initState();
  }
  @override
  void dispose(){
    didDispose = true;
    threeV.dispose();
    rightClick.dispose();
    _stdoutSub?.cancel();
    process?.kill(ProcessSignal.sigint);
    super.dispose();
  }
  void rightClickActions(RightClickOptions options){
    switch (options) {
      case RightClickOptions.delete:
        threeV.control.detach();
        threeV.removeAll(threeV.intersected);
        threeV.intersected.clear();
        break;
      case RightClickOptions.copy:
        threeV.copy = threeV.intersected;
        break;
      case RightClickOptions.paste:
        threeV.copyAll(threeV.intersected);
        break;
      case RightClickOptions.reset_camera:
        threeV.resetCameraView();
        break;
      case RightClickOptions.game_view:
        threeV.setToMainCamera();
        break;
      default:
    }
    rightClick.closeMenu();
    setState(() {});
  }

  void callBacks({required LSICallbacks call}){
    switch (call) {
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

  Future<void> setupProcess(String deviceId) async{
    if(isPlaying){
      _stdoutSub?.cancel();
      process?.kill(ProcessSignal.sigint);
      isPlaying = false;
      loading = false;
      setState(() { });
      return;
    }

    isPlaying = true;
    loading = true;
    process = await Process.start(
      'flutter',
      ['run', '-d', deviceId],
      workingDirectory: widget.currentProject['location'],
      runInShell: true,  
      mode: ProcessStartMode.normal,
    );

    _stdoutSub = process?.stdout.listen(
      (data1) {
        convertShellData(String.fromCharCodes(data1));
      },
      onDone: (){
        process?.kill(ProcessSignal.sigint);
        process = null;
        isPlaying = false;
        if(!didDispose)setState(() {});
      }
    );
    setState(() { });
  }

  void convertShellData(String data1, [bool isGetDevices = false]){
    setState(() {
      consoleLog += '\n$data1';
    });
    if(!isGetDevices){
      final data = data1.trim().replaceAll(' ', '').toLowerCase();
      if(data.contains('flutterrunkeycommands')){
        loading = false;
        setState(() {});
      }
    }
    else{
      final combinedData = data1.trim().replaceAll(' ', '').toLowerCase();
      for(final data in combinedData.split('\n')){
        final splitDevice = data.split('•');
        String device = '';
        if(splitDevice.length > 1){
          device = splitDevice[1];
        }
        if(data.contains('macos(desktop)') && !devices.containsKey('macos')){
          devices['macos'] = 'macos';
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('windows(desktop)') && !devices.containsKey('windows')){
          devices['windows'] = 'windows';
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('linux(desktop)') && !devices.containsKey('linux')){
          devices['linux'] = 'linux';
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('chrome(web)') && !devices.containsKey('chrome')  && !devices.containsKey('WASM')){
          devices['chrome'] = 'chrome';
          devices['WASM'] = 'chrome --wasm';
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('(mobile)•emulator') && !devices.containsKey('emulator')){
          devices['emulator'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('linux(desktop)') && !devices.containsKey('android')){
          devices['android'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('ipad(wireless)(mobile)') && !devices.containsKey('ipad')){
          devices['ipad'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('ios•com.apple.coresimulator') && data.contains('ipad') && !devices.containsKey('ipad-sim')){
          devices['ipad-sim'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('iphone(wireless)(mobile)') && !devices.containsKey('iphone')){
          devices['iphone'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('ios•com.apple.coresimulator') && data.contains('iphone') && !devices.containsKey('iphone-sim')){
          devices['iphone-sim'] = device;
          callBacks(call: LSICallbacks.updatedNav);
        }
        else if(data.contains('lostconnectiontodevice.')){
          isPlaying = false;
          setState(() {});
        }
      }
    }
  }

  Future<void> getDevices() async{
    final result = await Process.run(
      'flutter',
      ['devices'],
    );
    final output = result.stdout.toString();
    convertShellData(output,true);
    //await shell.run('flutter devices');
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    double safePadding = MediaQuery.of(context).padding.top;
    deviceHeight = MediaQuery.of(context).size.height-safePadding-25;
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(deviceWidth,50), 
          child: Navigation(
            width: 25,
            height: 25,
            margin: EdgeInsets.only(left: 15, right: 15),
            callback: callBacks,
            reset: resetNav,
            navData: screenNav.navigator,
            centerNavData: [
              NavItems(
                name: 'Device${selectedDevice == null?'':'($selectedDevice)'}',
                subItems: [
                  NavItems(
                    show: devices.containsKey('macos'),
                    name: 'macos',
                    icon: Icons.apple_outlined,
                    onTap: (_){
                      selectedDevice = 'macos';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('windows'),
                    name: 'windows',
                    icon: Icons.window,
                    onTap: (_){
                      selectedDevice = 'windows';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('linux'),
                    name: 'linux',
                    icon: Icons.smart_toy_rounded,
                    onTap: (_){
                      selectedDevice = 'linux';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('chrome'),
                    name: 'chrome',
                    icon: Icons.web,
                    onTap: (_){
                      selectedDevice = 'chrome';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('WASM'),
                    name: 'WASM',
                    icon: Icons.web,
                    onTap: (_){
                      selectedDevice = 'WASM';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('emulator'),
                    name: 'emulator',
                    icon: Icons.adb,
                    onTap: (_){
                      selectedDevice = 'emulator';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('android'),
                    name: 'android',
                    icon: Icons.adb,
                    onTap: (_){
                      selectedDevice = 'android';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('ipad'),
                    name: 'ipad',
                    icon: Icons.apple_outlined,
                    onTap: (_){
                      selectedDevice = 'ipad';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('ipad-sim'),
                    name: 'ipad-sim',
                    icon: Icons.apple_outlined,
                    onTap: (_){
                      selectedDevice = 'ipad-sim';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('iphone'),
                    name: 'iphone',
                    icon: Icons.apple_outlined,
                    onTap: (_){
                      selectedDevice = 'iphone';
                      setState(() {});
                    }
                  ),
                  NavItems(
                    show: devices.containsKey('iphone-sim'),
                    name: 'iphone-sim',
                    icon: Icons.apple_outlined,
                    onTap: (_){
                      selectedDevice = 'iphone-sim';
                      setState(() {});
                    }
                  ),
                ],
                onTap: (_){
                  
                }
              ),
              NavItems(
                useName: false,
                icon: !isPlaying?Icons.play_arrow_rounded:Icons.stop_rounded,
                loading: loading,
                name: 'Play',
                onTap: (_){
                  if(selectedDevice != null){
                    setupProcess(devices[selectedDevice]!);
                  }
                }
              ),
              NavItems(
                show: isPlaying && !loading,
                useName: false,
                icon: Icons.refresh,
                name: 'Refresh',
                onTap: (_){
                  process?.stdin.write('r');
                }
              ),
              NavItems(
                show: isPlaying && !loading,
                useName: false,
                icon: Icons.arrow_back,
                name: 'Reload',
                onTap: (_){
                  process?.stdin.write('R');
                }
              ),
            ],
          ),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hud(threeV, setState),
                FileNavigation(files: widget.currentProject,consoleLog: consoleLog, history: threeV.history,)
             ],
            ),
            Container(
              width: MediaQuery.of(context).size.width*.2,
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height/3,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: threeV.mounted?SceneCollection(threeV,setState):Container(),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/3 - 40,
                    margin: const EdgeInsets.fromLTRB(5,0,5,5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: threeV.mounted?IntersectedGui(threeV: threeV):Container(),
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