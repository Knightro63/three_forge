import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetScaleCommand extends Command {
  Object3D? object;
  Vector3? newScale;
  Vector3? optionalOldScale;
  Vector3? oldScale;

	SetScaleCommand(super.editor, [this.object,this.newScale,this.optionalOldScale]) {
		this.type = 'SetScaleCommand';
		this.name = editor.strings.getKey( 'command/SetScale' );
		this.updatable = true;

		if ( object != null && newScale != null ) {
			this.oldScale = object?.scale.clone();
			this.newScale = newScale?.clone();
		}

		if ( optionalOldScale != null ) {
			this.oldScale = optionalOldScale?.clone();
		}
	}

	void execute() {
		this.object?.scale.setFrom( this.newScale! );
		this.object?.updateMatrixWorld( true );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void undo() {
		this.object?.scale.setFrom( this.oldScale! );
		this.object?.updateMatrixWorld( true );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void update( command ) {
		this.newScale?.setFrom( command.newScale );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();
		output['objectUuid'] = this.object?.uuid;
		output['oldScale'] = this.oldScale?.toList();
		output['newScale'] = this.newScale?.toList();

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.oldScale = new Vector3().copyFromArray( json['oldScale'] );
		this.newScale = new Vector3().copyFromArray( json['newScale'] );
	}
}
