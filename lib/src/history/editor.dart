import 'dart:convert';

import 'package:three_forge/src/styles/config.dart';
import 'package:three_forge/src/history/history.dart';
import 'package:three_forge/src/history/selector.dart';
import 'package:three_forge/src/styles/language.dart';
import 'package:three_forge/src/signal/signal.dart';
import 'package:three_js/three_js.dart';
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_tjs_loader/object_loader.dart';

class Signals{
  final editScript = new Signal();

  // player

  final startPlayer = new Signal();
  final stopPlayer = new Signal();

  // xr

  final enterXR = new Signal();
  final offerXR = new Signal();
  final leaveXR = new Signal();

  // notifications

  final editorCleared = new Signal();

  final savingStarted = new Signal();
  final savingFinished = new Signal();

  final transformModeChanged = new Signal();
  final snapChanged = new Signal();
  final spaceChanged = new Signal();
  final rendererCreated = new Signal();
  final rendererUpdated = new Signal();
  final rendererDetectKTX2Support = new Signal();

  final sceneBackgroundChanged = new Signal();
  final sceneEnvironmentChanged = new Signal();
  final sceneFogChanged = new Signal();
  final sceneFogSettingsChanged = new Signal();
  final sceneGraphChanged = new Signal();
  final sceneRendered = new Signal();

  final cameraChanged = new Signal();
  final cameraResetted = new Signal();

  final geometryChanged = new Signal();

  final objectSelected = new Signal();
  final objectFocused = new Signal();

  final objectAdded = new Signal();
  final objectChanged = new Signal();
  final objectRemoved = new Signal();

  final cameraAdded = new Signal();
  final cameraRemoved = new Signal();

  final helperAdded = new Signal();
  final helperRemoved = new Signal();

  final materialAdded = new Signal();
  final materialChanged = new Signal();
  final materialRemoved = new Signal();

  final scriptAdded = new Signal();
  final scriptChanged = new Signal();
  final scriptRemoved = new Signal();

  final windowResize = new Signal();

  final showHelpersChanged = new Signal();
  final refreshSidebarObject3D = new Signal();
  final refreshSidebarEnvironment = new Signal();
  final historyChanged = new Signal();

  final viewportCameraChanged = new Signal();
  final viewportShadingChanged = new Signal();

  final intersectionsDetected = new Signal();

  final pathTracerUpdated = new Signal();
}

class Editor{
  Editor(){
    camera = PerspectiveCamera().copy(_DEFAULT_CAMERA);
    addCamera( this.camera );
    viewportCamera = this.camera;
    history = History( this );
    selector = Selector( this );
    strings = Strings( this.config );
  }

	final signals = Signals();
  final PerspectiveCamera _DEFAULT_CAMERA = PerspectiveCamera( 50, 1, 0.01, 1000 )
  ..name = 'Camera'
  ..position.setValues( 0, 5, 10 )
  ..lookAt(Vector3() );

  Scene scene = Scene()..name = 'Scene';
	Config config = new Config();
	late History history;
	late Selector selector;
	//Storage storage = Storage();
	late Strings strings;

	//Loader loader = Loader( this );

	late Camera camera;

	Scene sceneHelpers = Scene()..add(HemisphereLight( 0xffffff, 0x888888, 2 ) );

	Map<String,dynamic> object = {};
	Map<String,dynamic> geometries = {};
	Map<String,dynamic> materials = {};
	Map<String,dynamic> textures = {};
	Map<String,dynamic> scripts = {};
  Map<String,dynamic> animations = {};
	List<Material> materialsRefCounter = []; // tracks how often is a material used by a 3D object

	late AnimationMixer mixer = AnimationMixer( this.scene );

	Object3D? selected;
	Map<int,dynamic> helpers = {};
	Map<String,dynamic> cameras = {};

	late Camera viewportCamera;
	String viewportShading = 'default';

