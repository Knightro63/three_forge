enum ForgeScene{main,rig,animate}
enum ShadingType{wireframe,solid,material}
enum ControlSpaceType{global,local}
enum EditType{point,edge,face}
enum SelectorType{
  translate,rotate,scale,select,paint,erase;

  bool get isGimble => index < 3;
}