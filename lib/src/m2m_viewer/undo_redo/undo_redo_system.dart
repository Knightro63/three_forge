import 'package:three_forge/src/m2m_viewer/interfaces/bone_transform_state.dart';
import 'package:three_forge/src/m2m_viewer/src/utilities.dart';
import 'package:three_js_core/three_js_core.dart';

class UndoRedoStateChangedEvent extends Event{
  final Map<String, dynamic> detail;
  UndoRedoStateChangedEvent(String type, {required this.detail}){
    this.type = type;
  }
}

/// UndoRedoSystem
/// Manages undo/redo functionality for skeleton bone transformations
/// Stores states and allows reverting to previous states
class UndoRedoSystem with EventDispatcher {
  List<List<BoneTransformState>> undoStack = [];
  List<List<BoneTransformState>> redoStack = [];
  int maxHistorySize = 50;
  Skeleton? skeletonRef;

  UndoRedoSystem([this.maxHistorySize = 50]);

  /// Set the skeleton reference that this undo/redo system will operate on
  void setSkeleton(Skeleton skeleton) {
    skeletonRef = skeleton;
    clearHistory();
  }

  /// Store the current state of all bones in the skeleton
  /// This should be called before making any changes to bones
  void storeCurrentState() {
    if (skeletonRef == null) {
      print('Cannot store undo state: skeleton reference is null');
      return;
    }
    
    final currentState = Utility.storeBoneTransforms(skeletonRef!);
    undoStack.add(currentState);

    /// If the stack exceeds the maximum size, remove the oldest state
    /// so it is a rolling history
    if (undoStack.length > maxHistorySize) {
      undoStack.removeAt(0); // Replacing JS shift() safely
    }

    // Clear redo stack when a new action is performed
    redoStack = [];
    dispatchStateChangedEvent();
  }

  /// Restore the previous state (undo)
  /// Returns true if undo was successful, false if no undo available
  bool undo() {
    if (skeletonRef == null) {
      print('Cannot undo: skeleton reference is null');
      return false;
    }
    if (undoStack.isEmpty) {
      print('No undo states available');
      return false;
    }

    // Store current state in redo stack before undoing
    final currentState = Utility.storeBoneTransforms(skeletonRef!);
    redoStack.add(currentState);

    // Get and apply the previous state
    final previousState = undoStack.removeLast(); // Replacing JS pop() safely
    Utility.restoreBoneTransforms(skeletonRef!, previousState);

    // Update world matrices for all bones explicitly typing the tracking variable
    for (int i = 0; i < skeletonRef!.bones.length; i++) {
      final bone = skeletonRef!.bones[i];
      bone.updateWorldMatrix(true, true);
    }

    dispatchStateChangedEvent();
    return true;
  }

  /// Restore the next state (redo)
  /// Returns true if redo was successful, false if no redo available
  bool redo() {
    if (skeletonRef == null) {
      print('Cannot redo: skeleton reference is null');
      return false;
    }
    if (redoStack.isEmpty) {
      print('No redo states available');
      return false;
    }

    // Store current state in undo stack before redoing
    final currentState = Utility.storeBoneTransforms(skeletonRef!);
    undoStack.add(currentState);

    // Get and apply the next state
    final nextState = redoStack.removeLast(); // Replacing JS pop() safely
    Utility.restoreBoneTransforms(skeletonRef!, nextState);

    // Update world matrices for all bones explicitly typing the tracking variable
    for (int i = 0; i < skeletonRef!.bones.length; i++) {
      final bone = skeletonRef!.bones[i];
      bone.updateWorldMatrix(true, true);
    }

    dispatchStateChangedEvent();
    return true;
  }

  /// Check if undo is available
  bool canUndo() {
    return undoStack.isNotEmpty;
  }

  /// Check if redo is available
  bool canRedo() {
    return redoStack.isNotEmpty;
  }

  /// Get the number of available undo states
  int getUndoCount() {
    return undoStack.length;
  }

  /// Get the number of available redo states
  int getRedoCount() {
    return redoStack.length;
  }

  /// Clear all undo/redo history
  void clearHistory() {
    undoStack = [];
    redoStack = [];
    dispatchStateChangedEvent();
  }

  /// Get a snapshot of the current bone transforms without storing it
  /// Useful for comparison or external storage
  List<BoneTransformState>? getCurrentStateSnapshot() {
    if (skeletonRef == null) {
      return null;
    }
    return Utility.storeBoneTransforms(skeletonRef!);
  }

  /// Restore a specific state snapshot
  /// This adds the current state to undo history before applying the snapshot
  void restoreStateSnapshot(List<BoneTransformState> stateSnapshot) {
    if (skeletonRef == null) {
      print('Cannot restore state snapshot: skeleton reference is null');
      return;
    }

    // Store current state before restoring snapshot
    storeCurrentState();

    // Apply the snapshot
    Utility.restoreBoneTransforms(skeletonRef!, stateSnapshot);

    // Update world matrices for all bones explicitly typing the tracking variable
    for (int i = 0; i < skeletonRef!.bones.length; i++) {
      final bone = skeletonRef!.bones[i];
      bone.updateWorldMatrix(true, true);
    }

    dispatchStateChangedEvent();
  }

  /// Dispatch a custom event when the undo/redo state changes
  /// This allows UI elements to update their enabled/disabled state
  void dispatchStateChangedEvent() {
    final event = UndoRedoStateChangedEvent(
      'undoRedoStateChanged',
      detail: {
        'canUndo': canUndo(),
        'canRedo': canRedo(),
        'undoCount': getUndoCount(),
        'redoCount': getRedoCount()
      },
    );
    dispatchEvent(event);
  }
}
