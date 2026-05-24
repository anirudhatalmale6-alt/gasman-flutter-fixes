
import 'dart:typed_data';

import 'package:printing/printing.dart';

class PdfPrint {
  static Future<void> previewAndPrint(Uint8List bytes, {String? filename}) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<void> share(Uint8List bytes, {String filename = "document.pdf"}) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}


