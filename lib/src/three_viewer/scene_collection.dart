import 'package:flutter/material.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class SceneCollection extends StatelessWidget{
  final void Function(void Function()) setState;
  final ThreeViewer threeV;
  
  SceneCollection(this.threeV,this.setState);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      InkWell(
        onTap: (){
          setState((){
            threeV.sceneSelected = !threeV.sceneSelected;
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
      widgets.add(
        InkWell(
          onTap: (){
            threeV.boxSelect(false);
            threeV.intersected.clear();
            threeV.intersected.add(child);
            threeV.boxSelect(true);
            setState(() {
              
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
            height: 25,
            color: threeV.intersected.isNotEmpty && threeV.intersected.contains(child)?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 137,
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

    return ListView(
      children: widgets,
    );
  }
}