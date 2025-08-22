import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_forge/src/styles/lsi_functions.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class PhysicsGui extends StatefulWidget {
  const PhysicsGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _ModiferGuiState createState() => _ModiferGuiState();
}

class _ModiferGuiState extends State<PhysicsGui> {
  late final ThreeViewer threeV;
    List<DropdownMenuItem<String>> bodySelector = LSIFunctions.setDropDownItems(['None','Dynamic', 'Static','Kinematic','Ghost']);

  
  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
  }
  @override
  void dispose(){
    physicsControllers.clear();
    super.dispose();
  }

  void controllersReset(){
    for(final controllers in physicsControllers){
      controllers.clear();
    }
  }

  final List<TextEditingController> physicsControllers = [
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

  Widget createShapes(List<Map<String,dynamic>> shapes){
    List<Widget>  widgets = [];

    for(final shape in shapes){
      // widgets.add(

      // );
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    controllersReset();
    threeV.intersected[0].userData['physics'] ??= {
      'allowSleep': true,
      'type': 'Static',
      'name': '',
      'isSleeping': false,
      'adjustPosition': true,
      'mass': 0.0,
      'isTrigger': false,
      'linearVelocity': [0,0,0],
      'angularVelocity': [0,0,0],
      'shapes': {}
    };

    Map<String,dynamic> object = threeV.intersected[0].userData['physics'];
    const double d = 60;
    double d2 = 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(child: const Text('Name:')),
            EnterTextFormField(
              label: object['name'].toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['name'] = val;
              },
              controller: physicsControllers[7],
            )
          ],
        ),
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
              items: bodySelector,
              value: object['type'],
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                object['type'] = value;
              },
            ),
          ),
        ),
        InkWell(
          onTap: (){
            object['allowSleep'] = !object['allowSleep'];
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Allow Sleep\t\t\t'),
              SavedWidgets.checkBox(object['allowSleep'] ?? true)
            ]
          )
        ),
        InkWell(
          onTap: (){
            object['isSleeping'] = !object['isSleeping'];
            setState(() {});
          },
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Is Sleeping\t\t\t'),
              SavedWidgets.checkBox(object['isSleeping'])
            ]
          )
        ),
        InkWell(
          onTap: (){
            object['adjustPosition'] = !object['adjustPosition'];
            setState(() {});
          },
          child: Row(
            children: [
              Text('Adjust Position\t\t\t'),
              SavedWidgets.checkBox(object['adjustPosition'])
            ]
          )
        ),
        InkWell(
          onTap: (){
            object['isTrigger'] = !object['isTrigger'];
            setState(() {});
          },
          child: Row(
            children: [
              Text('Is Trigger\t\t\t'),
              SavedWidgets.checkBox(object['isTrigger'])
            ]
          )
        ),
        if(object['isTrigger'] == true)DragTarget(
          builder: (context, candidateItems, rejectedItems) {
            return Row(
              children: [
                const Text('Script:'),
                EnterTextFormField(
                  readOnly: true,
                  width: 76,
                  height: 20,
                  maxLines: 1,
                  textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                  color: Theme.of(context).canvasColor,
                  controller: physicsControllers[8],
                )
              ],
            );
          },
          onAcceptWithDetails: (details) async{
            object['scriptPath'] = details;
          },
        ),
        Row(
          children: [
            SizedBox(width:d, child: const Text('Mass')),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['mass'].toString(),
              width: d2,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                final double? hex = double.tryParse(val);
                if(hex != null){
                  object['mass'] = hex;
                }
              },
              controller: physicsControllers[6],
            )
          ],
        ),
        const SizedBox(height: 10,),
        const Text('Linear Velocity'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['linearVelocity'][0].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['linearVelocity'][0] = double.parse(val);
              },
              controller: physicsControllers[0],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['linearVelocity'][1].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['linearVelocity'][1] = double.parse(val);
              },
              controller: physicsControllers[1],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['linearVelocity'][2].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['linearVelocity'][2] = double.parse(val);
              },
              controller: physicsControllers[2],
            )
          ],
        ),

        const SizedBox(height: 10,),
        const Text('Angular Velocity'),
        const SizedBox(height: 5,),
        Row(
          children: [
            const Text('X'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['angularVelocity'][0].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['angularVelocity'][0] = double.parse(val);
              },
              controller: physicsControllers[3],
            )
          ],
        ),
        Row(
          children: [
            const Text('Y'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['angularVelocity'][1].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['angularVelocity'][1] = double.parse(val);
              },
              controller: physicsControllers[4],
            )
          ],
        ),
        Row(
          children: [
            const Text('Z'),
            EnterTextFormField(
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              label: object['angularVelocity'][2].toString(),
              width: 80,
              height: 20,
              maxLines: 1,
              textStyle: Theme.of(context).primaryTextTheme.bodySmall,
              color: Theme.of(context).canvasColor,
              onChanged: (val){
                object['angularVelocity'][2] = double.parse(val);
              },
              controller: physicsControllers[5],
            )
          ],
        ),
      ],
    );
  }
}