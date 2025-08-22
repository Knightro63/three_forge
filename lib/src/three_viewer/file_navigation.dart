import 'dart:io';

import 'package:flutter/material.dart';

class FileNavigation extends StatefulWidget {
  const FileNavigation({Key? key, required this.files, required this.consoleLog}):super(key: key);
  final Map<String,dynamic> files;
  final String consoleLog;

  @override
  _FileNavigationState createState() => _FileNavigationState();
}

class _FileNavigationState extends State<FileNavigation>{
  late final String mainPath;
  bool consoleSelected = false;
  Map<String,List<FileSystemEntity>> files = {};
  List<String> filesOpen = [];
  String? folderSelected;

  @override
  void initState() {
    super.initState();
    mainPath = widget.files['location'];
    onEventChange();
    Directory(widget.files['location']).watch().listen((event){
      onEventChange();
    });
  }

  void onEventChange(){
    files['main'] = Directory(widget.files['location']).listSync();
  }

  Widget getFileTye(FileSystemEntity file){
    String path = file.path;
    bool isImag =  path.contains('.hdr') || path.contains('.jpg') || path.contains('.png') || path.contains('.jpeg') || path.contains('.tiff') || path.contains('.bmp');

    if(path.contains('/models/') && !isImag){
      final fullName = file.path.split('/').last;
      //final fileType = fullName.split('.').last;
      final name = fullName.split('.').first;

      path = path.split('/models').first+'/thumbnails/$name.png';
      isImag = true;
    }

    if(file is Directory && !path.contains('/thumbnails/')){
      return Icon(Icons.folder);
    }
    else if(path.contains('.dart')){
      return Icon(Icons.flutter_dash);
    }
    else if(isImag){
      return SizedBox(width: 75, height: 75, child: Image.file(File(path)));
    }
    else if(path.contains('mp3') || path.contains('ogg')){
      return Icon(Icons.audio_file);
    }
    else{
      return Icon(Icons.description);
    }
  }

  Widget displayFilesInFolder(double width){
    List<Widget> widgets = [];

    Widget card(FileSystemEntity file){
      return Container(
        width: 91,
        height: 91,
        child: Column(
          children: [
            getFileTye(file),
            SizedBox(width: 2,),
            Text(
              file.path.split('/').last,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).primaryTextTheme.bodySmall,
            )
          ],
        ),
      );
    }

    if(files[folderSelected!] != null) for(final file in files[folderSelected!]!){
      if(file.path.split('/').last[0] != '.'){
        String name = file.path.split('/').last;
        dynamic data = file is Directory?'${file.path}/$name.folder':file.path;
    
        widgets.add(
          Draggable(
            feedback: card(file),
            child: InkWell(
              onDoubleTap: (){
                setState(() {
                  folderSelected = file.path;
                  files[file.path] = Directory(file.path).listSync();
                });
              },
              child: card(file)
            ),
            data: data,
          )
        );
      }
    }

    return Container(
      padding: EdgeInsets.all(5),
      color: Theme.of(context).cardColor,
      height: 220,
      width: width,
      child: SingleChildScrollView(
        child: Wrap(
          children: widgets,
        ) 
      ),
    );
  }

  Widget folderStructure(){
    List<Widget> widgets = [];

    void folderView(String key, int level){
      for(final file in files[key]!){
        final bool contains = files.containsKey(file.path) && filesOpen.contains(file.path);
        if(file is Directory && !file.path.split('/').last.contains('.')) widgets.add(Container(
          margin: EdgeInsets.only(left: level*10),
          width: 140,
          height: 20,
          color: folderSelected == file.path?Theme.of(context).secondaryHeaderColor:null,
          child: InkWell(
            onTap: (){
              setState(() {
                folderSelected = file.path;
                files[file.path] = Directory(file.path).listSync();
              });
            },
            child: Row(
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      if(contains){
                        files.remove(file.path);
                        filesOpen.remove(file.path);
                      }
                      else{
                        files[file.path] = Directory(file.path).listSync();
                        filesOpen.add(file.path);
                      }
                    });
                  },
                  child: Icon(contains?Icons.arrow_drop_down_rounded:Icons.arrow_right_rounded,size: 20,)
                ),
                Icon(Icons.folder,size: 15,),
                SizedBox(width: 2,),
                Text(
                  file.path.split('/').last,
                  style: Theme.of(context).primaryTextTheme.bodySmall,
                )
              ],
            )
          ),
        ));

        if(contains){
          final int newLevel = file.path.replaceAll(mainPath, '').split('/').length-1;
          folderView(file.path, newLevel);
        }
      }
    }

    folderView('main', 0);

    return Container(
      margin: EdgeInsets.only(left: 5,right: 5),
      color: Theme.of(context).cardColor,
      width: 140,
      height: 220,
      child: ListView(
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width*.8;
    return Container(
      color: Theme.of(context).cardColor,
      width: width,
      height: 260,
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                InkWell(
                  onTap: (){
                    consoleSelected = false;
                    setState(() {
                      
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5,right: 5),
                    width: 80,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: consoleSelected?Theme.of(context).cardColor:Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      'Project',
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    consoleSelected = true;
                    setState(() {
                      
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: consoleSelected?Theme.of(context).secondaryHeaderColor:Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      'Console',
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 230,
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(5)
            ),
            child: consoleSelected?Container(
                width: width,
                height: 220,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    widget.consoleLog
                  ),
                )
              ):Row(
              children: [
                folderStructure(),
                folderSelected != null?displayFilesInFolder(width-160):
                Container(
                  color: Theme.of(context).cardColor,
                  width: width-160,
                  height: 220,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}