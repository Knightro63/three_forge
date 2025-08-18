export 'navData.dart';

import 'package:flutter/material.dart';
import 'navData.dart';
import '../styles/globals.dart';

class NavDropDown{
  NavDropDown({
    this.style = const TextStyle(
      //color: lsi.darkGrey,
      fontFamily: 'Klavika',
      fontSize: 14
    ),
    required this.navData,
    required this.context,
    required this.key,
    this.offset = const Offset(0,0)
  });

  bool isOpen = false;
  OverlayEntry? _overlayEntry;
  late Offset buttonPosition;
  late Size buttonSize;
  TextStyle style;
  NavItems navData;
  BuildContext context;
  GlobalKey key;
  Offset offset = const Offset(0,0);

  findButton() {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero)+offset;
  }

  void close(){
    if(isOpen){
      _overlayEntry!.remove();
      isOpen = !isOpen;
    }
  }

  void open(){
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    if(!isOpen){
      Overlay.of(context).insert(_overlayEntry!);
      isOpen = !isOpen;
    }
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx,
          width: 120,
          child: OverlayClass(
            subItems: navData.subItems,
            itemHeight: buttonSize.height,
            style: style,
            onTap: (){
              if(_overlayEntry != null){
                close();
              }
            }
          )
        );
      },
    );
  }
}

class Navigation extends StatefulWidget{
  Navigation({
    Key? key, 
    this.height = 45,
    this.width = double.infinity,
    this.callback, 
    this.showNavList = true,
    required this.navData,
    this.tabs,
    this.selectedTab = 0,
    this.sideOnTap,
    this.reset = false,
    this.centerNavData,
    this.spacer,
    this.radius,
    this.style = const TextStyle(
      //color: lsi.darkGrey,
      fontFamily: 'Klavika',
      fontSize: 14
    ),
    this.margin
  }):super(key: key);

  final void Function(String)? sideOnTap;
  final void Function({required LSICallbacks call})? callback;
  final bool reset;
  final bool showNavList;
  final List<NavItems> navData;
  final List<NavItems>? centerNavData;
  final List<NavTab>? tabs;
  final double width;
  final double height;
  final TextStyle style;
  final int selectedTab;
  //final Widget? centerWidgets;
  final Widget? spacer;
  final EdgeInsets? margin;
  final double? radius;
  //final List<Widget> endWidgets;

  @override
  _NavState createState() => _NavState();
}
class _NavState extends State<Navigation>{
  int? location;
  String currentItem = '';
  List<NavDropDown> nav = [];
  List<GlobalKey> _key = [];

  @override
  void initState() {
    for(int i = 0; i < widget.navData.length;i++){
      String keyName = "nav_item_$i";
      _key.add(LabeledGlobalKey(keyName));
      nav.add(
        NavDropDown(
          key: _key[i],
          context: context,
          navData: widget.navData[i]
        )
      );
    }
    for(int i = 0; i < (widget.centerNavData?.length ?? 0);i++){
      int j = i+widget.navData.length;
      String keyName = "nav_item_$j";
      _key.add(LabeledGlobalKey(keyName));
      nav.add(
        NavDropDown(
          key: _key[j],
          context: context,
          navData: widget.centerNavData![i]
        )
      );
    }
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  void setNavData(){
    
  }

  Widget items(List<NavItems> data, int start){
    List<Widget> widgets = [];
    for(int i = 0; i < data.length;i++){
      if(data[i].show)widgets.add(
        NavItem(
          itemKey: _key[start+i],
          style: widget.style,
          itemName: data[i].name,
          selected: currentItem,
          icon: data[i].icon,
          useName: data[i].useName,
          onHover: (){
            setState(() {
              if(location != i){
                bool hasOpen = false;
                for(int j = 0; j < nav.length; j++){
                  if(nav[j].isOpen){
                    nav[j].close();
                    hasOpen = true;
                  }
                }
                if(hasOpen){
                  location = start+i;
                  currentItem = data[i].name;
                  nav[start+i].open();
                }
              }
            });
          },
          onTap: (){
            if(data[i].subItems == null){
              data[i].onTap?.call(null);
            }
            else{
              setState(() {
                if(nav[start+i].isOpen){
                  currentItem = '';
                  nav[start+i].close();
                }
                else{
                  currentItem = data[i].name;
                  location =start+i;
                  nav[start+i].open();
                }

                data[i].onTap?.call(null);
              });
            }
          }
        )
      );
      if(widget.spacer != null && data.length > 0 && i < data.length-1){
        widgets.add(widget.spacer!);
      }
    }
    return Row(children: widgets);
  }

  Widget tabs(){
   List<Widget> widgets = [];
    if(widget.tabs == null) return Row(children:widgets);
    for(int i = 0; i < widget.tabs!.length;i++){
      widgets.add(
        NavTabs(
          style: widget.style,
          itemName: widget.tabs![i].name,
          selected: i == widget.selectedTab?widget.tabs![i].name:currentItem,
          onHover: (){
            setState(() {
              if(currentItem != ''){
                for(int j = 0; j < nav.length; j++){
                  if(nav[j].isOpen){
                    nav[j].close();
                  }
                }
                //location = i+widget.navData.length;
                currentItem = '';
              }
            });
          },
          onTap: (){
            setState(() {
              if(widget.tabs![i].function != null){
                widget.tabs![i].function!(i);
              }
            });
          }
        )
      );
    }
    return Row(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.reset){
      setState(() { 
        currentItem = ''; 
        for(int i = 0; i < nav.length; i++){
          if(nav[i].isOpen){
            nav[i].close();
          }
          if(i < widget.navData.length){
            nav[i].navData = widget.navData[i];
          }
          else{
            nav[i].navData = widget.centerNavData![i-widget.navData.length];
          }
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(widget.callback != null){
          widget.callback!(call: LSICallbacks.updatedNav);
        }
      });
    }
    
    return Container(
      height: widget.height,
      width: widget.width,
      padding: widget.margin,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: widget.radius == null?null:BorderRadius.circular(widget.radius!),
        boxShadow: [BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 5,
          offset: const Offset(0,1),
        ),]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[items(widget.navData,0), widget.centerNavData != null?items(widget.centerNavData!,widget.navData.length):SizedBox(),tabs()]
      ),
    );
  }
}

