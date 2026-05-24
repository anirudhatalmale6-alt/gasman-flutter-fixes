
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AnyFilePick {
  static Future<File?> pickAny() async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }
}

