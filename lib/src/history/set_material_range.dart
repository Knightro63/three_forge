import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";

class SetMaterialRangeCommand extends Command {
  Object3D? object;
  double? newMinValue;
  double? newMaxValue;
  double? oldMinValue;
  double? oldMaxValue;
  String attributeName;
  int materialSlot;

  List oldRange = [];
  List newRange = [];

	SetMaterialRangeCommand(super.editor, [this.object = null, this.attributeName = '', this.newMinValue = - double.infinity, this.newMaxValue = double.infinity, this.materialSlot = - 1 ]) {
		this.type = 'SetMaterialRangeCommand';
		this.name = editor.strings.getKey( 'command/SetMaterialRange' ) + ': ' + attributeName;
		this.updatable = true;

		final material = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;

		this.oldRange = ( material != null && material[ attributeName ] != null ) ? [ ...this.material[ attributeName ] ] : null;
		this.newRange = [ newMinValue, newMaxValue ];
	}

	void execute() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );

		material?[ this.attributeName ] = [ ...this.newRange ];
		material?.needsUpdate = true;

		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.materialChanged.dispatch( this.object, this.materialSlot );
	}

	void undo() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );

		material?[ this.attributeName ] = [ ...this.oldRange ];
		material?.needsUpdate = true;

		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.materialChanged.dispatch( this.object, this.materialSlot );
	}

	void update( cmd ) {
		this.newRange = [ ...cmd.newRange ];
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['attributeName'] = this.attributeName;
		output['oldRange'] = [ ...this.oldRange ];
		output['newRange'] = [ ...this.newRange ];
		output['materialSlot'] = this.materialSlot;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.attributeName = json['attributeName'];
		this.oldRange = [ ...json['oldRange'] ];
		this.newRange = [ ...json['newRange'] ];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.materialSlot = json['materialSlot'];

	}
}
