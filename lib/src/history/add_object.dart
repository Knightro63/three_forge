import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:three_js_tjs_loader/object_loader.dart';
import 'commands.dart';

class AddObjectCommand extends Command {

	AddObjectCommand(super.editor, [super.object]){
		this.type = CommandType.addObject;
	}

	void execute() {
		if(object != null) this.editor.add( object!, usingUndo: true );
		this.editor.selectPart( this.object );
	}

  @override
	void undo() {
    super.undo();
		if(object != null) this.editor.remove( this.object!,true );
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