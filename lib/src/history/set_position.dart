import "commands.dart";
import 'package:three_js/three_js.dart';

class SetPositionCommand extends Command {
  Vector3? newPosition;
  Vector3? optionalOldPosition;
  Vector3? oldPosition;

	SetPositionCommand(super.editor, [super.object,this.newPosition,this.optionalOldPosition]) {
		this.updatable = true;

		if ( object != null && newPosition != null ) {
			this.oldPosition = object?.position.clone();
			this.newPosition = newPosition?.clone();
		}

		if ( optionalOldPosition != null ) {
			this.oldPosition = optionalOldPosition?.clone();
		}
	}

	void execute() {
		this.object?.position.setFrom( this.newPosition! );
		this.object?.updateMatrixWorld( true );
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.object?.position.setFrom( this.oldPosition! );
		this.object?.updateMatrixWorld( true );
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		if(cmd is SetPositionCommand && cmd.newPosition != null) this.newPosition?.setFrom( cmd.newPosition! );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();
		output['objectUuid'] = this.object?.uuid;
		output['oldPosition'] = this.oldPosition?.toList();
		output['newPosition'] = this.newPosition?.toList();

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.oldPosition = Vector3().copyFromArray( json['oldPosition'] );
		this.newPosition = Vector3().copyFromArray( json['newPosition'] );
	}
}
