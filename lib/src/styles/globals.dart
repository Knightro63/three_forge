library my_prj.globals;

import 'package:css/css.dart';
import 'package:flutter/material.dart';

enum LSICallbacks{clear,updatedNav,updateScene,updateLevel,quit}

ThemeData theme = CSS.darkTheme;
LsiThemes themeType = LsiThemes.dark;
double deviceWidth = 0;
double deviceHeight = 0;