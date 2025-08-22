import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';
import 'commands.dart';

class AddObjectCommand extends Command {
  Object3D? object;

	/**
	 * @param {Editor} editor
	 * @param {THREE.Object3D|null} [object=null]
	 * @constructor
	 */
	AddObjectCommand(Editor editor, [this.object]):super(editor) {
		this.type = 'AddObjectCommand';

		if ( object != null ) {
			this.name = editor.strings.getKey( 'command/AddObject' ) + ': ' + object!.name;
		}
	}

	void execute() {
		if(object != null) this.editor.addObject( object! );
		this.editor.select( this.object );
	}

	void undo() {
		if(object != null) this.editor.removeObject( this.object! );
		this.editor.deselect();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();
		output['object'] = this.object?.toJson();
		return output;
	}

  @override
	Future<void> fromJson(Map<String,dynamic> json ) async{
    super.fromJson( json );
		this.object = this.editor.objectByUuid( json['object'].object.uuid );

		if ( this.object == null ) {
			final loader = ObjectLoader();
			this.object = await loader.fromBytes(Uint8List.fromList(jsonEncode(json['object']).codeUnits));
		}
	}
}