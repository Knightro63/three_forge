import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';

class CameraGui extends StatefulWidget {
  const CameraGui({Key? key, required this.camera, this.threeV}):super(key: key);
  final three.Camera camera;
  final ThreeViewer? threeV;

  @override
  _LightGuiState createState() => _LightGuiState();
}

class _LightGuiState extends State<CameraGui> {
  late three.Camera camera;
  List<DropdownMenuItem<String>> cameraSelector = LSIFunctions.setDropDownItems(['Orthographic', 'Perspective']);
  late String cameraValue;

  @override
  void initState() {
    super.initState();
    camera = widget.camera;
    cameraValue = widget.camera.runtimeType.toString() == 'PerspectiveCamera'?'Perspective':'Orthographic';
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

  void updateMainCamera(String cameraValue){
    if(camera.userData['mainCamera'] == true){
      widget.threeV!.changeCamera(cameraValue);
    }
    else{}
    setState(() {});
  }

  void updateCameraHelper(three.Camera camera){
    (camera.userData['helper'] as CameraHelper?)?.copy(CameraHelper(camera));
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
        if(camera.userData['mainCamera'] == true)Container(
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
                updateMainCamera(cameraValue == 'Perspective'?'PerspectiveCamera':'OrthographicCamera');
                updateCameraHelper(camera);
                setState(() {});
              },
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Near')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: camera.near.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.near = hex;
                  updateCameraHelper(camera);
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
              label: camera.far.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.far = hex;
                  updateCameraHelper(camera);
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
              label: camera.zoom.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.zoom = hex;
                  updateCameraHelper(camera);
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
              label: camera.aspect.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.aspect = hex;
                  updateCameraHelper(camera);
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
              label: camera.fov.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.fov = hex;
                  updateCameraHelper(camera);
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
              label: camera.left.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.left = hex;
                  updateCameraHelper(camera);
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
              label: camera.top.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.top = hex;
                  updateCameraHelper(camera);
                }
              },
              controller: cameraControllers[7],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: Text('right')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: camera.right.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.right = hex;
                  updateCameraHelper(camera);
                }
              },
              controller: cameraControllers[8],
            )
          ],
        ),
        if(cameraValue == 'Orthographic')Row(
          children: [
            SizedBox(width:d, child: Text('bottom')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: camera.bottom.toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  camera.bottom = hex;
                  updateCameraHelper(camera);
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