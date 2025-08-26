import 'package:three_js/three_js.dart';
import 'commands.dart';

class Command {
  int id = - 1;
	bool inMemory = false;
	bool updatable = false;
	String type = '';
	String name = '';
	Editor editor;
  String? attributeName;
  Map<String,dynamic>? script;
  Object3D? object;

  Map<String,dynamic> json = {};

	Command(this.editor);

  void execute(){}
  void undo(){}
  void update(Command command){}

	Map<String,dynamic> toJson() {
		return {
      'type': this.type,
      'id': this.id,
      'name': this.name
    };
	}

	void fromJson(Map<String,dynamic> json ) {
		this.inMemory = true;
		this.type = json['type'];
		this.id = json['id'];
		this.name = json['name'];
	}

  static Command? createCommand(String type, Editor editor){
    switch (type) {
      case 'AddObjectCommand':
        return AddObjectCommand(editor);
      case 'AddScriptCommand':
        return AddScriptCommand(editor);
      case 'MoveObjectCommand':
        return MoveObjectCommand(editor);
      case 'MultiCmdsCommand':
        return MultiCmdsCommand(editor);
      case 'RemoveObjectCommand':
        return RemoveObjectCommand(editor);
      case 'RemoveScriptCommand':
        return RemoveScriptCommand(editor);
      case 'SetColorCommand':
        return SetColorCommand(editor);
      case 'SetGeometryValueCommand':
        return SetGeometryValueCommand(editor);
      case 'SetGeometryCommand':
        return SetGeometryCommand(editor);
      case 'SetMaterialColorCommand':
        return SetMaterialColorCommand(editor);
      case 'SetMaterialMapCommand':
        return SetMaterialMapCommand(editor);
      case 'SetMaterialRangeCommand':
        return SetMaterialRangeCommand(editor);
      case 'SetMaterialValueCommand':
        return SetMaterialValueCommand(editor);
      case 'SetMaterialVectorCommand':
        return SetMaterialVectorCommand(editor);
      case 'SetMaterialCommand':
        return SetMaterialCommand(editor);
      case 'SetPositionCommand':
        return SetPositionCommand(editor);
      case 'SetSceneCommand':
        return SetSceneCommand(editor);
      case 'SetScriptValueCommand':
        return SetScriptValueCommand(editor);
      case 'SetShadowValueCommand':
        return SetShadowValueCommand(editor);
      case 'SetUuidCommand':
        return SetUuidCommand(editor);
      case 'SetValueCommand':
        return SetValueCommand(editor);
      default:
        return null;
    }
  }
}
