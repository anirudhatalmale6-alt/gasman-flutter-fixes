import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<File> file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name.json');
  }

  static Future<Map<String, dynamic>> read(String name) async {
    try {
      final f = await file(name);
      if (!await f.exists()) return {};
      final txt = await f.readAsString();
      return jsonDecode(txt) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> write(String name, Map<String, dynamic> data) async {
    final f = await file(name);
    await f.writeAsString(jsonEncode(data));
  }
}
