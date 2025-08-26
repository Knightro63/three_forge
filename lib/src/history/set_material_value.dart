import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class SetMaterialValueCommand extends Command {
  Object3D? object;
  dynamic newValue;
  dynamic oldValue;
  int materialSlot;

	SetMaterialValueCommand(super.editor, [this.object = null, String attributeName = '', this.newValue ,this.materialSlot = - 1 ]) {
		this.attributeName = attributeName;
    this.type = 'SetMaterialValueCommand';
		this.name = editor.strings.getKey( 'command/SetMaterialValue' ) + ': ' + attributeName;
		this.updatable = true;

		final material = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;
		this.oldValue = ( material != null ) ? material[ attributeName ] : null;
	}

	void execute() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );

		material?[ this.attributeName! ] = this.newValue;
		material?.needsUpdate = true;

		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.materialChanged.dispatch( [this.object, this.materialSlot] );
	}

	void undo() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );

		material?[ this.attributeName! ] = this.oldValue;
		material?.needsUpdate = true;

		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.materialChanged.dispatch( [this.object, this.materialSlot] );
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetMaterialValueCommand).newValue;
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['attributeName'] = this.attributeName;
		output['oldValue'] = this.oldValue;
		output['newValue'] = this.newValue;
		output['materialSlot'] = this.materialSlot;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.attributeName = json['attributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.materialSlot = json['materialSlot'];
	}
}
