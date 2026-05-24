
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePick {
  static final _picker = ImagePicker();

  static Future<File?> camera() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    return x == null ? null : File(x.path);
  }

  static Future<File?> gallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    return x == null ? null : File(x.path);
  }
}
