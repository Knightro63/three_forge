

import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class SetMaterialCommand extends Command {
  Object3D? object;
  Material? newMaterial;
  Material? oldMaterial;
  int materialSlot;

	SetMaterialCommand(super.editor, [this.object = null, this.newMaterial = null, this.materialSlot = - 1 ]) {
		this.type = 'SetMaterialCommand';
		this.name = editor.strings.getKey( 'command/SetMaterial' );

		this.oldMaterial = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;
	}

	void execute() {
		this.editor.setObjectMaterial( this.object!, this.materialSlot, this.newMaterial );
		this.editor.signals.materialChanged.dispatch( [this.object, this.materialSlot] );
	}

	void undo() {
		this.editor.setObjectMaterial( this.object!, this.materialSlot, this.oldMaterial );
		this.editor.signals.materialChanged.dispatch( [this.object, this.materialSlot] );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['oldMaterial'] = this.oldMaterial?.toJson();
		output['newMaterial'] = this.newMaterial?.toJson();
		output['materialSlot'] = this.materialSlot;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) async{
		super.fromJson( json );

    parseMaterial(Map<String,dynamic> json ) async{
			final loader = new ObjectLoader();
			final images = await loader.parseImages( json['images'] );
			final textures = loader.parseTextures( json['textures'], images );
			final materials = loader.parseMaterials( [ json ], textures );
			return materials[ json['uuid'] ];
		}

		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.oldMaterial = await parseMaterial( json['oldMaterial'] );
		this.newMaterial = await parseMaterial( json['newMaterial'] );
		this.materialSlot = json['materialSlot'];
	}
}
