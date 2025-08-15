import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class CameraGui extends StatefulWidget {
  const CameraGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _LightGuiState createState() => _LightGuiState();
}

class _LightGuiState extends State<CameraGui> {
  late final ThreeViewer threeV;
  List<DropdownMenuItem<String>> cameraSelector = LSIFunctions.setDropDownItems(['Orthographic', 'Perspective']);
  late String cameraValue;

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
    cameraValue = threeV.camera is three.OrthographicCamera?'Orthographic':'Perspective';
  }
  @override
  void dispose(){
    super.dispose();
    cameraControllers.clear();
  }

  void controllersReset(){
    for(final controllers in cameraControllers){
      controllers.clear();
    }
  }

  final List<TextEditingController> cameraControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void updateCameraHelper(){
    (threeV.camera.userData['helper'] as three.Object3D).copy(CameraHelper(threeV.camera));
  }
  void updateCamera(){
    final temp = threeV.camera.userData['helper'];
    if(cameraValue == 'Perspective'){
      threeV.camera = threeV.cameraPersp;
    }
    else{
      threeV.camera = threeV.cameraOrtho;
    }
    threeV.camera.userData['helper'] = temp;
    updateCameraHelper();
  }
  @override
  Widget build(BuildContext context) {
    controllersReset();
    const double d = 60;
    double d2 = 60;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.center,
          height:20,
          padding: const EdgeInsets.only(left:10),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton <dynamic>(
              dropdownColor: Theme.of(context).canvasColor,
              isExpanded: true,
              items: cameraSelector,
              value: cameraValue,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                cameraValue = value;
                updateCamera();
              },
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Near')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.near.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.near = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[0],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Far')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.far.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.far = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[1],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Zoom')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.zoom.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.zoom = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[2],
            )
          ],
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Aspect')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.aspect.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.aspect = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[3],
            )
          ],
        ),
        if(cameraValue == 'Perspective')Row(
          children: [
            SizedBox(width:d, child: const Text('FOV')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.fov.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.fov = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[5],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: const Text('Left')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.left.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.left = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[6],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: const Text('Top')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.top.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.top = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[7],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: Text('Penubra')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.right.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.right = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[8],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: Text('Penubra')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: threeV.camera.bottom.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  threeV.camera.bottom = hex;
                  updateCameraHelper();
                }
              },
              controller: cameraControllers[9],
            )
          ],
        )
      ],
    );
  }
}