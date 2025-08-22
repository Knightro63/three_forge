import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetScriptValueCommand extends Command {
  Object3D? object;
  String? newValue;
  Vector3? optionalOldPosition;
  String? oldValue;
  String attributeName;
  String script;

	SetScriptValueCommand(super.editor, [this.object = null, this.script = '', this.attributeName = '', this.newValue = null ]) {
		this.type = 'SetScriptValueCommand';
		this.name = editor.strings.getKey( 'command/SetScriptValue' ) + ': ' + attributeName;
		this.updatable = true;
		this.oldValue = ( script != '' ) ? script[ this.attributeName ] : null;
	}

	void execute() {
		this.script[ this.attributeName ] = this.newValue;
		this.editor.signals.scriptChanged.dispatch( this.script );
	}

	void undo() {
		this.script[ this.attributeName ] = this.oldValue;
		this.editor.signals.scriptChanged.dispatch( this.script );
	}

	void update( cmd ) {
		this.newValue = cmd.newValue;
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['index'] = this.editor.scripts[ this.object?.uuid ].indexOf( this.script );
		output['attributeName'] = this.attributeName;
		output['oldValue'] = this.oldValue;
		output['newValue'] = this.newValue;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
		this.attributeName = json['attributeName'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.script = this.editor.scripts[ json['objectUuid'] ][ json['index'] ];
	}
}