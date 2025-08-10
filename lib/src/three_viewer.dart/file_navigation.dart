import 'package:flutter/material.dart';

class FileNavigation extends StatefulWidget {
  const FileNavigation({Key? key}):super(key: key);

  @override
  _FileNavigationState createState() => _FileNavigationState();
}

class _FileNavigationState extends State<FileNavigation>{
  bool consoleSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width*.8,
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
            width: MediaQuery.of(context).size.width*8,
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(5)
            ),
            child: Row(
              children: [

              ],
            ),
          )
        ],
      ),
    );
  }
}