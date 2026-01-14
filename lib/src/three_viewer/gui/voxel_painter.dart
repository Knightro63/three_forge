import 'package:flutter/material.dart';
import 'package:three_forge/src/modifers/create_models.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/src/voxel_painter.dart';

class VoxelPainterGui extends StatefulWidget {
  const VoxelPainterGui({Key? key, required this.voxelPainter}):super(key: key);
  final VoxelPainter voxelPainter;

  @override
  _VoxelPainterGuiState createState() => _VoxelPainterGuiState();
}

class _VoxelPainterGuiState extends State<VoxelPainterGui> {
  late VoxelPainter voxelPainter;
  final TextEditingController objectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    voxelPainter = widget.voxelPainter;
  }
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(voxelPainter != widget.voxelPainter){
      voxelPainter = widget.voxelPainter;
    }
    objectController.text = voxelPainter.helper?.name ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Wrap(
              children: [
                const Text('Object'),
                EnterTextFormField(
                  readOnly: true,
                  height: 20,
                  label: voxelPainter.helper?.name ?? '',
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: objectController,
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            final object = await CreateModels.create(details.data as String);
            if(object != null) voxelPainter.setObject(object);
          },
        ),
        // DragTarget(
        //   builder: (context, candidateItems, rejectedItems) {
        //     return Wrap(
        //       children: [
        //         const Text('Helper'),
        //         EnterTextFormField(
        //           readOnly: true,
        //           height: 20,
        //           label: voxelPainter.helper?.name ?? '',
        //           maxLines: 1,
        //           textStyle: Theme.of(context).primaryTextTheme.bodySmall,
        //           color: Theme.of(context).canvasColor,
        //           controller: helperController,
        //         )
        //       ],
        //     );
        //   },
        //   onAcceptWithDetails: (details) async{
        //     final object = await CreateModels.create(details.data as String);
        //     if(object != null) voxelPainter.setHelper(object);
        //   },
        // ),
      ],
    );
  }
}