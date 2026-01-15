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
              bone.name.replaceAll('mixamorig', ''), 
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
              bone.name.replaceAll('mixamorig', ''),
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

  Widget childList(three.Object3D? bone){
    if(bone == null) return Container(); 
    List<Widget> widgets = [];
    List<String> names = [];

    Widget childBone(String name, bool useWidth){
      return Container(
        margin: EdgeInsets.all(5),
        height: 25,
        width: !useWidth?null:MediaQuery.of(context).size.width*0.2-85,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).canvasColor
        ),
        child: Text(
          name.replaceAll('mixamorig', ''),
          style: Theme.of(context).primaryTextTheme.bodySmall,
        )
      );
    }

    for(final child in bone.children){
      if(!names.contains(child.name)){
        names.add(child.name);
        widgets.add(
          (threeV.intersected[0].userData['attachedObjects'] as Map<String,dynamic>?)?[bone.uuid]?.contains(child) == true?Row(
            children: [
              childBone(child.name,true),
              InkWell(
                onTap: (){
                  (threeV.intersected[0].userData['attachedObjects']?[bone.uuid] as List).remove(child);
                  bone.remove(child);
                  threeV.scene.add(child);
                  selectedObject?.userData['scale'] = selectedObject?.scale.clone();
                  child.scale = child.userData['scale'];
                  setState(() {});
                },
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(Icons.delete,size: 15,),
                ),
              )
            ],
          ):childBone(child.name,false)
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
        childList(selectedBone),
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
              items: objectSelector,
              value: selectedObject,
              isDense: true,
              focusColor: Theme.of(context).secondaryHeaderColor,
              style: Theme.of(context).primaryTextTheme.bodySmall,
              onChanged:(value){
                selectedObject = value;
                if(selectedObject != !selectedBone.children.contains(selectedObject)){
                  threeV.scene.remove(selectedObject!);
                  selectedBone.add(selectedObject);
                  selectedObject?.userData['scale'] = selectedObject?.scale.clone();
                  selectedObject?.scale.scale(1/threeV.intersected[0].scale.x);

                  if(threeV.intersected[0].userData['attachedObjects']?[selectedBone.uuid] == null){
                    threeV.intersected[0].userData['attachedObjects'] = <String,List<three.Object3D?>>{};
                    threeV.intersected[0].userData['attachedObjects'][selectedBone.uuid] = <three.Object3D?>[];
                  }
                  threeV.intersected[0].userData['attachedObjects'][selectedBone.uuid].add(selectedObject);
                  setState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}