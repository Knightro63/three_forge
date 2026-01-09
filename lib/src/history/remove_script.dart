import "commands.dart";

class RemoveScriptCommand extends Command {
  int? index;

	RemoveScriptCommand(super.editor, [super.object, Map<String,dynamic>? script]) {
    this.script = script ?? {};

		if ( this.object != null && this.script != '' ) {
			this.index = (this.object?.userData['scripts'] as List?)?.indexOf( this.script );
		}
	}

	void execute() {
		if ( (this.object?.userData['scripts'] as List?) == null ) return;

		if ( this.index != - 1 ) {
			(this.object?.userData['scripts'] as List?)?.removeAt( this.index! );
		}

		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		if ( (this.object?.userData['scripts'] as List?) == null ) {
			this.object?.userData['scripts'] = [];
		}

		(this.object?.userData['scripts'] as List?)?.insert( this.index!, this.script );
		this.editor.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['script'] = this.script;
		output['index'] = this.index;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );
		this.script = json['script'];
		this.index = json['index'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
	}
}
