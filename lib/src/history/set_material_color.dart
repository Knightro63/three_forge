import "package:three_forge/src/history/commands.dart";
import "package:three_js/three_js.dart";


class SetMaterialColorCommand extends Command {
  Object3D? object;
  String? newValue;
  String? oldValue;
  int materialSlot;

	/**
	 * @param {Editor} editor
	 * @param {THREE.Object3D|null} [object=null]
	 * @param {string} attributeName
	 * @param {?number} [newValue=null] Integer representing a hex color value
	 * @param {number} [materialSlot=-1]
	 * @constructor
	 */
	SetMaterialColorCommand(super.editor, [this.object = null, String attributeName = '', this.newValue = null, this.materialSlot = - 1 ]) {
		this.attributeName = attributeName;
    this.type = 'SetMaterialColorCommand';
		this.name = editor.strings.getKey( 'command/SetMaterialColor' ) + ': ' + attributeName;
		this.updatable = true;

		this.object = object;
		this.materialSlot = materialSlot;

		final material = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;

		this.oldValue = ( material != null ) ?( material[ attributeName ]?.getHex()) : null;
		this.newValue = newValue;

		this.attributeName = attributeName;
	}

	void execute() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );
		material?[ this.attributeName ].setHex( this.newValue );
		this.editor.signals.materialChanged.dispatch( [this.object, this.materialSlot] );
	}

	void undo() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );
		material?[ this.attributeName ].setHex( this.oldValue );
		this.editor.signals.materialChanged.dispatch([ this.object, this.materialSlot ]);
	}

  @override
	void update(Command cmd) {
		this.newValue = (cmd as SetMaterialColorCommand).newValue;
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

		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.attributeName = json['attributeName'];
		this.oldValue = json['oldValue'];
		this.newValue = json['newValue'];
		this.materialSlot = json['materialSlot'];
	}
}
