import "package:three_js/three_js.dart";

import "commands.dart";

class SetFogValueCommand extends Command {
  dynamic newValue;
  dynamic oldValue;
  FogBase? fog;

	SetFogValueCommand(super.editor, [this.fog, String attributeName = '', this.newValue]){
		this.attributeName = attributeName;
		this.updatable = true;

		this.oldValue = fog?[ attributeName ];
	}

	void execute() {
		this.fog?[ this.attributeName! ] = this.newValue;
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.fog?[ this.attributeName! ] = this.oldValue;
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetFogValueCommand).newValue;
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
