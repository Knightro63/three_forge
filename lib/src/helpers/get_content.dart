import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> syncAndProcessAssets(String place) async {
  // Define your local Dart app workspace path
  final String localFolderPath = place;
  final String criticalFileCheck = "$localFolderPath/contents.json";

  // The GitHub URL to download your project repository as a zip
  final String githubZipUrl = "https://githubusercontent.com";
  final String zipDestinationPath = "$localFolderPath/downloaded_assets.zip";

  final File checkFile = File(criticalFileCheck);

  // 1. Check if the asset environment already exists
  if (await checkFile.exists()) {
    print("Files already exist. Skipping download.");
    return jsonDecode(await checkFile.readAsString());
  }

  print("Critical assets missing! Preparing repository download...");

  // Ensure the target directory wrapper exists
  final Directory baseDir = Directory(localFolderPath);
  if (!await baseDir.exists()) {
    await baseDir.create(recursive: true);
  }

  try {
    // 2. Stream the ZIP directly from GitHub to your folder
    print("Downloading zip archive from GitHub...");
    final http.Response response = await http.get(Uri.parse(githubZipUrl));
    if (response.statusCode != 200) {
      throw HttpException("Failed to download file from GitHub. Status code: ${response.statusCode}");
    }

    // Write the raw bytes to a temporary local zip file
    final File zipFile = File(zipDestinationPath);
    await zipFile.writeAsBytes(response.bodyBytes);
    print("Download completed successfully.");

    // 3. Decode and extract the zip contents
    print("Extracting archive...");
    final bytes = await zipFile.readAsBytes();
    final Archive archive = ZipDecoder().decodeBytes(bytes);

    for (final ArchiveFile file in archive) {
      final String filename = file.name;
      
      // Skip hidden system files like Mac metadata artifacts
      if (filename.split('/').any((part) => part.startsWith('.'))) continue;

      if (file.isFile) {
        final data = file.content as List<int>;
        final File outFile = File("$localFolderPath/$filename");
        
        // Create nested sub-directories on the fly if needed
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        // Handle directory entry explicitly if present
        await Directory("$localFolderPath/$filename").create(recursive: true);
      }
    }
    print("Extraction complete.");

    // Clean up the temporary downloaded zip archive file safely
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    // 4. Read and return the contents.json file that came inside the zip
    if (await checkFile.exists()) {
      print("Loading extracted contents.json file...");
      final String jsonString = await checkFile.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      print("Warning: Extraction finished but contents.json was not found in the root of the zip.");
    }

  } catch (e) {
    print("An error occurred during asset synchronization: $e");
  }
  return null;
}
