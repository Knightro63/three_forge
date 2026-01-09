import "commands.dart";

class MultiCmdsCommand extends Command {
  List<Command> cmdArray = [];

	MultiCmdsCommand(super.editor, [List<Command>? cmdArray] ) {
    this.cmdArray = cmdArray ?? [];
	}

	void execute() {
		for (int i = 0; i < this.cmdArray.length; i ++ ) {
			this.cmdArray[ i ].execute();
		}
	}

  @override
	void undo() {
    super.undo();
		for (int i = this.cmdArray.length - 1; i >= 0; i -- ) {
			this.cmdArray[ i ].undo();
		}
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
			final cmd = Command.createCommand(cmds![ i ]['type'], editor);
			cmd.fromJson( cmds[i] );
			this.cmdArray.add( cmd );
		}
	}
}
