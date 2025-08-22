import "dart:convert";

import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetSceneCommand extends Command {
  Scene? scene;
  List cmdArray = [];

	SetSceneCommand(super.editor, [this.scene = null ]) {
		this.type = 'SetSceneCommand';
		this.name = editor.strings.getKey( 'command/SetScene' );

		if ( scene != null ) {
			this.cmdArray.add( new SetUuidCommand( this.editor, this.editor.scene, scene?.uuid ) );
			this.cmdArray.add( new SetValueCommand( this.editor, this.editor.scene, 'name', scene?.name ) );
			this.cmdArray.add( new SetValueCommand( this.editor, this.editor.scene, 'userData', scene?.userData));

			while ( (scene?.children.length ?? 0) > 0 ) {
				final child = scene?.children.removeLast();
				this.cmdArray.add( new AddObjectCommand( this.editor, child ) );
			}
		}
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

		const cmds = [];
		for ( int i = 0; i < this.cmdArray.length; i ++ ) {
			cmds.add( this.cmdArray[ i ].toJson() );
		}

		output['cmds'] = cmds;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		final cmds = json['cmds'];

		for (int i = 0; i < cmds.length; i ++ ) {
			const cmd = new window[ cmds[ i ].type ]();	// creates a new object of type "json.type"
			cmd.fromJson( cmds[ i ] );
			this.cmdArray.add( cmd );
		}
	}
}
