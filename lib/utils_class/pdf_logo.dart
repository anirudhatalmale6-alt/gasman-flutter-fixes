import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../pages/new_tax_and_invoice/api_service/api_config.dart';
import '../services/company_service.dart';

/// Company logo for PDFs.
///
/// The logo path saved in settings used to point at the temp/cache folder,
/// which Android empties whenever it likes. Reading that missing file threw,
/// and the PDF / Share buttons silently did nothing. This loader never throws:
/// it falls back to a permanent copy, then to the server, then to no logo.
class PdfLogo {
  static const _fileName = 'company_logo.png';

  /// Permanent location (app documents folder, never cleared by Android).
  static Future<File> permanentFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Copies [path] into the permanent location, so the logo survives a cache
  /// clear. Safe to call with a missing/empty path.
  static Future<void> keep(String? path) async {
    try {
      if (path == null || path.isEmpty) return;
      final src = File(path);
      final dst = await permanentFile();
      if (src.path == dst.path || !await src.exists()) return;
      await dst.writeAsBytes(await src.readAsBytes(), flush: true);
    } catch (_) {}
  }

  static Future<pw.MemoryImage?> load(String? path) async {
    try {
      if (path != null && path.isNotEmpty) {
        final f = File(path);
        if (await f.exists()) {
          await keep(path);
          return pw.MemoryImage(await f.readAsBytes());
        }
      }
    } catch (_) {}

    try {
      final f = await permanentFile();
      if (await f.exists()) return pw.MemoryImage(await f.readAsBytes());
    } catch (_) {}

    return _download();
  }

  static Future<pw.MemoryImage?> _download() async {
    try {
      final co = await CompanyService().getCompany();
      final logoUrl = co['logo_url'] as String?;
      if (logoUrl == null || logoUrl.isEmpty) return null;
      final res = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      )).get<List<int>>(
        '${ApiConfig.baseUrl}$logoUrl',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) return null;
      final f = await permanentFile();
      await f.writeAsBytes(bytes, flush: true);
      return pw.MemoryImage(await f.readAsBytes());
    } catch (_) {
      return null;
    }
  }
}
