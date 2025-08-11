library my_prj.globals;

import 'package:css/css.dart';
import 'package:flutter/material.dart';

enum LSICallbacks{clear,updatedNav,updateScene,updateLevel,resetCamera,quit}

ThemeData themeDark = CSS.darkTheme;
double deviceWidth = 0;
double deviceHeight = 0;