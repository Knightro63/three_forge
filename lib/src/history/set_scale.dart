import "commands.dart";
import "package:three_js/three_js.dart";

class SetScaleCommand extends Command {
  Vector3? newScale;
  Vector3? optionalOldScale;
  Vector3? oldScale;

	SetScaleCommand(super.editor, [super.object,this.newScale,this.optionalOldScale]) {
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
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.object?.scale.setFrom( this.oldScale! );
		this.object?.updateMatrixWorld( true );
		this.editor.dispatch();
	}

  @override
	void update(Command cmd) {
		if(cmd is SetScaleCommand && cmd.newScale != null) this.newScale?.setFrom( cmd.newScale! );
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
