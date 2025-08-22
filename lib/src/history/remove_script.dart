import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class RemoveScriptCommand extends Command {
  Object3D? object;
  String script;
  int? index;

	RemoveScriptCommand(super.editor, [this.object, this.script = '']) {
		this.type = 'RemoveScriptCommand';
		this.name = editor.strings.getKey( 'command/RemoveScript' );

		if ( this.object != null && this.script != '' ) {
			this.index = this.editor.scripts[ this.object!.uuid ].indexOf( this.script );
		}
	}

	void execute() {
		if ( this.editor.scripts[ this.object!.uuid ] == null ) return;

		if ( this.index != - 1 ) {
			this.editor.scripts[ this.object!.uuid ].splice( this.index, 1 );
		}

		this.editor.signals.scriptRemoved.dispatch( this.script );
	}

	void undo() {
		if ( this.editor.scripts[ this.object!.uuid ] == null ) {
			this.editor.scripts[ this.object!.uuid ] = [];
		}

		this.editor.scripts[ this.object!.uuid ].splice( this.index, 0, this.script );
		this.editor.signals.scriptAdded.dispatch( this.script );
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
