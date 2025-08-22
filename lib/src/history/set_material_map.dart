import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class SetMaterialMapCommand extends Command {
  Object3D? object;
  Texture? newMap;
  Texture? oldMap;
  String mapName;
  int materialSlot;

	SetMaterialMapCommand(super.editor, [this.object, this.mapName = '', this.newMap, this.materialSlot = - 1 ]) {
		this.type = 'SetMaterialMapCommand';
		this.name = editor.strings.getKey( 'command/SetMaterialMap' ) + ': ' + mapName;

		final material = ( object != null ) ? editor.getObjectMaterial( object!, materialSlot ) : null;
		this.oldMap = ( object != null ) ? material[ mapName ] : null;
	}

	void execute() {
		if ( this.oldMap != null && this.oldMap != null ) this.oldMap?.dispose();

		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );

		material[ this.mapName ] = this.newMap;
		material?.needsUpdate = true;

		this.editor.signals.materialChanged.dispatch( this.object, this.materialSlot );
	}

	void undo() {
		final material = this.editor.getObjectMaterial( this.object!, this.materialSlot );
		material?[ this.mapName ] = this.oldMap;
		material?.needsUpdate = true;
		this.editor.signals.materialChanged.dispatch( this.object, this.materialSlot );
	}

  @override
	Map<String,dynamic> toJson() {
		final output = super.toJson();

		extractFromCache( cache ) {
			final List values = [];
			for ( final key in cache ) {
				final Map data = cache[ key ];
				data.remove('metadat');
				values.add( data );
			}

			return values;
		}

		serializeMap(Texture? map ) {
			if (map == null) return null;

			final Map<String,dynamic> meta = {
				'geometries': {},
				'materials': {},
				'textures': {},
				'images': {}
			};

			final Map<String,dynamic> json = map.toJson( meta );
			final images = extractFromCache( meta['images'] );
			if ( images.length > 0 ) json['images'] = images;
			json['sourceFile'] = map.userData['sourceFile'];

			return json;
		}

		output['objectUuid'] = this.object?.uuid;
		output['mapName'] = this.mapName;
		output['newMap'] = serializeMap( this.newMap );
		output['oldMap'] = serializeMap( this.oldMap );
		output['materialSlot'] = this.materialSlot;

		return output;
	}

  @override
	void fromJson(Map<String,dynamic> json ) {
		super.fromJson( json );

		parseTexture(Map<String,dynamic>? json ) {
			Texture? map = null;
			if ( json != null ) {
				final loader = new ObjectLoader();
				final images = loader.parseImages( json['images'] );
				final textures = loader.parseTextures( [ json ], images );
				map = textures[ json['uuid'] ];
				map?.userData['sourceFile'] = json['sourceFile'];
			}
			return map;
		}

		this.object = this.editor.objectByUuid( json['objectUuid'] );
		this.mapName = json['mapName'];
		this.oldMap = parseTexture( json['oldMap'] );
		this.newMap = parseTexture( json['newMap'] );
		this.materialSlot = json['materialSlot'];
	}
}
