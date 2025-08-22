import 'package:three_forge/src/history/command.dart';
import 'package:three_js/three_js.dart';

class MoveObjectCommand extends Command {
  Object3D? object;
  Object3D? newParent;
  Object3D? oldParent;
  Object3D? newBefore;

  int? newIndex;
  int? oldIndex;

	MoveObjectCommand(super.editor, [this.object = null, this.newParent = null, this.newBefore = null ]){
		this.type = 'MoveObjectCommand';
		this.name = editor.strings.getKey( 'command/MoveObject' );

		this.oldParent = ( object != null ) ? object?.parent : null;
		this.oldIndex = ( this.oldParent != null ) ? this.oldParent?.children.indexOf( this.object! ) : null;
		this.newParent = newParent;

		if ( newBefore != null ) {
			this.newIndex = ( newParent != null ) ? newParent?.children.indexOf( newBefore! ) : null;
		} 
    else {
			this.newIndex = ( newParent != null ) ? newParent?.children.length : null;
		}

		if ( this.oldParent == this.newParent && (this.newIndex ?? 0) > (this.oldIndex ?? 0) ) {
			this.newIndex = this.newIndex! - 1;
		}

		this.newBefore = newBefore;
	}

	void execute() {
		this.oldParent?.remove( this.object! );

		final children = this.newParent?.children;
		children?.insert(newIndex ?? 0, object!);//.splice( this.newIndex, 0, this.object );
		this.object?.parent = this.newParent;

		this.object?.dispatchEvent(Event( type: 'added' ));
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.objectChanged.dispatch( this.newParent );
		this.editor.signals.objectChanged.dispatch( this.oldParent );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

	void undo() {
		this.newParent?.remove( this.object! );

		final children = this.oldParent?.children;
		children?.insert(oldIndex ?? 0, object!);//.splice( this.oldIndex, 0, this.object );
		this.object?.parent = this.oldParent;

		this.object?.dispatchEvent( Event( type: 'added' ));
		this.editor.signals.objectChanged.dispatch( this.object );
		this.editor.signals.objectChanged.dispatch( this.newParent );
		this.editor.signals.objectChanged.dispatch( this.oldParent );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['newParentUuid'] = this.newParent?.uuid;
		output['oldParentUuid'] = this.oldParent?.uuid;
		output['newIndex'] = this.newIndex;
		output['oldIndex'] = this.oldIndex;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.oldParent = this.editor.objectByUuid( json['oldParentUuid'] );
		if ( this.oldParent == null ) {
			this.oldParent = this.editor.scene;
		}

		this.newParent = this.editor.objectByUuid( json['newParentUuid'] );

		if ( this.newParent == null ) {
			this.newParent = this.editor.scene;
		}

		this.newIndex = json['newIndex'];
		this.oldIndex = json['oldIndex'];
	}
}