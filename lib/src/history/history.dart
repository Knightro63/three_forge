import 'commands.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';

class History {
  ThreeViewer viewer;
  List<Command> undos = [];
  List<Command> redos = [];
  int lastCmdTime = DateTime.now().millisecondsSinceEpoch;
  int idCounter = 0;

  History(this.viewer);

	void execute(Command cmd) {
		final lastCmd = this.undos.isNotEmpty ? this.undos.last : null;
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

		//cmd.execute();
    if(cmd.allowDispatch) viewer.dispatch();
		cmd.inMemory = true;

		// if ( this.config.getKey( 'settings/history' ) ) {
		// 	cmd.json = cmd.toJson();	// serialize the cmd immediately after execution and append the json to the cmd
		// }

		this.lastCmdTime = DateTime.now().millisecondsSinceEpoch;

		// clearing all the redo-commands
		this.redos = [];
	}

	Command? undo() {
		Command? cmd;

		if ( this.undos.isNotEmpty ) {
			cmd = this.undos.removeLast();
			if ( cmd.inMemory == false ) {
				cmd.fromJson( cmd.json );
			}
		}

		if ( cmd != null ) {
      cmd.onUndoDone?.call();
			cmd.undo();
			this.redos.add( cmd );
		}

		return cmd;
	}

	Command? redo() {
		Command? cmd;

		if ( this.redos.isNotEmpty ) {
			cmd = this.redos.removeLast();
			if ( cmd.inMemory == false ) {
				cmd.fromJson( cmd.json );
			}
		}

		if ( cmd != null ) {
      cmd.onRedoDone?.call();
			cmd.execute();
			this.undos.add( cmd );
		}

		return cmd;
	}

	Map<String, dynamic> toJson() {
		final Map<String, List> history = {};
		history['undos'] = [];
		history['redos'] = [];

		// Append Undos to History
		for (int i = 0; i < this.undos.length; i ++ ) {
			history['undos']!.add( this.undos[ i ].json );
		}

		// Append Redos to History
		for (int i = 0; i < this.redos.length; i ++ ) {
			history['redos']!.add( this.redos[ i ].json );
		}

		return history;
	}

	void fromJson(Map<String, List>? json ) {
		if ( json == null ) return;
		for (int i = 0; i < json['undos']!.length; i ++ ) {
			final cmdJSON = json['undos']![ i ] as Map<String,dynamic>;
			final cmd = Command.createCommand(cmdJSON['type'], viewer);//Commands[ cmdJSON.type ]( this.editor ); // creates a new object of type "json.type"
			cmd.json = cmdJSON;
			cmd.id = cmdJSON['id'];
			this.undos.add( cmd );
			this.idCounter = ( cmdJSON['id'] > this.idCounter ) ? cmdJSON['id'] : this.idCounter; // set last used idCounter
		}

		for (int i = 0; i < json['redos']!.length; i ++ ) {
			final cmdJSON = json['redos']![ i ] as Map<String,dynamic>;
			final cmd = Command.createCommand(cmdJSON['type'], viewer);//Commands[ cmdJSON.type ]( this.editor ); // creates a new object of type "json.type"
			cmd.json = cmdJSON;
			cmd.id = cmdJSON['id'];
			this.redos.add( cmd );
			this.idCounter = ( cmdJSON['id'] > this.idCounter ) ? cmdJSON['id'] : this.idCounter; // set last used idCounter
		}
	}

	void clear() {
		this.undos = [];
		this.redos = [];
		this.idCounter = 0;
	}

	void goToState(int id ) {
		Command? cmd = this.undos.isNotEmpty ? this.undos[ this.undos.length - 1 ] : null;	// next cmd to pop

		if ( cmd == null || id > cmd.id ) {
			cmd = this.redo();
			while ( cmd != null && id > cmd.id ) {
				cmd = this.redo();
			}
		} 
    else {
			while ( true ) {
				cmd = this.undos[ this.undos.length - 1 ];	// next cmd to pop
				if ( id == cmd.id ) break;
				this.undo();
			}
		}
	}

	void enableSerialization(int id ) {
		this.goToState( - 1 );

		Command? cmd = this.redo();
		while ( cmd != null ) {
      try {
        // Attempt to access the property
        cmd.json = cmd.toJson();
      }catch(e){}

			cmd = this.redo();
		}

		this.goToState( id );
	}

  String get undoString{
    String history = '';
    for(final cmd in undos){
      history += '  [${cmd.id}] ${cmd.name}\n';
    }
    return history;
  }
  String get redoString {
    String history = '';
    for(final cmd in redos){
      history += '  [${cmd.id}] ${cmd.name}\n';
    }
    return history;
  }
  String toString(){
    String history = '';
    history += 'Undos:\n';
    for(final cmd in undos){
      history += '  [${cmd.id}] ${cmd.name}\n';
    }
    history += 'Redos:\n';
    for(final cmd in redos){
      history += '  [${cmd.id}] ${cmd.name}\n';
    }
    return history;
  }
}