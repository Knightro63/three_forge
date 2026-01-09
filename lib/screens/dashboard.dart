import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:css/css.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:three_forge/screens/thumbnail_creator.dart';
import 'package:three_forge/src/navigation/navigation.dart';
import 'package:three_forge/src/styles/config.dart';
import 'package:three_forge/src/styles/globals.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key, required this.setProject, required this.onDone, required this.config});
  final void Function(Map<String,dynamic>?) setProject;
  final void Function() onDone;
  final Config config;
  @override
  _CodePage createState() => _CodePage();
}

class _CodePage extends State<Dashboard>{
  final TextEditingController serch = TextEditingController();
  final TextEditingController newProjectController = TextEditingController();
  String? projectName;
  String? errorMessage;
  final TextEditingController newProjectLocationController = TextEditingController();
  List<FileSystemEntity> file = [];

  String modifier = '';
  bool direction = false;

  late final Config config;
  dynamic currentProjects = [];

  @override
  void initState() {
    config = widget.config;
    currentProjects.clear(); 
    currentProjects.addAll(config.getAllProjects());
    super.initState();
  }
  @override
  void dispose() {
    file.clear();
    serch.dispose();
    newProjectController.dispose();
    newProjectLocationController.dispose();
    super.dispose();
  }

  Future<String?> getPath() async{
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Loaction');
    if(path!=null) file = Directory(path).listSync();
    return path;
  }

  Future<void> importProject() async{
    final path = await getPath();
    String? jsonFile;
    if(path != null){
      for(final f in file){
        if(f.path.contains('gameInfo.json')){
          jsonFile = await File(f.path).readAsString();
          break;
        }
      }

      if(jsonFile != null){
        final temp = json.decode(jsonFile);
        await addProject(temp['title'],path, temp['name'], temp['dateCreated']);
      }
    }
  }

  Future<void> addProject(String title, String location, String name, String dateCreated) async{
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final newProject = {
      'title': title,
      'name': name,
      'dateCreated': dateCreated,
      'location': '$location',
      'dateModified': DateTime.now().toString(),
      'version': '0.0.1',//packageInfo.version
    };
    currentProjects.add(newProject);

    await config.setProject(newProject);
    setState(() {});
  }
  Future<void> removeProject(Map<String,dynamic> project) async{
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentProjects.remove(project);
    await config.removeProject(project);
    setState(() {});
  }

