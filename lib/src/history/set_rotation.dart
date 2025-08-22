import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class SetRotationCommand extends Command {
  Object3D? object;
  Euler? newRotation;
  Euler? oldRotation;
  Euler? optionalOldRotation;

	SetRotationCommand(super.editor, [this.object, this.newRotation, this.optionalOldRotation]) {
		this.type = 'SetRotationCommand';
		this.name = editor.strings.getKey( 'command/SetRotation' );
		this.updatable = true;

		if ( object != null && newRotation != null ) {
			this.oldRotation = object?.rotation.clone();
			this.newRotation = newRotation?.clone();
		}

		if ( optionalOldRotation != null ) {
			this.oldRotation = optionalOldRotation?.clone();
		}
	}

	void execute() {
		this.object?.rotation.copy( this.newRotation! );
		this.object?.updateMatrixWorld( true );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void undo() {
		this.object?.rotation.copy( this.oldRotation !);
		this.object?.updateMatrixWorld( true );
		this.editor.signals.objectChanged.dispatch( this.object );
	}

	void update( command ) {
		this.newRotation?.copy( command.newRotation );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();
		output['objectUuid'] = this.object?.uuid;
		output['oldRotation'] = this.oldRotation?.toArray();
		output['newRotation'] = this.newRotation?.toArray();

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.oldRotation = new Euler().fromArray( json['oldRotation'] );
		this.newRotation = new Euler().fromArray( json['newRotation'] );
	}
}
