import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class SelectionHelper extends StatefulWidget {
  const SelectionHelper({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _SelectionHelperState createState() => _SelectionHelperState();
}

class _SelectionHelperState extends State<SelectionHelper> {
  @override
  Widget build(BuildContext context) {
    bool hv = widget.threeV.startPoint.y-widget.threeV.mousePosition.y >= 0;
    bool wv = widget.threeV.startPoint.x-widget.threeV.mousePosition.x >= 0;

    final top = widget.threeV.startPoint.y;
    final left = widget.threeV.startPoint.x;
    final width = widget.threeV.mousePosition.x;
    final height = widget.threeV.mousePosition.y;

    return !widget.threeV.selectionHelperEnabled?Container():Positioned(
      top: !hv?top:height,
      left: !wv?left:width,
      child: Container(
        width: wv?left-width:width-left,
        height: hv?top-height:height-top,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor.withAlpha(128),
          border: Border.all(
            width: 2,
            color: Theme.of(context).secondaryHeaderColor,
          )
        ),
      )
    );
  }
}