import "package:three_forge/src/history/commands.dart";

class MultiCmdsCommand extends Command {
  List<Command> cmdArray = [];
	/**
	 * @param {Editor} editor
	 * @param {Array<Command>} [cmdArray=[]]
	 * @constructor
	 */
	MultiCmdsCommand(super.editor, [List<Command>? cmdArray] ) {
		this.type = 'MultiCmdsCommand';
		this.name = editor.strings.getKey( 'command/MultiCmds' );
    this.cmdArray = cmdArray ?? [];
	}

	void execute() {
		this.editor.signals.sceneGraphChanged.active = false;

		for (int i = 0; i < this.cmdArray.length; i ++ ) {
			this.cmdArray[ i ].execute();
		}

		this.editor.signals.sceneGraphChanged.active = true;
		this.editor.signals.sceneGraphChanged.dispatch();
	}

	void undo() {
		this.editor.signals.sceneGraphChanged.active = false;

		for (int i = this.cmdArray.length - 1; i >= 0; i -- ) {
			this.cmdArray[ i ].undo();
		}

		this.editor.signals.sceneGraphChanged.active = true;
		this.editor.signals.sceneGraphChanged.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();
		final List<Map<String,dynamic>> cmds = [];

		for (int i = 0; i < this.cmdArray.length; i ++ ) {
			cmds.add( this.cmdArray[ i ].toJson() );
		}

		output['cmds'] = cmds;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		final cmds = json['cmds'] as List<Map<String,dynamic>>?;

		for (int i = 0; i < (cmds?.length ?? 0); i ++ ) {
			final cmd = Command.createCommand(cmds![ i ]['type'], editor);//window[ cmds[ i ].type ]();	// creates a new object of type "json.type"
			cmd?.fromJson( cmds[i] );
			this.cmdArray.add( cmd! );
		}
	}
}
