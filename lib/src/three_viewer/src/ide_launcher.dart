import 'dart:io';

class ExternalIdeLauncher {
  /// Opens a file in the user's default system editor/IDE
  static Future<void> openScriptInEditor(String scriptPath) async {
    if (Platform.isWindows) {
      // Windows standard shell open command
      await Process.run('cmd', ['/c', 'start', '', scriptPath]);
    } 
    else if (Platform.isMacOS) {
      // macOS native open command
      await Process.run('open', [scriptPath]);
    }
  }
}
