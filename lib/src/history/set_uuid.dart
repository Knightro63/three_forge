import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetUuidCommand extends Command {
  String? newUuid;
  String? oldUuid;
  Object3D? object;

	SetUuidCommand(super.editor, [this.object, this.newUuid]){
		this.type = 'SetUuidCommand';
		this.name = editor.strings.getKey( 'command/SetUuid' );
		this.oldUuid = ( object != null ) ? object?.uuid : null;
	}

	void execute() {
		this.object?.uuid = this.newUuid!;
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

	void undo() {
		this.object?.uuid = this.oldUuid!;
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson( );
		output['oldUuid'] = this.oldUuid;
		output['newUuid'] = this.newUuid;
		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.oldUuid = json['oldUuid'];
		this.newUuid = json['newUuid'];
		this.object = this.editor.objectByUuid( json['oldUuid'] );

		if ( this.object == null ) {
			this.object = this.editor.objectByUuid( json['newUuid'] );
		}
	}
}
