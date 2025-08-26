import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class SetColorCommand extends Command {
  Object3D? object;
  int? newValue;
  int? oldValue;

	SetColorCommand(super.editor, [this.object = null, String attributeName = '', this.newValue = null ]) {
		this.attributeName = attributeName;
    this.type = 'SetColorCommand';
		this.name = editor.strings.getKey( 'command/SetColor' ) + ': ' + attributeName;
		this.updatable = true;

		this.oldValue = ( object != null ) ? this.object![ this.attributeName ].getHex() : null;
	}

	void execute() {
		this.object?[ this.attributeName ].setHex( this.newValue );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void undo() {
		this.object?[ this.attributeName ].setHex( this.oldValue );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetColorCommand).newValue;
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
