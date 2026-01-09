import 'dart:convert';

import 'package:flutter/foundation.dart';
import "commands.dart";
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class RemoveObjectCommand extends Command {
  Object3D? parent;
	int? index;

	RemoveObjectCommand(super.editor, [super.object]) {
		this.parent = ( object != null ) ? object?.parent : null;

		if ( this.parent != null ) {
			this.index = this.parent?.children.indexOf( this.object! );
		}
	}

	void execute() {
		this.editor.remove( this.object!, true);
		this.editor.deselect();
	}

  @override
	void undo() {
    super.undo();
		this.editor.add( this.object!, parent: this.parent, index: this.index, usingUndo: true );
		this.editor.selectPart( this.object );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['object'] = this.object?.toJson();
		output['index'] = this.index;
		output['parentUuid'] = this.parent?.uuid;

		return output;

	}

  @override
	Future<void> fromJson(Map<String,dynamic> json ) async{
		super.fromJson( json );

		this.parent = this.editor.objectByUuid( json['parentUuid'] );
		if ( this.parent == null ) {
			this.parent = this.editor.scene;
		}

		this.index = json['index'];

		this.object = this.editor.objectByUuid( json['object'].object.uuid );

		if ( this.object == null ) {
			final loader = ObjectLoader();
			this.object = await loader.fromBytes(Uint8List.fromList(jsonEncode(json['object']).codeUnits));
		}
	}
}
