import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:three_js/three_js.dart';
import 'commands.dart';

enum CommandType {
  addObject,
  addScript,
  moveObject,
  multiCmds,
  removeObject,
  removeScript,
  setColor,
  setGeometryValue,
  setGeometry,
  setMaterialColor,
  setMaterialMap,
  setMaterialRange,
  setMaterialValue,
  setMaterialVector,
  setMaterial,
  setPosition,
  setScene,
  setScriptValue,
  setShadowValue,
  setUuid,
  setScale,
  setRotation,
  setFogValue,
  setUserDataValue,
  setValue;

  static CommandType getFromString(String type) {
    return CommandType.values.firstWhere((e) => e.name.toLowerCase() == type.toLowerCase());
  } 
  static CommandType getFromRuntimeType(String type) {
    switch (type) {
      case 'AddObjectCommand':
        return CommandType.addObject;
      case 'AddScriptCommand':
        return CommandType.addScript;
      case 'MoveObjectCommand':
        return CommandType.moveObject;
      case 'MultiCmdsCommand':
        return CommandType.multiCmds;
      case 'RemoveObjectCommand':
        return CommandType.removeObject;
      case 'RemoveScriptCommand':
        return CommandType.removeScript;
      case 'SetColorCommand':
        return CommandType.setColor;
      case 'SetGeometryValueCommand':
        return CommandType.setGeometryValue;
      case 'SetGeometryCommand':
        return CommandType.setGeometry;
      case 'SetMaterialColorCommand':
        return CommandType.setMaterialColor;
      case 'SetMaterialMapCommand':
        return CommandType.setMaterialMap;
      case 'SetMaterialRangeCommand':
        return CommandType.setMaterialRange;
      case 'SetMaterialValueCommand':
        return CommandType.setMaterialValue;
      case 'SetMaterialVectorCommand':
        return CommandType.setMaterialVector;
      case 'SetMaterialCommand':
        return CommandType.setMaterial;
      case 'SetPositionCommand':
        return CommandType.setPosition;
      case 'SetSceneCommand':
        return CommandType.setScene;
      case 'SetScriptValueCommand':
        return CommandType.setScriptValue;
      case 'SetShadowValueCommand':
        return CommandType.setShadowValue;
      case 'SetUuidCommand':
        return CommandType.setUuid;
      case 'SetScaleCommand':
        return CommandType.setScale;
      case 'SetFogValueCommand':
        return CommandType.setFogValue;
      case 'SetUserDataValueCommand':
        return CommandType.setUserDataValue;
      case 'SetRotationCommand':
        return CommandType.setRotation;
      case 'SetValueCommand':
        return CommandType.setValue;
      default:
        throw Exception('Unknown CommandType: $type');
    }
  } 
}

class Command {
  int id = - 1;
	bool inMemory = false;
	bool updatable = false;
	CommandType get type => CommandType.getFromRuntimeType(this.runtimeType.toString());
  set type(CommandType value) {}
	String get name => '$type: ${object?.name}';

	ThreeViewer editor;
  String? attributeName;
  Map<String,dynamic>? script;
  Object3D? object;
  bool allowDispatch = true;
  void Function()? onUndoDone;
  void Function()? onRedoDone;

  Map<String,dynamic> json = {};

	Command(this.editor,[this.object]);

  void execute(){}
  void undo(){
    onUndoDone?.call();
  }
  void redo(){
    onRedoDone?.call();
  }
  void update(Command command){}

	Map<String,dynamic> toJson() {
		return {
      'type': this.type.toString(),
      'id': this.id,
      'name': this.name
    };
	}

	void fromJson(Map<String,dynamic> json ) {
		this.inMemory = true;
		this.type = CommandType.getFromRuntimeType(json['type']);
		this.id = json['id'];
	}

  static Command createCommand(CommandType type, ThreeViewer editor){
    switch (type) {
      case CommandType.addObject:
        return AddObjectCommand(editor);
      case CommandType.addScript:
        return AddScriptCommand(editor);
      // case CommandType.moveObject:
      //   return MoveObjectCommand(editor);
      case CommandType.multiCmds:
        return MultiCmdsCommand(editor);
      case CommandType.removeObject:
        return RemoveObjectCommand(editor);
      case CommandType.removeScript:
        return RemoveScriptCommand(editor);
      // case CommandType.setColor:
      //   return SetColorCommand(editor);
      // case CommandType.setGeometryValue:
      //   return SetGeometryValueCommand(editor);
      // case CommandType.setGeometry:
      //   return SetGeometryCommand(editor);
      // case CommandType.setMaterialColor:
      //   return SetMaterialColorCommand(editor);
      // case CommandType.setMaterialMap:
      //   return SetMaterialMapCommand(editor);
      // case CommandType.setMaterialRange:
      //   return SetMaterialRangeCommand(editor);
      case CommandType.setMaterialValue:
        return SetMaterialValueCommand(editor);
      // case CommandType.setMaterialVector:
      //   return SetMaterialVectorCommand(editor);
      case CommandType.setMaterial:
        return SetMaterialCommand(editor);
      case CommandType.setPosition:
        return SetPositionCommand(editor);
      // case CommandType.setScene:
      //   return SetSceneCommand(editor);
      case CommandType.setScriptValue:
        return SetScriptValueCommand(editor);
      // case CommandType.setShadowValue:
      //   return SetShadowValueCommand(editor);
      // case CommandType.setUuid:
      //   return SetUuidCommand(editor);
      case CommandType.setFogValue:
        return SetFogValueCommand(editor);
      case CommandType.setUserDataValue:
        return SetUserDataValueCommand(editor);
      default:
        return SetValueCommand(editor);
    }
  }
}
