import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class AddScriptCommand extends Command {
  String type = 'AddScriptCommand';
  Object3D? object;
  String script;

	AddScriptCommand(Editor editor, [this.object, this.script = '' ]):super(editor);

	void execute() {
		if ( this.editor.scripts[ this.object?.uuid ] == null ) {
			this.editor.scripts[ this.object!.uuid ] = [];
		}

		this.editor.scripts[ this.object?.uuid ].add( this.script );
		this.editor.signals.scriptAdded.dispatch( this.script );
	}

	void undo() {
		if ( this.editor.scripts[ this.object?.uuid ] == null ) return;
		final index = this.editor.scripts[ this.object?.uuid ].indexOf( this.script );

		if ( index != - 1 ) {
			this.editor.scripts[ this.object?.uuid ].splice( index, 1 );
		}

		this.editor.signals.scriptRemoved.dispatch( this.script );
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
