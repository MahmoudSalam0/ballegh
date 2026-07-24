import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReportImageStorage {
  ReportImageStorage._();

  static final ReportImageStorage instance = ReportImageStorage._();

  final ImagePicker _picker = ImagePicker();
  final Random _random = Random.secure();

  Future<String?> pickAndStore(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage == null) {
      return null;
    }

    final imagesDirectory = await _imagesDirectory();
    final extension = _safeExtension(pickedImage.path);
    final uniquePart =
        '${DateTime.now().microsecondsSinceEpoch}_'
        '${_random.nextInt(0x7fffffff)}';
    final destinationPath = path.join(
      imagesDirectory.path,
      'report_$uniquePart$extension',
    );

    final destination = File(destinationPath);
    try {
      await File(pickedImage.path).copy(destination.path);
      return destination.path;
    } catch (_) {
      try {
        if (await destination.exists()) {
          await destination.delete();
        }
      } catch (_) {
        // The original copy error is the useful error for the caller.
      }
      rethrow;
    }
  }

  Future<void> deleteManagedImage(String? imagePath) async {
    final value = imagePath?.trim();
    if (value == null || value.isEmpty) {
      return;
    }

    try {
      final imagesDirectory = await _imagesDirectory();
      final managedRoot = path.normalize(path.absolute(imagesDirectory.path));
      final candidate = path.normalize(path.absolute(value));

      if (!path.isWithin(managedRoot, candidate)) {
        return;
      }

      final file = File(candidate);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // File cleanup must never change the result of a database operation.
    }
  }

  Future<Directory> _imagesDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      path.join(documentsDirectory.path, 'report_images'),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  String _safeExtension(String sourcePath) {
    final extension = path.extension(sourcePath).toLowerCase();
    if (RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)) {
      return extension;
    }
    return '.jpg';
  }
}
