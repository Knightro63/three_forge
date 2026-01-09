

import "commands.dart";
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class SetMaterialCommand extends Command {
  Material? newMaterial;
  Material? oldMaterial;
  int materialSlot;

	SetMaterialCommand(super.editor, [super.object = null, this.newMaterial = null, this.materialSlot = - 1 ]) {
		this.oldMaterial = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;
	}

	void execute() {
		this.editor.setObjectMaterial( this.object!, this.materialSlot, this.newMaterial );
		this.editor.dispatch();
	}

  @override
	void undo() {
    super.undo();
		this.editor.setObjectMaterial( this.object!, this.materialSlot, this.oldMaterial );
		this.editor.dispatch();
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
