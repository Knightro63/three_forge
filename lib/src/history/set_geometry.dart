import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class SetGeometryCommand extends Command {
  Object3D? object;
  BufferGeometry? newGeometry;
  BufferGeometry? oldGeometry;

	SetGeometryCommand(super.editor,[this.object, this.newGeometry]) {
		this.type = 'SetGeometryCommand';
		this.name = editor.strings.getKey( 'command/SetGeometry' );
		this.updatable = true;

		this.oldGeometry = ( object != null ) ? object?.geometry : null;
	}

	void execute() {
		this.object?.geometry?.dispose();
		this.object?.geometry = this.newGeometry;
		this.object?.geometry?.computeBoundingSphere();

		this.editor.signals.geometryChanged.dispatch( this.object );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

	void undo() {
		this.object?.geometry?.dispose();
		this.object?.geometry = this.oldGeometry;
		this.object?.geometry?.computeBoundingSphere();

		this.editor.signals.geometryChanged.dispatch( this.object );
		this.editor.signals.sceneGraphChanged.dispatch();
	}

  @override
	void update(Command cmd) {
		this.newGeometry = (cmd as SetGeometryCommand).newGeometry;
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		output['objectUuid'] = this.object?.uuid;
		output['oldGeometry'] = this.oldGeometry?.toJson();
		output['newGeometry'] = this.newGeometry?.toJson();

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		parseGeometry( data ) {
			final loader = new ObjectLoader();
			return loader.parseGeometries( [ data ], null)[ data.uuid ];
		}

		this.object = this.editor.objectByUuid( json['objectUuid'] );

		this.oldGeometry = parseGeometry( json['oldGeometry'] );
		this.newGeometry = parseGeometry( json['newGeometry'] );
	}
}
