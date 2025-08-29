import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class SceneCollection extends StatelessWidget{
  final void Function(void Function()) setState;
  final ThreeViewer threeV;
  
  SceneCollection(this.threeV,this.setState);

  Widget subModel(BuildContext context, child, bool isSub, bool isMulti){
    return Padding(
      padding: isSub?EdgeInsetsGeometry.only(left: 20):EdgeInsetsGeometry.only(left: 0),
      child: InkWell(
        onTap: (){
          threeV.selectPart(child);
          setState(() {
            
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          padding: EdgeInsets.fromLTRB((isMulti?0:15), 0, 5, 0),
          height: 25,
          color: threeV.intersected.isNotEmpty && threeV.intersected.contains(child)?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(isMulti)InkWell(
                onTap: (){
                  child.userData['opened'] = !(child.userData['opened'] ?? false);
                  setState((){});
                },
                child: Icon(Icons.arrow_drop_down_rounded, size: 15),
              ),
              SizedBox(
                width: 137-(isSub?20:0),
                child: Text(
                  child.name,
                  overflow: TextOverflow.ellipsis,
                )
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    child.visible = !child.visible;
                    if(child.userData['helper'] != null)child.userData['helper'].visible = child.visible;
                  });
                },
                child: Icon(child.visible?Icons.visibility:Icons.visibility_off,size: 15,),
              )
            ],
          ),
        )
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      InkWell(
        onTap: (){
          threeV.selectScene();
          setState((){
            
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          height: 25,
          color: threeV.sceneSelected?Theme.of(context).secondaryHeaderColor:null,
          child: const Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.inventory ,size: 15,),
              Text('\tScene Collection'),
            ],
          ),
        )
      )
    ];

    for(final obj in threeV.scene.children){
      final child = obj;
      final int? len = (child.userData['attachedObjects'] as Map?)?.length;
      widgets.add(subModel(context, child, false, len != null));

      if(child.userData['opened'] == true) (child.userData['attachedObjects'] as Map?)?.forEach((key,list){
        for(int i = 0; i < list.length; i++){
          widgets.add(subModel(context, list[i], true, false));
        }
      });
    }

    return ListView(
      children: widgets,
    );
  }
}