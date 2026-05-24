
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FilePick {
  static Future<File?> pickCsvOrExcel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }
}