  void setScene(Scene scene ) {
		this.scene.uuid = scene.uuid;
		this.scene.name = scene.name;

		this.scene.background = scene.background;
		this.scene.environment = scene.environment;
		this.scene.fog = scene.fog;
		this.scene.backgroundBlurriness = scene.backgroundBlurriness;
		this.scene.backgroundIntensity = scene.backgroundIntensity;

		this.scene.userData = json.decode( json.encode( scene.userData ) );

		// avoid render per object

		this.signals.sceneGraphChanged.active = false;

		while ( scene.children.length > 0 ) {
			this.addObject( scene.children[ 0 ] );
		}

		this.signals.sceneGraphChanged.active = true;
		this.signals.sceneGraphChanged.dispatch();
	}

	//

	void addObject(Object3D object, [Object3D? parent, int? index ]) {
		object.traverse(( child ) {
			if ( child.geometry != null ) addGeometry( child.geometry! );
			if ( child.material != null ) addMaterial( child.material! );

			if(child is Camera) addCamera( child );
			addHelper( child );
		} );

		if ( parent == null ) {
			this.scene.add( object );
		} 
    else {
			parent.children.insert(index ?? 0, object);//.splice( index, 0, object );
			object.parent = parent;
		}

		this.signals.objectAdded.dispatch( object );
		this.signals.sceneGraphChanged.dispatch();
	}

	void nameObject(Object3D object, String name ) {
		object.name = name;
		this.signals.sceneGraphChanged.dispatch();
	}

	void removeObject(Object3D object ) {
		if ( object.parent == null ) return; // avoid deleting the camera or scene

		var scope = this;

		object.traverse(( child ) {
			if(child is Camera) scope.removeCamera( child );
			scope.removeHelper( child );
			if ( child.material != null ) scope.removeMaterial( child.material! );
		} );

		object.parent?.remove( object );

		this.signals.objectRemoved.dispatch( object );
		this.signals.sceneGraphChanged.dispatch();
	}

	void addGeometry(BufferGeometry geometry ) {
		this.geometries[ geometry.uuid ] = geometry;
	}

	void setGeometryName(BufferGeometry geometry, String name ) {
		geometry.name = name;
		this.signals.sceneGraphChanged.dispatch();
	}

	void addMaterial(Material material ) {
		if (material is GroupMaterial) {
			for (int i = 0, l = material.children.length; i < l; i ++ ) {
				this.addMaterialToRefCounter( material.children[ i ] );
			}

		} 
    else {
			this.addMaterialToRefCounter( material );
		}

		this.signals.materialAdded.dispatch();
	}

	void addMaterialToRefCounter(Material material ) {
		var materialsRefCounter = this.materialsRefCounter;
		int count = materialsRefCounter.indexOf( material );

		if ( count == -1) {
			materialsRefCounter[1] = material;
			this.materials[ material.uuid ] = material;
		} 
    else {
			count ++;
			materialsRefCounter[count] = material;
		}
	}

	void removeMaterial(Material material ) {
		if (material is GroupMaterial) {
			for ( var i = 0, l = material.children.length; i < l; i ++ ) {
				this.removeMaterialFromRefCounter( material.children[ i ] );
			}
		} 
    else {
			this.removeMaterialFromRefCounter( material );
		}

		this.signals.materialRemoved.dispatch();
	}

	void removeMaterialFromRefCounter(Material material ) {
		var materialsRefCounter = this.materialsRefCounter;
		int count = materialsRefCounter.indexOf( material );
		count --;

		if ( count == 0 ) {
			materialsRefCounter.remove( material );
			this.materials.remove( material.uuid );
		} 
    else {
			materialsRefCounter[count] = material;
		}
	}

	Material? getMaterialById(int id ) {
		Material? material;
		List<Material> materials = this.materials.values.toList() as List<Material>;

		for (int i = 0; i < materials.length; i ++ ) {
			if ( materials[ i ].id == id ) {
				material = materials[ i ];
				break;
			}
		}

		return material;
	}

