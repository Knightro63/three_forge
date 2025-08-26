import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class SetValueCommand extends Command {
  Object3D? object;
  dynamic newValue;
  dynamic oldValue;

	SetValueCommand(super.editor, [this.object, String attributeName = '', this.newValue]){
		this.attributeName = attributeName;
    this.type = 'SetValueCommand';
		this.name = editor.strings.getKey( 'command/SetValue' ) + ': ' + attributeName;
		this.updatable = true;

		this.oldValue = ( object != null ) ? object![ attributeName ] : null;
	}

	void execute() {
		this.object?[ this.attributeName! ] = this.newValue;
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void undo() {
		this.object?[ this.attributeName! ] = this.oldValue;
		this.editor.signals.objectChanged.dispatch( this.object );
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetValueCommand).newValue;
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

		this.attributeName = json['attributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
	}
}
