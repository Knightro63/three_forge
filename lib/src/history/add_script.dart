import "commands.dart";

class AddScriptCommand extends Command {
	AddScriptCommand(super.editor, [super.object, Map<String,dynamic>? script]){
    this.script = script ?? {};
  }

	void execute() {
		if ( this.object?.userData['scripts'] == null ) {
			this.object?.userData['scripts'] = [];
		}

		this.object?.userData['scripts'].add( this.script );
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		if ( this.object?.userData['scripts'] == null ) return;
		final index = (this.object?.userData['scripts'] as List).indexOf( this.script );

		if ( index != - 1 ) {
			(this.object?.userData['scripts'] as List).removeAt(index);
		}

		this.editor.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['script'] = this.script;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );
		this.script = json['script'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
	}
}
