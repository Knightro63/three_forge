import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class SetShadowValueCommand extends Command {
  Light? object;
  String attributeName = '';
  dynamic newValue;
  dynamic oldValue;

	SetShadowValueCommand(super.editor, [this.object = null, attributeName = '', newValue = null ]) {
		this.type = 'SetShadowValueCommand';
		this.name = editor.strings.getKey( 'command/SetShadowValue' ) + ': ' + attributeName;
		this.updatable = true;
		this.oldValue = ( object != null ) ? object?.shadow[ attributeName ] : null;
	}

	void execute() {
		this.object?.shadow[ this.attributeName ] = this.newValue;
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void undo() {
		this.object?.shadow[ this.attributeName ] = this.oldValue;
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void update( cmd ) {
		this.newValue = cmd.newValue;
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

		this.object = this.editor.objectByUuid( json['objectUuid'] ) as Light;
		this.attributeName = json['attributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
	}
}
