import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js/three_js.dart' as three;

class SkeletonGui extends StatefulWidget {
  const SkeletonGui({Key? key, required this.threeV}):super(key: key);
  final ThreeViewer threeV;

  @override
  _SkeletonGuiState createState() => _SkeletonGuiState();
}

class _SkeletonGuiState extends State<SkeletonGui> {
  late final ThreeViewer threeV;
  final TextEditingController controller = TextEditingController();
  late final SkeletonHelper skeleton;
  List<DropdownMenuItem<three.Bone>> boneSelector = [];
  List<DropdownMenuItem<three.Object3D?>> objectSelector = [];
  late three.Bone selectedBone;
  three.Object3D? selectedObject;

  @override
  void initState() {
    super.initState();
    threeV = widget.threeV;
    skeleton = threeV.intersected[0].userData['skeleton'];
    List<String> names = [];
    for(final bone in skeleton.bones){
      if(!names.contains(bone.name)){
        names.add(bone.name);
        boneSelector.add(DropdownMenuItem(
            value: bone,
            child: Text(
              bone.name, 
              overflow: TextOverflow.ellipsis,
            )
        ));
      }
    }
    selectedBone = skeleton.bones.first;

    List<String> objectNames = [];
    objectSelector.add(
      DropdownMenuItem(
        value: null,
        child: Text(
          'None', 
          overflow: TextOverflow.ellipsis,
        )
      )
    );

    for(final object in threeV.scene.children){
      if(!objectNames.contains(object.name)){
        objectNames.add(object.name);
        objectSelector.add(DropdownMenuItem(
            value: object,
            child: Text(
              object.name, 
              overflow: TextOverflow.ellipsis,
            )
        ));
      }
    }
  }
  @override
  void dispose(){
    super.dispose();
  }

  Widget bones(SkeletonHelper skeleton){
    List<Widget> widgets = [];
    List<String> names = [];

    for(final bone in skeleton.bones){
      if(!names.contains(bone.name)){
        names.add(bone.name);
        widgets.add(
          Container(
            margin: EdgeInsets.all(5),
            height: 25,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).canvasColor
            ),
            child: Text(
              bone.name,
              style: Theme.of(context).primaryTextTheme.bodySmall,
            )
          )
        );
      }
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bones: '),
        SizedBox(height: 5,),
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
              items: boneSelector,
              value: selectedBone,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                selectedBone = value;
                setState(() {
                  
                });
              },
            ),
          ),
        ),
        SizedBox(height: 20,),
        const Text('Attached Object: '),
        SizedBox(height: 5,),
        if(selectedBone.children.isEmpty)Container(
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
              items: objectSelector,
              value: selectedObject,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                selectedObject = value;
                print(selectedObject);
                if(selectedObject != null){
                  selectedBone.add(selectedObject);
                }
                else{
                  selectedBone.clear();
                }
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}