  void createNewProjectModal(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return editNewProjectModal();
      }
    ).then((value){
      modalReset(null);
      errorMessage = null;
    });
  }
  
  Future<void> createNewProject() async{
    final fileLocation = newProjectLocationController.text;
    Process process = await Process.start(
      'flutter',
      ['create', projectName!],
      workingDirectory: fileLocation,
      runInShell: true,  
      mode: ProcessStartMode.normal,
    );
    await process.exitCode;

    await File('$fileLocation/$projectName/gameInfo.json').writeAsString(json.encode({
        'title': newProjectController.text,
        'name': projectName,
        'dateCreated': DateTime.now().toString(),
      })
    );

    bool exists = await Directory('$fileLocation/$projectName/assets').exists();
    if(!exists) await Directory('$fileLocation/$projectName/assets').create();

    await File('$fileLocation/$projectName/assets/gameScene.json').writeAsString(json.encode({
        'title': newProjectController.text,
        'name': projectName,
        'dateCreated': DateTime.now().toString(),
      })
    );

    exists = await Directory('$fileLocation/$projectName/assets/thumbnails').exists();
    if(!exists) await Directory('$fileLocation/$projectName/assets/thumbnails').create();

    exists = await Directory('$fileLocation/$projectName/assets/models').exists();
    if(!exists) await Directory('$fileLocation/$projectName/assets/models').create();

    await addProject(newProjectController.text, '$fileLocation/$projectName', projectName!, DateTime.now().toString());
    setState(() {});
  }

  void modalReset(BuildContext? buildContext){
    setState(() {

    });
    if(buildContext != null){
      Navigator.pop(buildContext);
    }
  }

  Widget createTumbnailModal() {
    return StatefulBuilder(builder: (context1, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 320,
          width: 260,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ]
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return ThumbnailCreator();
          })
        )
      );
    });
  }

  Widget editNewProjectModal() {
    bool creating = false;
    newProjectController.text = 'My Project';
    projectName = 'my_project';
    newProjectLocationController.text = Directory.current.path;
    errorMessage = null;

    return StatefulBuilder(builder: (context1, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 320,
          width: 260,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ]
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 240,
                      height: 20,
                      child:Text(
                        'Project Name:',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    Container(
                      width: 240,
                      height: 30,
                      alignment: Alignment.center,
                      child: TextField(
                        autofocus: false,
                        onChanged: (t){
                          projectName = t.replaceAll(' ', '_').toLowerCase();
                          if(t != ''){
                            errorMessage = null;
                          }
                          setState((){});
                        },
                        controller: newProjectController,
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(context).splashColor,
                          contentPadding: EdgeInsets.fromLTRB(2,10,0,10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor,
                              width: 1,
                              style: BorderStyle.none,
                            ),
                          ),
                        ),
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      width: 240,
                      height: 20,
                      child:Text(
                        'Flutter Name:',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: const EdgeInsets.fromLTRB(2, 4, 0, 0),
                      width: 240,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(context).hintColor,
                          width: 1,
                        ),
                      ),
                      child:Text(
                        projectName ?? '',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      width: 240,
                      height: 20,
                      child:Text(
                        'Location:',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    InkWell(
                      onTap: (){
                        getPath().then((path){
                          newProjectLocationController.text = path ?? '';
                          errorMessage = null;
                          setState((){});
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 240-30,
                            height: 30,
                            alignment: Alignment.center,
                            child: TextField(
                              readOnly: true,
                              autofocus: false,
                              controller: newProjectLocationController,
                              style: Theme.of(context).primaryTextTheme.bodySmall,
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Theme.of(context).splashColor,
                                contentPadding: EdgeInsets.fromLTRB(2,10,0,10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).hintColor,
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                            )
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                            width: 30,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5)
                              ),
                              border: Border.all(
                                color: Theme.of(context).hintColor,
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.folder_open_rounded,size: 20,)
                          ),
                        ],
                      )
                    ),
                  ]
                ),
                Container(
                  width: 240,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    errorMessage ?? '',
                    style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(color: Colors.red),
                  )
                ),
                InkWell(
                  onTap: (){
                    if(!creating){
                      final tempP = newProjectLocationController.text;
                      if(tempP == ''){
                        errorMessage = 'Please select a location!';
                        setState((){});
                        return;
                      }
                      else if(newProjectController.text == ''){
                        errorMessage = 'Please create a name for your project!';
                        setState((){});
                        return;
                      }
                      else{
                        for(final f in file){
                          if(f.path == '$tempP/$projectName'){
                            errorMessage = 'File name already exists!';
                            setState((){});
                            return;
                          }
                        }

                        createNewProject().then((_){
                          modalReset(context1);
                        });
                      }
                      creating = true;

                      setState((){});
                    }
                  },
                  child: Container(
                    width: 240,
                    height: 30,
                    decoration: BoxDecoration(
                      color:  Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: creating?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        SizedBox(width: 30, child:CircularProgressIndicator(color: Colors.white,))
                      ]):Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,size:20),
                        Text(
                          'Create Project',
                          style: Theme.of(context).primaryTextTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          })
        )
      );
    });
  }

  Widget empty(){
    Color textColor = Theme.of(context).primaryTextTheme.bodySmall!.color!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.flutter_dash_rounded,size: 40,color: Theme.of(context).hintColor ,),
        SizedBox(height: 10,),
        Text(
          'No Projects',
          style: Theme.of(context).primaryTextTheme.bodyMedium,
        ),
        SizedBox(height: 10,),
        Text(
          'Create a new project or select your projects folder to get started.',
          style: Theme.of(context).primaryTextTheme.bodySmall,
        ),
        SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                importProject();
              },
              child: Container(
                width: 120,
                height: 25,
                decoration: BoxDecoration(
                  //color:  Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).primaryColorLight
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder,size:15),
                    SizedBox(width: 5,),
                    Text(
                      'Import Project',
                      style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color:textColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 10,),
            InkWell(
              onTap: createNewProjectModal,
              child: Container(
                width: 120,
                height: 25,
                decoration: BoxDecoration(
                  //color:  Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).secondaryHeaderColor
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,size:20),
                    Text(
                      'New Project',
                      style: Theme.of(context).primaryTextTheme.labelSmall?.copyWith(color:textColor),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget projects(){
    List<Widget> widgets = [];
    currentProjects.sort((a,b){
      String key = 'dateCreated';
      if(modifier == 'Name'){ 
        key = 'title';
      }
      if(direction){
        return (a[key] as String).compareTo(b[key]);
      }
      else{
        return (b[key] as String).compareTo(a[key]);
      }
    });
    for(final project in currentProjects){
      if(serch.text == '' || (project['title'] as String).toLowerCase().contains(serch.text.toLowerCase())) widgets.add(
        InkWell(
          onTap: (){
            widget.setProject(project);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 52,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width-130-110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['title'] ?? '',
                        style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        project['location'] ?? '',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      ),
                    ],
                  )
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        (project['dateModified'] as String?)?.split(' ')[0] ?? '',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    SizedBox(
                      width: 70,
                      child:Text(
                        project['version'] ?? '',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      )
                    ),
                    InkWell(
                      onTap: (){
                        removeProject(project);
                      },
                      child: Icon(Icons.delete, size: 20,),
                    )
                  ],
                )
              ],
            ),
          )
        )
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: widgets,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left:10, right: 10,top: 5),
              height: 20,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/three_forge_icon.png'),
                  Container(
                    height: 20,
                    width: 35,
                    margin: EdgeInsets.only(right: 80),
                    child: Navigation(
                      width: 45,
                      radius: 10,
                      navData: [
                        NavItems(
                          name: themeType.name.toUpperCase(),
                          icon: themeType == LsiThemes.dark?Icons.nightlight_round_sharp:Icons.light_mode,
                          useName: false,
                          subItems: [
                            NavItems(
                              name: LsiThemes.dark.name.toUpperCase(),
                              icon: Icons.nightlight_round_sharp,
                              onTap: (_){
                                config.setSettingsKey({'theme':'dark'});
                                setState(() {
                                  themeType = LsiThemes.dark;
                                  theme = CSS.darkTheme;
                                });
                                widget.onDone();
                              }
                            ),
                            NavItems(
                              name: LsiThemes.light.name.toUpperCase(),
                              icon: Icons.light_mode,
                              onTap: (_){
                                config.setSettingsKey({'theme':'light'});
                                setState(() {
                                  themeType = LsiThemes.light;
                                  theme = CSS.lightTheme;
                                });
                                widget.onDone();
                              }
                            ),
                          ]
                        )
                      ]
                    )
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10,0,10,0),
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projects',
                    style: Theme.of(context).primaryTextTheme.displayMedium,
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Theme.of(context).splashColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                              )
                            ),
                            child: Icon(Icons.search),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(2, 0, 10, 0),
                            width: 240,
                            height: 35,
                            alignment: Alignment.center,
                            child: TextField(
                              autofocus: false,
                              onTap: (){
                                
                              },
                              onChanged: (t){
                                setState(() {});
                              },
                              controller: serch,
                              style: Theme.of(context).primaryTextTheme.bodyMedium,
                              decoration: InputDecoration(
                                isDense: true,
                                //labelText: label,
                                filled: true,
                                fillColor: Theme.of(context).splashColor,
                                contentPadding: EdgeInsets.all(15),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                  ),
                                ),
                                hintText: 'search'
                              ),
                            )
                          )
                        ],
                      ),
                      InkWell(
                        onTap: (){
                          importProject();
                        },
                        child: Container(
                          width: 130,
                          height: 30,
                          decoration: BoxDecoration(
                            //color:  Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).primaryColorLight
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder,size:20),
                              Text(
                                'Import Project'
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: createNewProjectModal,
                        child: Container(
                          width: 130,
                          height: 30,
                          decoration: BoxDecoration(
                            color:  Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,size:20),
                              Text(
                                'New Project'
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              height: 45,
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      setState(() {
                        if(modifier == 'Name'){
                          direction = !direction;
                        }
                        else{
                          modifier = 'Name';
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left:10),
                      width: MediaQuery.of(context).size.width-130-110,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Name'
                          ),
                          if(modifier == 'Name')direction?Icon(Icons.arrow_upward_sharp,size:20):Icon(Icons.arrow_downward_sharp,size:20),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            if(modifier == 'Modified'){
                              direction = !direction;
                            }
                            else{
                              modifier = 'Modified';
                            }
                          });
                        },
                        child: Container(
                          width: 130,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Modified'
                              ),
                              if(modifier == 'Modified')direction?Icon(Icons.arrow_upward_sharp,size:20):Icon(Icons.arrow_downward_sharp,size:20),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Version'
                            ),
                          ],
                        ),
                      ),
                      // InkWell(
                      //   onTap: (){
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return createTumbnailModal();
                      //       }
                      //     ).then((value){
                      //       modalReset(null);
                      //     });
                      //   },
                      //   child: Icon(Icons.settings, size: 20,),
                      // ),
                      Icon(Icons.settings, size: 20,),
                      SizedBox(width: 10,)
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height-145,
              child: currentProjects.isNotEmpty?projects():empty()
            )
          ],
        ),
      )
    );
  }
}