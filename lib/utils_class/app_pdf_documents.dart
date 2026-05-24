import 'package:pdf/widgets.dart' as pw;
import 'package:the_gas_man_app/utils_class/pdf_font_helper.dart';

class AppPdfDocument extends pw.Document {
  AppPdfDocument() : super(theme: PdfFontHelper.getTheme());
}