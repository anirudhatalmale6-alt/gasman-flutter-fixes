import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontHelper {
  static pw.Font? regular;
  static pw.Font? bold;

  static Future<void> loadFonts() async {
    final regularFont =
    await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFont =
    await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

    regular = pw.Font.ttf(regularFont);
    bold = pw.Font.ttf(boldFont);
  }

  static pw.ThemeData getTheme() {
    return pw.ThemeData.withFont(
      base: regular!,
      bold: bold!,
    );
  }
}