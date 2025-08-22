import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetGeometryValueCommand extends Command {
  Object3D? object;
  String attributeName;
  int? newValue;
  int? oldValue;

	SetGeometryValueCommand(super.editor, [this.object = null, this.attributeName = '', this.newValue = null ]) {
		this.type = 'SetGeometryValueCommand';
		this.name = editor.strings.getKey( 'command/SetGeometryValue' ) + ': ' + attributeName;

		this.oldValue = ( object != null ) ? object?.geometry?[ attributeName ] : null;
	}

	void execute() {
		this.object?.geometry?[ this.attributeName ] = this.newValue;
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.geometryChanged.dispatch();
		this.editor.signals.sceneGraphChanged.dispatch();
	}

	void undo() {
		this.object?.geometry?[ this.attributeName ] = this.oldValue;
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.geometryChanged.dispatch();
		this.editor.signals.sceneGraphChanged.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['attributeName'] = this.attributeName;
		output['oldValue'] = this.oldValue;
		output['newValue'] = this.newValue;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.attributeName = json['attributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
	}
}
