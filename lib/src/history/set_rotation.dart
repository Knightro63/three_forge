import "commands.dart";
import 'package:three_js/three_js.dart';

class SetRotationCommand extends Command {
  Euler? newRotation;
  Euler? oldRotation;
  Euler? optionalOldRotation;

	SetRotationCommand(super.editor, [super.object, this.newRotation, this.optionalOldRotation]) {
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
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.object?.rotation.copy( this.oldRotation !);
		this.object?.updateMatrixWorld( true );
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		if(cmd is SetRotationCommand && cmd.newRotation != null) this.newRotation?.copy( cmd.newRotation! );
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
