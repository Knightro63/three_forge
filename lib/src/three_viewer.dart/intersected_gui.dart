import 'package:css/css.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/src/styles/savedWidgets.dart';
import 'package:three_forge/src/three_viewer.dart/decimal_index_formatter.dart';
import 'package:three_js/three_js.dart';

class IntersectedGui extends StatelessWidget{
  final void Function(void Function()) setState;
  final Object3D? intersected;
  
  IntersectedGui(this.setState,this.intersected);

  final List<bool> expands = [false,false,false,false];
  final List<TextEditingController> transfromControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  void dispose(){
    expands.clear();
    transfromControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(5,5,5,5),
          decoration: BoxDecoration(
            color: CSS.darkTheme.cardColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    expands[0] = !expands[0];
                  });
                },
                child: Row(
                  children: [
                    Icon(!expands[0]?Icons.expand_more:Icons.expand_less, size: 15,),
                    const Text('\tTransform'),
                  ],
                )
              ),
              if(expands[0]) Padding(
                padding: const EdgeInsets.fromLTRB(25,10,5,5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location'),
                    const SizedBox(height: 5,),
                    Row(
                      children: [
                        const Text('X'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.position.x.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.position.x = double.parse(val);
                          },
                          controller: transfromControllers[0],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Y'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.position.y.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.position.y = double.parse(val);
                          },
                          controller: transfromControllers[1],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Z'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.position.z.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.position.z = double.parse(val);
                          },
                          controller: transfromControllers[2],
                        )
                      ],
                    ),

                    const SizedBox(height: 10,),
                    const Text('Rotate'),
                    const SizedBox(height: 5,),
                    Row(
                      children: [
                        const Text('X'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.rotation.x.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.rotation.x = double.parse(val);
                          },
                          controller: transfromControllers[3],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Y'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.rotation.y.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.rotation.y = double.parse(val);
                          },
                          controller: transfromControllers[4],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Z'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.rotation.z.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.rotation.z = double.parse(val);
                          },
                          controller: transfromControllers[5],
                        )
                      ],
                    ),

                    const SizedBox(height: 10,),
                    const Text('Scale'),
                    const SizedBox(height: 5,),
                    Row(
                      children: [
                        const Text('X'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.scale.x.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.scale.x = double.parse(val);
                          },
                          controller: transfromControllers[6],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Y'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.scale.y.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.scale.y = double.parse(val);
                          },
                          controller: transfromControllers[7],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Z'),
                        EnterTextFormField(
                          inputFormatters: [DecimalTextInputFormatter()],
                          label: intersected!.scale.z.toString(),
                          width: 80,
                          height: 20,
                          maxLines: 1,
                          textStyle: Theme.of(context).primaryTextTheme.bodySmall,
                          color: Theme.of(context).canvasColor,
                          onChanged: (val){
                            intersected!.scale.z = double.parse(val);
                          },
                          controller: transfromControllers[8],
                        )
                      ],
                    )
                  ],
                )
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(5,5,5,5),
          decoration: BoxDecoration(
            color: CSS.darkTheme.cardColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    expands[1] = !expands[1];
                  });
                },
                child: Row(
                  children: [
                    Icon(!expands[1]?Icons.expand_more:Icons.expand_less, size: 15,),
                    const Text('\tMaterial'),
                  ],
                )
              ),
              if(expands[1]) Padding(
                padding: const EdgeInsets.fromLTRB(25,10,5,5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  ]
                )
              )
            ]
          )
        ),

        // if(animationClips[intersected?.name] != null) Container(
        //   margin: const EdgeInsets.fromLTRB(5,5,5,5),
        //   decoration: BoxDecoration(
        //     color: CSS.darkTheme.cardColor,
        //     borderRadius: BorderRadius.circular(5)
        //   ),
        //   child: Column(
        //     children: [
        //       InkWell(
        //         onTap: (){
        //           setState(() {
        //             expands[3] = !expands[3];
        //           });
        //         },
        //         child: Row(
        //           children: [
        //             Icon(!expands[3]?Icons.expand_more:Icons.expand_less, size: 15,),
        //             const Text('\t Animation'),
        //           ],
        //         )
        //       ),
        //       if(expands[3]) Padding(
        //         padding: const EdgeInsets.fromLTRB(25,10,5,5),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.start,
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: getAnimations()
        //         )
        //       )
        //     ]
        //   )
        // ),
      ],
    );
  }
}