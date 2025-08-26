import "package:three_forge/src/history/commands.dart";
import "package:three_forge/src/styles/config.dart";
import "package:three_js/three_js.dart";

class History {
  Editor editor;
  List undos = [];
  List redos = [];
  int lastCmdTime = DateTime.now().millisecondsSinceEpoch;
  int idCounter = 0;
  bool historyDisabled = false;
  late Config config;

	History(this.editor ) {
		this.config = editor.config;

		this.editor.signals.startPlayer.add(() {
			historyDisabled = true;
		});

		this.editor.signals.stopPlayer.add(() {
			historyDisabled = false;
		});
	}

	void execute(Command cmd, optionalName ) {
		final lastCmd = this.undos[ this.undos.length - 1 ] as Command?;
		final timeDifference = DateTime.now().millisecondsSinceEpoch - this.lastCmdTime;

		final isUpdatableCmd = lastCmd != null&&
			lastCmd.updatable &&
			cmd.updatable &&
			lastCmd.object == cmd.object &&
			lastCmd.type == cmd.type &&
			lastCmd.script == cmd.script &&
			lastCmd.attributeName == cmd.attributeName;

		if ( isUpdatableCmd && cmd  is SetScriptValueCommand) {
			// When the cmd.type is "SetScriptValueCommand" the timeDifference is ignored

			lastCmd.update( cmd );
			cmd = lastCmd;
		} 
    else if ( isUpdatableCmd && timeDifference < 500 ) {
			lastCmd.update( cmd );
			cmd = lastCmd;
		} 
    else {
			// the command is not updatable and is added as a new part of the history

			this.undos.add( cmd );
			cmd.id = ++ this.idCounter;
		}

		cmd.name = ( optionalName != null ) ? optionalName : cmd.name;
		cmd.execute();
		cmd.inMemory = true;

		// if ( this.config.getKey( 'settings/history' ) ) {
		// 	cmd.json = cmd.toJson();	// serialize the cmd immediately after execution and append the json to the cmd
		// }

		this.lastCmdTime = DateTime.now().millisecondsSinceEpoch;

		// clearing all the redo-commands

		this.redos = [];
		this.editor.signals.historyChanged.dispatch( cmd );
	}

	Command? undo() {
		if ( this.historyDisabled ) {
			console.error( this.editor.strings.getKey( 'prompt/history/forbid' ) );
			return null;
		}

		Command? cmd;

		if ( this.undos.length > 0 ) {
			cmd = this.undos.removeLast();
			if ( cmd?.inMemory == false ) {
				cmd?.fromJson( cmd.json );
			}
		}

		if ( cmd != null ) {
			cmd.undo();
			this.redos.add( cmd );
			this.editor.signals.historyChanged.dispatch( cmd );
		}

		return cmd;
	}

	Command? redo() {
		if ( this.historyDisabled ) {
			console.error( this.editor.strings.getKey( 'prompt/history/forbid' ) );
			return null;
		}

		Command? cmd;

		if ( this.redos.length > 0 ) {
			cmd = this.redos.removeLast();
			if ( cmd?.inMemory == false ) {
				cmd?.fromJson( cmd.json );
			}
		}

		if ( cmd != null ) {
			cmd.execute();
			this.undos.add( cmd );
			this.editor.signals.historyChanged.dispatch( cmd );
		}

		return cmd;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> history = {};
		history['undos'] = [];
		history['redos'] = [];

		// if ( ! this.config.getKey( 'settings/history' ) ) {
		// 	return history;
		// }

		// Append Undos to History

		for (int i = 0; i < this.undos.length; i ++ ) {
			if ( this.undos[ i ].hasOwnProperty( 'json' ) ) {
				history['undos'].add( this.undos[ i ].json );
			}
		}

		// Append Redos to History

		for (int i = 0; i < this.redos.length; i ++ ) {
			if ( this.redos[ i ].hasOwnProperty( 'json' ) ) {
				history['redos'].add( this.redos[ i ].json );
			}
		}

		return history;
	}

	void fromJson(Map<String, dynamic>? json ) {
		if ( json == null ) return;
		for (int i = 0; i < json['undos'].length; i ++ ) {
			final cmdJSON = json['undos'][ i ] as Map<String,dynamic>;
			final cmd = Command.createCommand(cmdJSON['type'], editor)!;//Commands[ cmdJSON.type ]( this.editor ); // creates a new object of type "json.type"
			cmd.json = cmdJSON;
			cmd.id = cmdJSON['id'];
			cmd.name = cmdJSON['name'];
			this.undos.add( cmd );
			this.idCounter = ( cmdJSON['id'] > this.idCounter ) ? cmdJSON['id'] : this.idCounter; // set last used idCounter
		}

		for (int i = 0; i < json['redos'].length; i ++ ) {
			final cmdJSON = json['redos'][ i ] as Map<String,dynamic>;
			final cmd = Command.createCommand(cmdJSON['type'], editor)!;//Commands[ cmdJSON.type ]( this.editor ); // creates a new object of type "json.type"
			cmd.json = cmdJSON;
			cmd.id = cmdJSON['id'];
			cmd.name = cmdJSON['name'];
			this.redos.add( cmd );
			this.idCounter = ( cmdJSON['id'] > this.idCounter ) ? cmdJSON['id'] : this.idCounter; // set last used idCounter
		}

		// Select the last executed undo-command
		this.editor.signals.historyChanged.dispatch( this.undos[ this.undos.length - 1 ] );
	}

	void clear() {
		this.undos = [];
		this.redos = [];
		this.idCounter = 0;
		this.editor.signals.historyChanged.dispatch();
	}

	void goToState( id ) {
		if ( this.historyDisabled ) {
			console.error( this.editor.strings.getKey( 'prompt/history/forbid' ) );
			return;
		}

		this.editor.signals.sceneGraphChanged.active = false;
		this.editor.signals.historyChanged.active = false;

		dynamic cmd = this.undos.length > 0 ? this.undos[ this.undos.length - 1 ] : null;	// next cmd to pop

		if ( cmd == null || id > cmd.id ) {
			cmd = this.redo();
			while ( cmd != null && id > cmd.id ) {
				cmd = this.redo();
			}
		} 
    else {
			while ( true ) {
				cmd = this.undos[ this.undos.length - 1 ];	// next cmd to pop
				if ( cmd == null || id == cmd.id ) break;
				this.undo();
			}
		}

		this.editor.signals.sceneGraphChanged.active = true;
		this.editor.signals.historyChanged.active = true;

		this.editor.signals.sceneGraphChanged.dispatch();
		this.editor.signals.historyChanged.dispatch( cmd );
	}

	void enableSerialization( id ) {
		/**
		 * because there might be commands in this.undos and this.redos
		 * which have not been serialized with .toJSON() we go back
		 * to the oldest command and redo one command after the other
		 * while also calling .toJSON() on them.
		 */

		this.goToState( - 1 );

		this.editor.signals.sceneGraphChanged.active = false;
		this.editor.signals.historyChanged.active = false;

		dynamic cmd = this.redo();
		while ( cmd != null ) {
			if ( ! cmd.hasOwnProperty( 'json' ) ) {
				cmd.json = cmd.toJSON();
			}

      try {
        // Attempt to access the property
        cmd.json = cmd.toJSON();
      }catch(e){}

			cmd = this.redo();
		}

		this.editor.signals.sceneGraphChanged.active = true;
		this.editor.signals.historyChanged.active = true;

		this.goToState( id );
	}
}
