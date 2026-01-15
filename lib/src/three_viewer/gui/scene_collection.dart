import 'package:flutter/material.dart';
import 'package:three_forge/src/history/commands.dart';
import 'package:three_forge/src/styles/globals.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart' as three;

class SceneCollection extends StatelessWidget{
  final void Function(void Function()) setState;
  final ThreeViewer threeV;

  SceneCollection(this.threeV,this.setState);

  final Map<String,dynamic> icons = {
    'Mesh': {
      'icon': Icons.polyline_outlined,
      'color': Colors.green
    },

    'Object3D': {
      'icon': Icons.workspaces_outlined,
      'color': Colors.red
    },

    'Group': {
      'icon': Icons.inventory,
      'color': Colors.white
    },

    'AnimationObject': {
      'icon': Icons.animation,
      'color': Colors.blue
    },
    'SkinnedMesh': {
      'icon': Icons.directions_walk_rounded,
      'color': Colors.green
    },
    'Bone': {
      'icon': Icons.bakery_dining_outlined,
      'color': Colors.blue
    },

    'AmbientLight': {
      'icon': Icons.light_mode,
      'color': Colors.orange
    },
    'DirectionalLight': {
      'icon': Icons.light,
      'color': Colors.orange
    },
    'SpotLight': {
      'icon': Icons.light,
      'color': Colors.orange
    },
    'PointLight': {
      'icon': Icons.view_in_ar_rounded,
      'color': Colors.orange
    },
    'HemisphereLight': {
      'icon': Icons.panorama_photosphere,
      'color': Colors.orange
    },
    'RectAreaLight': {
      'icon': Icons.rectangle_outlined,
      'color': Colors.orange
    },

    'PerspectiveCamera': {
      'icon': Icons.video_camera_back,
      'color': Colors.deepPurple
    },
    'OrtographicCamera': {
      'icon': Icons.video_camera_back,
      'color': Colors.deepPurple
    },
  };

  Icon getIcon(three.Object3D object){
    final Map<String,dynamic>? c = icons[object.runtimeType.toString()];

    if(c == null){
      return Icon(Icons.error,size: 15,color: Colors.red);
    }

    return  Icon(c['icon'] ,size: 15,color: c['color']);
  }

  Widget card(BuildContext context, three.Object3D child){
    return Theme(
      data: theme,
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
        height: 25,
        color: Theme.of(context).cardColor,
        child: SizedBox(
          width: 137,
          child: Text(
            child.name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ),
      )
    );
  }

  List<Widget> folderStructure(BuildContext context){
    List<Widget> widgets = [];
    int level = 0;
    void folderView(three.Object3D parent, int level){
      for(final child in parent.children){
        final bool contains = child.userData['openChildren'] ?? false;
        if(child.name != '') widgets.add(
          Draggable(
            data: child,
            feedback: card(context,child),
            child: DragTarget(
              builder: (context, candidateItems, rejectedItems) {
                return Container(
                  margin: EdgeInsets.only(left: level*10),
                  height: 20,
                  color: threeV.intersected.isNotEmpty && threeV.intersected.contains(child)?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        threeV.selectPart(child);
                        setState(() {});
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            (child.children.isNotEmpty && (child.children[0].name != '' || child.children.length > 1))?InkWell(
                              onTap: (){
                                setState(() {
                                  if(contains){
                                    child.userData['openChildren'] = false;
                                    setState(() {});
                                  }
                                  else{
                                    child.userData['openChildren'] = true;
                                    setState(() {});
                                  }
                                });
                              },
                              child: Icon(contains?Icons.arrow_drop_down_rounded:Icons.arrow_right_rounded,size: 20,)
                            ):SizedBox(width:20),
                            getIcon(child),
                            SizedBox(width: 2,),
                            Text(
                              child.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).primaryTextTheme.bodySmall,
                            )
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              threeV.execute(
                                SetValueCommand(threeV, child, 'visible', !child.visible)
                                  ..onRedoDone = (){
                                    child.userData['helper']?.visible = !child.visible;
                                    child.userData['skeleton']?.visible = !child.visible;
                                  }
                                  ..onUndoDone = (){
                                    child.userData['helper']?.visible = !child.visible;
                                    child.userData['skeleton']?.visible = !child.visible;
                                  }
                              );
                              child.visible = !child.visible;
                              child.userData['helper']?.visible = child.visible;
                              child.userData['skeleton']?.visible = child.visible;
                              threeV.control.detach();
                            });
                          },
                          child: Icon(child.visible == true?Icons.visibility:Icons.visibility_off,size: 15,),
                        )
                      ],
                    )
                  ),
                );
              },
              onAcceptWithDetails: (details) async{
                final selectedObject = details.data as three.Object3D?;
                bool allowed = true;
                if(child.userData['attachedObjects'] != null){
                  for(final k in child.userData['attachedObjects'].keys){
                    for(final l in child.userData['attachedObjects'][k]){
                      if(l == selectedObject){
                        allowed = false;
                        break;
                      }
                    }
                  }
                }

                if(selectedObject != null && allowed){
                  threeV.scene.remove(selectedObject);
                  final parent = selectedObject.parent;
                  three.Object3D? topParent = parent;

                  parent?.traverseAncestors((ancestor){
                    // If the ancestor's parent is the Scene, this ancestor is our target
                    if (ancestor is! three.Scene) {
                      topParent = ancestor;
                    }
                  });

                  topParent?.userData['attachedObjects'][parent?.uuid] = <three.Object3D>[];
                  parent?.remove(selectedObject);

                  child.add(selectedObject);
                  selectedObject.userData['scale'] = selectedObject.scale.clone();
                  selectedObject.scale.scale(1/child.scale.x);

                  if(child.userData['attachedObjects']?[child.uuid] == null){
                    child.userData['attachedObjects'] = <String,List<three.Object3D>>{};
                    child.userData['attachedObjects'][child.uuid] = <three.Object3D>[];
                  }
                  child.userData['attachedObjects'][child.uuid].add(selectedObject);
                  setState(() {});
                }
              },
            )
          )
        );

        if(contains){
          folderView(child, level+1);
        }
      }
      level++;
    }

    folderView(threeV.scene, level);
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidateItems, rejectedItems) {
        return ListView(
          children: <Widget>[
            InkWell(
              onTap: (){
                threeV.selectScene();
                setState((){});
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                height: 25,
                color: threeV.sceneSelected?Theme.of(context).secondaryHeaderColor:null,
                child: const Row(
                  children: [
                    Icon(Icons.inventory ,size: 15,),
                    Text('\tScene Collection'),
                  ],
                ),
              )
            )
          ]+folderStructure(context),
        );
      },
      onAcceptWithDetails: (details){
        final selectedObject = details.data as three.Object3D?;

        if(selectedObject != null && !threeV.scene.children.contains(selectedObject)){
          threeV.scene.remove(selectedObject);
          final parent = selectedObject.parent;
          three.Object3D? topParent = parent;

          parent?.traverseAncestors((ancestor){
            if (ancestor is! three.Scene) {
              topParent = ancestor;
            }
          });

          topParent?.userData['attachedObjects'][parent?.uuid] = <three.Object3D>[];
          parent?.remove(selectedObject);

          threeV.scene.add(selectedObject);
          if(selectedObject.userData['scale'] != null){
            selectedObject.scale.setFrom(selectedObject.userData['scale']);
          }
        }
      },
    );
  }
}