class NavTabs extends StatefulWidget{
  const NavTabs({
    Key? key,
    this.hoverColor = Colors.blue,
    required this.itemName,
    required this.onHover, 
    required this.onTap,
    required this.selected,
    required this.style
  }):super(key: key);

  final String itemName;
  final Function onHover;
  final Color hoverColor;
  final TextStyle style;
  final Function onTap;
  final String selected;

  @override
  _NavTabsState createState() => _NavTabsState();
}
class _NavTabsState extends State<NavTabs>{
  bool hovering = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (PointerEvent details){
          setState(() {
            hovering = true;
          });
        },
        onExit: (PointerEvent details){
          setState(() {
            hovering = false;
          });
        },
        onHover: (val){
          widget.onHover();
        },
        child: Container(
          height: 20,
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.fromLTRB(2, 5, 0, 0),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            color: (!hovering && widget.selected != widget.itemName)?Colors.white.withAlpha(50):widget.hoverColor,
            borderRadius: const BorderRadius.only(topLeft:Radius.circular(5),topRight:Radius.circular(5)),
            //border: border
          ),
          child:Text(
            widget.itemName,
            style: widget.style,
          )
        ),
      )
    );
  }
}

class NavItem extends StatefulWidget{
  const NavItem({
    Key? key,
    required this.itemKey, 
    this.hoverColor = Colors.blue,
    required this.itemName,
    required this.onHover, 
    required this.onTap,
    this.selected = '',
    required this.style,
    required this.icon,
    this.useName = true,
  }):super(key: key);

  final String itemName;
  final Function onHover;
  final Color hoverColor;
  final TextStyle style;
  final Function onTap;
  final String selected;
  final GlobalKey itemKey;
  final IconData? icon;
  final bool useName;

  @override
  _NavItemState createState() => _NavItemState();
}
class _NavItemState extends State<NavItem>{
  bool hovering = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (PointerEvent details){
          setState(() {
            hovering = true;
          });
        },
        onExit: (PointerEvent details){
          setState(() {
            hovering = false;
          });
        },
        onHover: (val){
          widget.onHover();
        },
        child: Container(
          key: widget.itemKey,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            color: (!hovering && widget.selected != widget.itemName)?null:widget.hoverColor,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            //border: border
          ),
          child: !widget.useName && widget.icon != null?Icon(
            widget.icon,
            color: widget.style.color,
            size: widget.style.fontSize,
          ):widget.icon != null? Row(
            children: [
              Icon(
                widget.icon,
                color: widget.style.color,
                size: widget.style.fontSize,
              ),
              Text(
                widget.itemName,
                style: widget.style,
              )
            ],
          ):
          Text(
            widget.itemName,
            style: widget.style,
          )
        ),
      )
    );
  }
}

class OverlayClass extends StatefulWidget {
  const OverlayClass({
    Key? key,
    this.hoverColor = Colors.blue,
    this.subItems,
    required this.itemHeight,
    required this.style,
    required this.onTap,
  }):super(key: key);

