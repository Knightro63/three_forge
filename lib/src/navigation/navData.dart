import 'package:flutter/cupertino.dart';

class NavItems{
  NavItems({
    required this.name,
    this.icon,
    this.onTap,
    this.onChange,
    this.subItems,
    this.reset = false,
    this.input,
    this.quarterTurns = 0,
    this.show = true,
    this.useName = true,
    this.loading = false,
  });

  String name;
  IconData? icon;
  void Function(dynamic)? onTap;
  void Function(dynamic)? onChange;
  List<NavItems>? subItems;
  dynamic input;
  bool reset;
  int quarterTurns;
  bool show;
  bool useName;
  bool loading;
}

class NavTab{
  NavTab({
    required this.name,
    this.function
  });

  String name;
  void Function(int)? function;
}