	void setMaterialName( material, name ) {
		material.name = name;
		this.signals.sceneGraphChanged.dispatch();
	}

	void addTexture( texture ) {
		this.textures[ texture.uuid ] = texture;
	}

	//

	void addCamera(Camera camera ) {
    this.cameras[ camera.uuid ] = camera;
    this.signals.cameraAdded.dispatch( camera );
	}

	void removeCamera(Camera camera ) {
		if ( this.cameras[ camera.uuid ] != null ) {
			this.cameras.remove(camera.uuid);
			this.signals.cameraRemoved.dispatch( camera );
		}
	}

	//

	addHelper(Object3D object, [Object3D? helper ]) {
    if ( helper == null ) {
      if ( object is Camera ) {
        helper = CameraHelper( object );
      } 
      else if ( object is PointLight ) {
        helper = PointLightHelper( object, 1 );
      } 
      else if ( object is DirectionalLight ) {
        helper = DirectionalLightHelper( object, 1 );
      } 
      else if ( object is SpotLight ) {
        helper = SpotLightHelper( object );
      } 
      else if ( object is HemisphereLight ) {
        helper = HemisphereLightHelper( object, 1 );
      } 
      else if ( object is SkinnedMesh ) {
        helper = SkeletonHelper( object.skeleton!.bones[ 0 ] );
      } 
      else if ( object is Bone && object.parent != null && object.parent is! Bone) {
        helper = SkeletonHelper( object );
      } 
      else {
        // no helper for this object type
        return;
      }

      final picker = Mesh( SphereGeometry( 2, 4, 2 ),  MeshBasicMaterial.fromMap( { 'color': 0xff0000, 'visible': false } ) );
      picker.name = 'picker';
      picker.userData['object'] = object;
      helper.add( picker );

    }

    this.sceneHelpers.add( helper );
    this.helpers[ object.id ] = helper;

    this.signals.helperAdded.dispatch( helper );
	}

	void removeHelper(Object3D object ) {
		if ( this.helpers[ object.id ] != null ) {
			var helper = this.helpers[ object.id ];
			helper.parent.remove( helper );
			helper.dispose();

			this.helpers.remove(object.id);
			this.signals.helperRemoved.dispatch( helper );
		}
	}

	//

	void addScript( object, script ) {
		if ( this.scripts[ object.uuid ] == null ) {
			this.scripts[ object.uuid ] = [];
		}

		this.scripts[ object.uuid ].push( script );
		this.signals.scriptAdded.dispatch( script );
	}

	void removeScript(Object3D object, script ) {
		if ( this.scripts[ object.uuid ] == null ) return;

		var index = this.scripts[ object.uuid ].indexOf( script );

		if ( index != - 1 ) {
			this.scripts[ object.uuid ].splice( index, 1 );
		}

		this.signals.scriptRemoved.dispatch( script );
	}

	Material? getObjectMaterial(Object3D object, [int? slot ]) {
		Material? material = object.material;

		if (material is GroupMaterial && slot != null ) {
			material = material.children[ slot ];
		}

		return material;
	}

	void setObjectMaterial(Object3D object, int? slot, newMaterial ) {
		if (object.material is GroupMaterial && slot != null ) {
			(object.material as GroupMaterial?)?.children[ slot ] = newMaterial;
		} 
    else {
			object.material = newMaterial;
		}
	}

	void setViewportCamera(String uuid ) {
		this.viewportCamera = this.cameras[ uuid ];
		this.signals.viewportCameraChanged.dispatch();
	}

	void setViewportShading(String value ) {
		this.viewportShading = value;
		this.signals.viewportShadingChanged.dispatch();
	}

	//

	void select( object ) {
		this.selector.select( object );
	}

