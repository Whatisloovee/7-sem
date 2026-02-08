import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'vehicle.dart';

class FileOperations {
  static Future<void> saveVehicleToFiles(Vehicle vehicle) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_saveVehicleIsolate, [receivePort.sendPort, vehicle.toMap(), RootIsolateToken.instance!]);
    await for (var message in receivePort) {
      if (message is String && message == 'done') break;
    }
  }

  static void _saveVehicleIsolate(List<dynamic> args) async {
    final sendPort = args[0] as SendPort;
    final vehicleMap = args[1] as Map<String, dynamic>;
    final rootIsolateToken = args[2] as RootIsolateToken;

    // Initialize BackgroundIsolateBinaryMessenger
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final vehicle = Vehicle.fromMap(vehicleMap);
    final data = vehicle.getInfo();

    try {
      // Save to Temporary Directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/vehicle_temp.txt');
      print('Writing to Temporary: ${tempFile.path}');
      await tempFile.writeAsString('Temp: $data');
      print('Successfully wrote to Temporary: ${tempFile.path}');

      // Save to Application Documents Directory
      final docDir = await getApplicationDocumentsDirectory();
      final docFile = File('${docDir.path}/vehicle_doc.txt');
      print('Writing to Documents: ${docFile.path}');
      await docFile.writeAsString('Doc: $data');
      print('Successfully wrote to Documents: ${docFile.path}');

      // Save to Application Support Directory
      final supportDir = await getApplicationSupportDirectory();
      final supportFile = File('${supportDir.path}/vehicle_support.txt');
      print('Writing to Support: ${supportFile.path}');
      await supportFile.writeAsString('Support: $data');
      print('Successfully wrote to Support: ${supportFile.path}');

      // Save to Application Library Directory (iOS only)
      if (Platform.isIOS) {
        try {
          final libraryDir = await getLibraryDirectory();
          final libraryFile = File('${libraryDir.path}/vehicle_library.txt');
          print('Writing to Library: ${libraryFile.path}');
          await libraryFile.writeAsString('Library: $data');
          print('Successfully wrote to Library: ${libraryFile.path}');
        } catch (e) {
          print('Error accessing Application Library on iOS: $e');
        }
      } else {
        print('Application Library not supported on Android');
      }

      // Save to Application Cache Directory (iOS only)
        try {
          final cacheDir = await getApplicationCacheDirectory();
          final cacheFile = File('${cacheDir.path}/vehicle_cache.txt');
          print('Writing to Cache: ${cacheFile.path}');
          await cacheFile.writeAsString('Cache: $data');
          print('Successfully wrote to Cache: ${cacheFile.path}');
        } catch (e) {
          print('Error accessing Application Cache on iOS: $e');
        }

      // Save to External Storage Directory (Android only)
      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final extFile = File('${extDir.path}/vehicle_ext.txt');
            print('Writing to External Storage: ${extFile.path}');
            await extFile.writeAsString('External: $data');
            print('Successfully wrote to External Storage: ${extFile.path}');
          }
        } catch (e) {
          print('Error accessing External Storage on Android: $e');
        }
      } else {
        print('External Storage not supported on iOS');
      }

      // Save to External Files Directories (Android only)
      if (Platform.isAndroid) {
        try {
          final extFilesDirs = await getExternalStorageDirectories();
          if (extFilesDirs != null && extFilesDirs.isNotEmpty) {
            for (int i = 0; i < extFilesDirs.length; i++) {
              final extFilesFile = File('${extFilesDirs[i].path}/vehicle_ext_files_${i + 1}.txt');
              print('Writing to External Files ${i + 1}: ${extFilesFile.path}');
              await extFilesFile.writeAsString('External Files ${i + 1}: $data');
              print('Successfully wrote to External Files ${i + 1}: ${extFilesFile.path}');
            }
          }
        } catch (e) {
          print('Error accessing External Files Directories on Android: $e');
        }
      } else {
        print('External Files Directories not supported on iOS');
      }

      // Save to External Cache Directory (Android only)
      if (Platform.isAndroid) {
        try {
          final extCacheDirs = await getExternalCacheDirectories();
          if (extCacheDirs != null && extCacheDirs.isNotEmpty) {
            final extCacheFile = File('${extCacheDirs.first.path}/vehicle_ext_cache.txt');
            print('Writing to External Cache: ${extCacheFile.path}');
            await extCacheFile.writeAsString('External Cache: $data');
            print('Successfully wrote to External Cache: ${extCacheFile.path}');
          }
        } catch (e) {
          print('Error accessing External Cache on Android: $e');
        }
      } else {
        print('External Cache not supported on iOS');
      }

      // Save to Downloads Directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final downloadsFile = File('${downloadsDir.path}/vehicle_downloads.txt');
        print('Writing to Downloads: ${downloadsFile.path}');
        await downloadsFile.writeAsString('Downloads: $data');
        print('Successfully wrote to Downloads: ${downloadsFile.path}');
      } else {
        print('Downloads directory not available');
      }
    } catch (e) {
      print('Error in file operations: $e');
    }

    sendPort.send('done');
  }

  static Future<List<String>> listSavedFiles() async {
    final List<String> files = [];
    try {
      final tempDir = await getTemporaryDirectory();
      files.add('${tempDir.path}/vehicle_temp.txt');
      final docDir = await getApplicationDocumentsDirectory();
      files.add('${docDir.path}/vehicle_doc.txt');
      final supportDir = await getApplicationSupportDirectory();
      files.add('${supportDir.path}/vehicle_support.txt');
      if (Platform.isIOS) {
        try {
          final libraryDir = await getLibraryDirectory();
          files.add('${libraryDir.path}/vehicle_library.txt');
        } catch (e) {
          files.add('Application Library not supported on iOS: $e');
        }
      } else {
        files.add('Application Library not supported on Android');
      }
      if (Platform.isIOS) {
        try {
          final cacheDir = await getApplicationCacheDirectory();
          files.add('${cacheDir.path}/vehicle_cache.txt');
        } catch (e) {
          files.add('Application Cache not supported on iOS: $e');
        }
      }
      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) files.add('${extDir.path}/vehicle_ext.txt');
          final extCacheDirs = await getExternalCacheDirectories();
          if (extCacheDirs != null && extCacheDirs.isNotEmpty) {
            files.add('${extCacheDirs.first.path}/vehicle_ext_cache.txt');
          }
        } catch (e) {
          files.add('External Storage/Cache not supported on Android: $e');
        }
      }
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        files.add('${downloadsDir.path}/vehicle_downloads.txt');
      } else {
        files.add('Downloads directory not available');
      }
    } catch (e) {
      files.add('Error listing files: $e');
    }
    return files;
  }

  static Future<List<String>> readSavedFilesContent() async {
    final List<String> contents = [];
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/vehicle_temp.txt');
      if (await tempFile.exists()) {
        contents.add('Temp: ${await tempFile.readAsString()}');
      } else {
        contents.add('Temp: File not found');
      }

      final docDir = await getApplicationDocumentsDirectory();
      final docFile = File('${docDir.path}/vehicle_doc.txt');
      if (await docFile.exists()) {
        contents.add('Doc: ${await docFile.readAsString()}');
      } else {
        contents.add('Doc: File not found');
      }

      final supportDir = await getApplicationSupportDirectory();
      final supportFile = File('${supportDir.path}/vehicle_support.txt');
      if (await supportFile.exists()) {
        contents.add('Support: ${await supportFile.readAsString()}');
      } else {
        contents.add('Support: File not found');
      }

      if (Platform.isIOS) {
        try {
          final libraryDir = await getLibraryDirectory();
          final libraryFile = File('${libraryDir.path}/vehicle_library.txt');
          if (await libraryFile.exists()) {
            contents.add('Library: ${await tempFile.readAsString()}');
          } else {
            contents.add('Library: File not found');
          }
        } catch (e) {
          contents.add('Application Library not supported on iOS: $e');
        }
      } else {
        contents.add('Application Library not supported on Android');
      }

      if (Platform.isIOS) {
        try {
          final cacheDir = await getApplicationCacheDirectory();
          final cacheFile = File('${cacheDir.path}/vehicle_cache.txt');
          if (await cacheFile.exists()) {
            contents.add('Cache: ${await cacheFile.readAsString()}');
          } else {
            contents.add('Cache: File not found');
          }
        } catch (e) {
          contents.add('Application Cache not supported on iOS: $e');
        }
      }

      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final extFile = File('${extDir.path}/vehicle_ext.txt');
            if (await extFile.exists()) {
              contents.add('External: ${await extFile.readAsString()}');
            } else {
              contents.add('External: File not found');
            }
          }
          final extCacheDirs = await getExternalCacheDirectories();
          if (extCacheDirs != null && extCacheDirs.isNotEmpty) {
            final extCacheFile = File('${extCacheDirs.first.path}/vehicle_ext_cache.txt');
            if (await extCacheFile.exists()) {
              contents.add('External Cache: ${await extCacheFile.readAsString()}');
            } else {
              contents.add('External Cache: File not found');
            }
          }
        } catch (e) {
          contents.add('External Storage/Cache not supported on Android: $e');
        }
      }

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final downloadsFile = File('${downloadsDir.path}/vehicle_downloads.txt');
        if (await downloadsFile.exists()) {
          contents.add('Downloads: ${await downloadsFile.readAsString()}');
        } else {
          contents.add('Downloads: File not found');
        }
      } else {
        contents.add('Downloads: Directory not available');
      }
    } catch (e) {
      contents.add('Error reading files: $e');
    }
    return contents;
  }
}