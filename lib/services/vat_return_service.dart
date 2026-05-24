import 'dart:convert';
import 'dart:developer';

import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';

import 'api_client.dart';

class VatReturnService {
  Future<Map<String, dynamic>> getSummary() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/vat/summary");
   // print("RRRR => ${res.data}");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getVatSubmissions() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/hmrc/vat-submissions");
   // print("Vat Submissions ${res.data}");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> submitVat({
    required String vrn,
    required Map<String, dynamic> vatData,
  }) async {
    final api = await ApiClient.create();
    final res = await api.dio.post(
      "/hmrc/vat-submit",
      data: {"vrn": vrn, "vatData": vatData},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getVatLoacks() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/hmrc/period-locks");
   // print("VatLockResponse ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>?> getVatObligations() async {
    AccountingSettings _settings = AccountStorage().settings;
    if (_settings != null && _settings.vatNumber != null) {
      final api = await ApiClient.create();
      final res = await api.dio.get(
          "/hmrc/vat-obligations?vrn=${_settings.vatNumber}&from=2025-01-01&to=2025-12-31");
      //print("Obligations List ${res.data}");
      return Map<String, dynamic>.from(res.data);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkHMRCConnection() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/hmrc/status");
    return Map<String, dynamic>.from(res.data);
  }

  Future<String> getAuthUrl() async {
    final api = await ApiClient.create();
    final res = await api.dio.get('/hmrc/auth-url');
  //  print("HMRC Connect URL => ${res.data['url']}");
    return res.data['url'];
  }

  Future<void> disconnect() async {
    final api = await ApiClient.create();
    await api.dio.post('/hmrc/disconnect');
  }

  Future<Map<String, dynamic>?> getVatReturn(
      {required String dateFrom, required String dateTo}) async {
    final api = await ApiClient.create();
    final res =
        await api.dio.get("/vat/return?dateFrom=$dateFrom&dateTo=$dateTo");
    return Map<String, dynamic>.from(res.data);
  }
}
