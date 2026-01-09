import "commands.dart";
import "package:three_js/three_js.dart";

class SetScriptValueCommand extends Command {
  String? newValue;
  Vector3? optionalOldPosition;
  String? oldValue;

	SetScriptValueCommand(super.editor, [super.object = null, Map<String,dynamic>? script, String attributeName = '', this.newValue = null ]) {
		this.attributeName = attributeName;
    this.script = script ?? {};
		this.updatable = true;
		this.oldValue = ( script != '' ) ? script![ this.attributeName! ] : null;
	}

	void execute() {
		this.script![this.attributeName!] = this.newValue;
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.script![this.attributeName!] = this.oldValue;
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetScriptValueCommand).newValue;
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['index'] = (this.object?.userData['scripts'] as List).indexOf( this.script );
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
		this.script = (this.object?.userData['scripts'] as List)[ json['index'] ];
	}
}