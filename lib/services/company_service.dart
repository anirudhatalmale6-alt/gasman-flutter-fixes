import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';

class CompanyService {
  Future<Map<String, dynamic>> getCompany() async {
    try {
      final api = await ApiClient.create();

      final res = await api.dio.get("/company");

      log("Company Info ${jsonEncode(res.data)}");

      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to load company",
      );
    }
  }

  Future<Map<String, dynamic>> updateCompany({
    String? name,
    String? businessName,
    String? address,
    String? phone,
    String? email,
    String? vrn,
    String? companyReg,
    String? utr,
    String? website,
    String? currencyCode,
    String? currencySymbol,

    /// NEW FIELDS
    String? paymentDetails,
    String? gasSafeNumber,
    String? postalCode,
    String? invoicePrefix,
    int? defaultReminderHours,
    File? logoFile,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final api = await ApiClient.create();

      final formData = FormData.fromMap({
        if (name != null) "name": name,
        if (businessName != null) "businessName": businessName,
        if (address != null) "address": address,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (vrn != null) "vrn": vrn,
        if (companyReg != null) "companyReg": companyReg,
        if (utr != null) "utr": utr,
        if (website != null) "website": website,
        if (currencyCode != null) "currencyCode": currencyCode,
        if (currencySymbol != null) "currencySymbol": currencySymbol,

        /// NEW FIELDS
        if (paymentDetails != null) "paymentDetails": paymentDetails,

        if (gasSafeNumber != null) "gasSafeNumber": gasSafeNumber,

        if (postalCode != null) "postalCode": postalCode,

        if (invoicePrefix != null) "invoicePrefix": invoicePrefix,

        if (defaultReminderHours != null)
          "defaultReminderHours": defaultReminderHours,

        /// FILE
        if (logoFile != null)
          "logo": await MultipartFile.fromFile(
            logoFile.path,
            filename: logoFile.path.split("/").last,
          ),
      });

      final res = await api.dio.put(
        "/company",
        data: formData,
        onSendProgress: onProgress,
      );

      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to update company",
      );
    }
  }

  Future<File?> urlToFile(String imageUrl) async {
    try {
      final response = await Dio().get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final tempDir = Directory.systemTemp;

      final file = File(
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(response.data);

      return file;
    } catch (e) {
      return null;
    }
  }
}
