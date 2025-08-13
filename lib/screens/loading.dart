import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../src/styles/globals.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key, required this.onDone}):super(key: key);
  final void Function() onDone;
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin{
  double loaded = 0;
  late final SharedPreferences prefs;
  late AnimationController controller;

  @override
  void initState(){
    SharedPreferences.getInstance().then((value){
      prefs = value;
      themeType = CSS.themeFromString(prefs.getString('theme')?? 'dark');
      theme = CSS.changeTheme(themeType);
      setState(() {});
    });

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
    deviceWidth = MediaQuery.of(context).size.width;
    double safePadding = MediaQuery.of(context).padding.top;
    deviceHeight = MediaQuery.of(context).size.height-safePadding-25;
    return MaterialApp(
      theme: CSS.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
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
      ),
    );
  }
}