  final Color hoverColor;
  final List<NavItems>? subItems;
  final double itemHeight;
  final TextStyle style;
  final Function onTap;

  @override
  _OverlayClassState createState() => _OverlayClassState();
}
class _OverlayClassState extends State<OverlayClass> {
  String itemName = '';
  int? location;
  List<GlobalKey> _key = [];
  List<NavDropDown> nav = [];
  List<int?> indicies = [];
  List<int> controllerIndicies = [];
  List<TextEditingController> controller = [];

  @override
  void initState() {
    if(widget.subItems != null){
      int k = 0;
      for(int i = 0; i < widget.subItems!.length;i++){
        String keyName = "nav_sub_item_$i";
        GlobalKey key = LabeledGlobalKey(keyName);
        _key.add(key);
        if(widget.subItems![i].subItems != null){
          nav.add(
            NavDropDown(
              key: key,
              context: context,
              navData: widget.subItems![i],
              offset: const Offset(122,-35)
            )
          );
          indicies.add(k);
          k++;
        }
        else{
          indicies.add(null);
        }
        controller.add(TextEditingController());
        if(widget.subItems![i].input != null){
          controller[controller.length-1].text = widget.subItems![i].input.toString();
        }
      }
    }

    super.initState();
  }

  @override
  void dispose(){
    for(int i = 0; i < nav.length; i++){
      if(nav[i].isOpen){
        nav[i].close();
      }
    }
    super.dispose();
  }

  Widget navSubButtons(){
    List<Widget> widgets = [];
    if(widget.subItems != null){
      for(int i = 0; i < widget.subItems!.length; i++){
        if(widget.subItems![i].show){
          widgets.add(
            InkWell(
              key: _key[i],
              onTap:(){
                if(widget.subItems![i].onTap != null){
                  widget.onTap();
                  widget.subItems![i].onTap!(null);
                }
                else if(nav.isNotEmpty && widget.subItems![i].subItems != null && !nav[indicies[i]!].isOpen){
                  for(int j = 0; j < indicies.length; j++){
                    if(indicies[j] != null && nav[indicies[j]!].isOpen){
                      nav[indicies[j]!].close();
                    }
                  }
                  nav[indicies[i]!].open();
                  location = indicies[i];
                }
                else if(nav.isNotEmpty && nav[indicies[i]!].isOpen){
                  nav[indicies[i]!].close();
                }
              },
              child: MouseRegion(
                onEnter: (PointerEvent details){
                  if(indicies[i] != location && location != null){
                    nav[location!].close();
                    location = null;
                  }
                  setState(() {
                    itemName = widget.subItems![i].name;
                  });
                },
                onExit: (PointerEvent details){
                  setState(() {
                    itemName = '';
                  });
                },
                //onHover: widget.onHover,
                child: Container(
                  decoration: BoxDecoration(
                    color: (itemName == widget.subItems![i].name)?widget.hoverColor:null,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    //border: border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          (widget.subItems![i].icon != null)?
                          RotatedBox(
                            quarterTurns: widget.subItems![i].quarterTurns,
                            child: Icon(
                              widget.subItems![i].icon,
                              color: widget.style.color,
                              size: widget.style.fontSize,
                            )
                          ):const SizedBox(width:14),
                          const SizedBox(width:5),
                          Text(
                            widget.subItems![i].name,
                            style: widget.style,
                          )
                      ],),
                      Row(children: [
                        widget.subItems![i].subItems != null?Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: widget.style.color,
                            size: widget.style.fontSize,
                          ):widget.subItems![i].input != null?Container(
                            margin: const EdgeInsets.all(0),
                            width: 50,
                            height: 19,
                            alignment: Alignment.center,
                            child: TextField(
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                isDense: true,
                                //labelText: label,
                                filled: true,
                                fillColor: Theme.of(context).splashColor,
                                contentPadding: const EdgeInsets.all(5),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  borderSide: BorderSide(
                                      width: 0, 
                                      style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              controller: controller[i],
                              maxLines: 1,
                              onTap: (){},
                              onEditingComplete: (){
                                widget.subItems![i].onChange?.call(controller[i].text);
                              },
                              onSubmitted: (e){
                                if(e != ''){
                                  widget.subItems![i].onChange?.call(e);
                                }
                              },
                              onChanged: (e){
                                if(e != ''){
                                  widget.subItems![i].onChange?.call(e);
                                }
                              },
                          )
                          ):Container()
                      ],)
                  ],)
                )
              )
            )
          );
        }
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      //mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
        //height: widget.subItems.length * widget.itemHeight+20,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(2,2),
          ),]
        ),
        child: navSubButtons()
      )
    );
  }
}