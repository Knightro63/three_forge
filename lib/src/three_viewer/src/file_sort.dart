import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:three_forge/src/three_viewer/export.dart';
import 'package:three_forge/src/three_viewer/viewer.dart';
import 'package:path/path.dart' as p;
import 'package:three_js/three_js.dart' as three;

class FileSort{
  String dirPath;
  String sceneName = 'untitled';

  FileSort(this.dirPath);

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    await for (FileSystemEntity entity in source.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        File newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
        await entity.copy(newFile.path);
      } else if (entity is Directory) {
        Directory newDirectory = Directory('${destination.path}/${entity.uri.pathSegments.last}');
        await _copyDirectory(entity, newDirectory); // Recursive call for subdirectories
      }
    }
  }

  Future<void> moveTextures(List<String> paths) async{
    String destinationPath ='$dirPath/assets/textures/' ;
    bool exists = await Directory(destinationPath).exists();
    if(!exists) await Directory(destinationPath).create(recursive: true);

    for(final sourcePath in paths){
      File sourceFile = File(sourcePath);
      File destinationFile = File('$destinationPath${sourcePath.split('/').last}');

      try {
        // Check if the source file exists before attempting to copy
        if (await sourceFile.exists()) {
          await sourceFile.copy(destinationFile.path);
          three.console.info('File copied successfully from $sourcePath to $destinationPath');
        } else {
          three.console.info('Source file does not exist: $sourcePath');
        }
      } catch (e) {
        three.console.info('Error copying file: $e');
      }
    }
  }

  Future<void> moveTexture(String path) async{
    String resourcePth ='$dirPath/assets/textures' ;
    Directory sourceDir = Directory(path);
    Directory destinationDir = Directory(resourcePth);

    await for (FileSystemEntity entity in sourceDir.list(recursive: false)) {
      if (entity is File) {
        final String fileName = p.basename(entity.path);
        final String newFilePath = p.join(destinationDir.path, fileName);
        await entity.copy(newFilePath);
      }
    }
  }

  Future<void> moveFiles(String name, List<String> paths) async{
    String destinationPath ='$dirPath/assets/models/${name.split('.').first}/' ;
    bool exists = await Directory(destinationPath).exists();
    if(!exists) await Directory(destinationPath).create(recursive: true);

    for(final sourcePath in paths){
      File sourceFile = File(sourcePath);
      File destinationFile = File('$destinationPath${sourcePath.split('/').last}');

      try {
        // Check if the source file exists before attempting to copy
        if (await sourceFile.exists()) {
          await sourceFile.copy(destinationFile.path);
          three.console.info('File copied successfully from $sourcePath to $destinationPath');
        } else {
          three.console.info('Source file does not exist: $sourcePath');
        }
      } catch (e) {
        three.console.info('Error copying file: $e');
      }
    }
  }
  Future<void> moveFolder(PlatformFile file) async{
    String path ='$dirPath/assets/models/${file.name.split('.').first}/' ;
    Directory sourceDir = Directory(file.path!.replaceAll(file.path!.split('/').last, ''));
    Directory destinationDir = Directory(path);

    if (sourceDir.existsSync()) {
      await _copyDirectory(sourceDir, destinationDir);
      three.console.info('Folder copied successfully!');
    } else {
      three.console.info('Source folder does not exist.');
    }
  }
  Future<void> moveTextures1(String path, String name) async{
    String resourcePth ='$dirPath/assets/textures/$name' ;
    Directory sourceDir = Directory(path);
    Directory destinationDir = Directory(resourcePth);

    if (sourceDir.existsSync()) {
      await _copyDirectory(sourceDir, destinationDir);
      three.console.info('Folder copied successfully!');
    } else {
      three.console.info('Source folder does not exist.');
    }
  }
  Future<void> export(String name, ThreeViewer three) async{
    String path ='$dirPath/assets/scenes/';
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);

    final last = name != ''?name:three.scene.name != ''?three.scene.name:three.scene.uuid;
    final tfe = ThreeForgeExport().export(three);
    await File('$path$last.json').writeAsString(json.encode(await tfe));
  }
  Future<void> moveObjects(List<PlatformFile> files) async{
    String path ='$dirPath/assets/models/' ;
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);

    for(final file in files){
      if(file.bytes != null){
        final last = file.name;
        await File('$path$last').writeAsBytes(file.bytes!);
      }
    }
  }
  Future<void> moveObject(PlatformFile file) async{
    String path ='$dirPath/assets/models/' ;
    bool exists = await Directory(path).exists();
    if(!exists) await Directory(path).create(recursive: true);

    if(file.bytes != null){
      final last = file.name;
      await File('$path$last').writeAsBytes(file.bytes!);
    }
  }
}