	void selectById(int id ) {
		if ( id == this.camera.id ) {
			this.select( this.camera );
			return;
		}

		this.select( this.scene.getObjectById( id.toString()  ) );
	}

	void selectByUuid(String uuid ) {
		var scope = this;

		this.scene.traverse(( child ) {
			if ( child.uuid == uuid ) {
				scope.select( child );
			}
		} );
	}

	void deselect() {
		this.selector.deselect();
	}

	void focus(Object3D? object ) {
		if ( object != null ) {
			this.signals.objectFocused.dispatch( object );
		}
	}

	void focusById(int id ) {
		this.focus( this.scene.getObjectById( id.toString() ) );
	}

	void clear() {
		this.history.clear();
		//this.storage.clear();

		this.camera.copy( _DEFAULT_CAMERA );
		this.signals.cameraResetted.dispatch();

		this.scene.name = 'Scene';
		this.scene.userData = {};
		this.scene.background = null;
		this.scene.environment = null;
		this.scene.fog = null;

		var objects = this.scene.children;

		this.signals.sceneGraphChanged.active = false;

		while ( objects.length > 0 ) {

			this.removeObject( objects[ 0 ] );

		}

		this.signals.sceneGraphChanged.active = true;

		this.geometries = {};
		this.materials = {};
		this.textures = {};
		this.scripts = {};

		this.materialsRefCounter.clear();

		this.animations = {};
		this.mixer.stopAllAction();

		this.deselect();

		this.signals.editorCleared.dispatch();
	}

	//
	Future<void> fromJson (Map<String,dynamic> json ) async{
		var loader = ObjectLoader();
		var camera = await loader.fromMap( json['camera'] );

		final existingUuid = this.camera.uuid;
		final incomingUuid = camera.uuid;

		// copy all properties, including uuid
		this.camera.copy( camera );
		this.camera.uuid = incomingUuid;

		this.cameras.remove(existingUuid); // remove old entry [existingUuid, this.camera]
		this.cameras[ incomingUuid ] = this.camera; // add new entry [incomingUuid, this.camera]

		this.signals.cameraResetted.dispatch();

		this.history.fromJson( json['history'] );
		this.scripts = json['scripts'];

		this.setScene( await loader.fromMap( json['scene'] ) );

		if ( json['environment'] == 'Room' ||
			 json['environment'] == 'ModelViewer' /* DEPRECATED */ ) {

			this.signals.sceneEnvironmentChanged.dispatch( json['environment'] );
			this.signals.refreshSidebarEnvironment.dispatch();
		}
	}

	Map<String,dynamic> toJSON() {
		final scene = this.scene;
		final scripts = this.scripts;

		for (final key in scripts.keys ) {
			final script = scripts[ key ];
			if ( script.length == 0 || scene.getObjectByProperty( 'uuid', key ) == null ) {
				scripts.remove(key);
			}
		}

		String? environment = null;

		if ( this.scene.environment != null && this.scene.environment?.isRenderTargetTexture == true ) {
			environment = 'Room';
		}

		return {
			'metadata': {},
			'project': {
				'shadows': this.config.getKey( 'project/renderer/shadows' ),
				'shadowType': this.config.getKey( 'project/renderer/shadowType' ),
				'toneMapping': this.config.getKey( 'project/renderer/toneMapping' ),
				'toneMappingExposure': this.config.getKey( 'project/renderer/toneMappingExposure' )
			},
			'camera': this.viewportCamera.toJson(),
			'scene': this.scene.toJson(),
			'scripts': this.scripts,
			'history': this.history.toJson(),
			'environment': environment
		};
	}

	Object3D? objectByUuid( uuid ) {
		return this.scene.getObjectByProperty( 'uuid', uuid);//, true );
	}

	void execute( cmd, optionalName ) {
		this.history.execute( cmd, optionalName );
	}

	void undo() {
	  this.history.undo();
	}

	void redo() {
		this.history.redo();
	}
}