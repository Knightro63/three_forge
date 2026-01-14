import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class PaintHelper extends StatefulWidget {
  const PaintHelper({super.key, required this.threeV});
  final ThreeViewer threeV;

  @override
  createState() => _SelectionHelperState();
}

class _SelectionHelperState extends State<PaintHelper> {
  @override
  Widget build(BuildContext context) {
    final brushSize = !widget.threeV.isVoxelPainter?0.0:(widget.threeV.intersected[0] as VoxelPainter).brushSize;
    final top = widget.threeV.mousePosition.y-brushSize/2;
    final left = widget.threeV.mousePosition.x-brushSize/2;

    return !widget.threeV.isVoxelPainter?Container():Positioned(
      top: top,
      left: left,
      child: IgnorePointer(
        ignoring: true, // Set to true to let events pass through
        child:Container(
          width: brushSize,
          height: brushSize,
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor.withAlpha(128),
            borderRadius: BorderRadius.circular(brushSize/2),
            border: Border.all(
              width: 2,
              color: Theme.of(context).secondaryHeaderColor,
            )
          ),
        )
      )
    );
  }
}