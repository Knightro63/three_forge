
String plugin = '''
export 'plugin_platform.dart'
    if (dart.library.io) 'plugin_platform.dart'
    if (dart.library.js) 'plugin_web.dart';
''';

String pluginWeb = '''
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void setPathUrlStrategy() {
  setUrlStrategy(PathUrlStrategy());//
}
''';

String pluginPlatform = 'void setPathUrlStrategy() {}';

String loadingThreeForge = '''
import 'package:flutter/material.dart';

class LoadingThreeForge extends StatefulWidget {
  const LoadingThreeForge({Key? key, required this.onDone}):super(key: key);
  final void Function() onDone;
  @override
  _LoadingThreeForgeState createState() => _LoadingThreeForgeState();
}

class _LoadingThreeForgeState extends State<LoadingThreeForge> with TickerProviderStateMixin{
  double loaded = 0;
  late AnimationController controller;

  @override
  void initState(){
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
    ..addListener(() {
      loaded += 0.3;
      if(loaded >= 100){
        widget.onDone();
      }
      setState(() {});
    })
    ..repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[900],
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/three_forge_icon_text.png',
              width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.width/2,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width/2, 
              child: LinearProgressIndicator(
                value: loaded/100,
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.circular(2),
              )
            )
          ],
        ),
      )
    );
  }
}
''';

String mainFile = '''
import 'package:flutter/material.dart';
import 'src/plugins/plugin.dart';
import 'screens/loading_three_forge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  bool loading = true;

  void doneLoading(){
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: theme,
      home: Stack(
        children:[
          if(loading)LoadingThreeForge(onDone: doneLoading),
          const GameScreen()
        ]
      ),
    );
  }
}
''';

