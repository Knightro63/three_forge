import 'package:three_forge/src/history/commands.dart';
import 'package:three_js/three_js.dart';

class Selector {
  Editor editor;
  final mouse = Vector2();
  final raycaster = Raycaster();
  late Signals signals;

	Selector( this.editor ) {
		final signals = editor.signals;
		this.signals = signals;

		// signals

		signals.intersectionsDetected.add((List<Intersection> intersects ){
			if ( intersects.length > 0 ) {
				final object = intersects[ 0 ].object;

				if ( object?.userData['object'] != null ) {
					// helper
					this.select( object?.userData['object'] );
				} else {
					this.select( object );
				}
			} 
      else {
				this.select( null );
			}
		});
	}

	List<Intersection> getIntersects(Raycaster raycaster ) {
		final List<Object3D> objects = [];

		this.editor.scene.traverseVisible(( child ) {
			if(child != null) objects.add( child );
		} );

		this.editor.sceneHelpers.traverseVisible(( child ) {
			if ( child?.name == 'picker' ) objects.add( child! );
		} );

		return raycaster.intersectObjects( objects, false );
	}

	List<Intersection> getPointerIntersects(Vector point, Camera camera ) {
		mouse.setValues( ( point.x * 2 ) - 1, - ( point.y * 2 ) + 1 );
		raycaster.setFromCamera( mouse, camera );
		return this.getIntersects( raycaster );
	}

	void select(Object3D? object ) {
		if ( this.editor.selected == object ) return;

		String? uuid = null;

		if ( object != null ) {
			uuid = object.uuid;
		}

		this.editor.selected = object;
		this.editor.config.setKey({'selected': uuid!});

		this.signals.objectSelected.dispatch( object );
	}

	void deselect() {
		this.select( null );
	}
}