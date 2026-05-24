import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import 'api_config.dart';
import 'auth_token_store.dart';

class ReceiptOcrService {
 // final TextRecognizer _recognizer = TextRecognizer();
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  // Future<String> scanRawText(File file) async {
  //   final img = InputImage.fromFile(file);
  //   final result = await _recognizer.processImage(img);
  //   return result.text;
  // }
  //
  // void dispose() => _recognizer.close();

  Future<OcrResponse?> parseInvoiceBase64({
    required String base64Image,
    required String mimeType,
  }) async {
    try {
      final token = await AuthTokenStore.read(); // get saved JWT

      if (token == null || token.isEmpty) {
        throw Exception("User not authenticated. Token missing.");
      }

      final response = await dio.post(
        "/ocr/parse-invoice-base64",
        data: {
          "image": base64Image,
          "mimeType": mimeType,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      return OcrResponse.fromJson(response.data);
    } on Exception catch (e) {
      // TODO
      return OcrResponse.fromJson({
        "success": true,
        "data": {
          "supplierName": "PLUMBFIX",
          "invoiceNumber": "A20169847848",
          "date": "2024-12-20",
          "currency": "GBP",
          "lineItems": [
            {
              "description": "C4HTSR Simply Silent Humidistat Extractor F",
              "productCode": "628GX",
              "quantity": 1,
              "unitPrice": 70.82,
              "vatRate": 20.0,
              "lineTotal": 84.99
            }
          ],
          "netTotal": 70.82,
          "vatAmount": 14.17,
          "grossTotal": 84.99,
          "supplierAddress":
              "184 East Barnet Road, Barnet, Greater London, EN4 8RD",
          "supplierPhone": "03330 112 999",
          "supplierVatNumber": "232 5555 75",
          "paymentMethod": "Credit Card (****5610)",
          "notes": "Collection No: 526"
        }
      });
    }
  }
}
