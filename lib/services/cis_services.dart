import 'dart:convert';
import 'dart:developer';

import '../pages/new_tax_and_invoice/data_models/cis_return.dart';
import '../pages/new_tax_and_invoice/data_models/deduction.dart';
import '../pages/new_tax_and_invoice/data_models/statement_model.dart';
import '../pages/new_tax_and_invoice/data_models/sub_contractor.dart';
import '../pages/new_tax_and_invoice/data_models/summary_data.dart';
import '../pages/new_tax_and_invoice/data_models/tax_month.dart';
import 'api_client.dart';

class CISService {
  // ---------------- Subcontractors ----------------

  Future<List<Subcontractor>> getSubcontractors() async {
    try {
      final api = await ApiClient.create();

      final res = await api.dio.get("/cis/subcontractors");

      print("Response ${jsonEncode(res.data)}");

      return (res.data['subcontractors'] as List)
          .map((e) => Subcontractor.fromJson(e))
          .toList();
    } on Exception catch (e) {
      // TODO
      return [];
    }
  }

  Future<void> addSubcontractor(Map<String, dynamic> body) async {
    final api = await ApiClient.create();

    await api.dio.post("/cis/subcontractors", data: body);
  }

  Future<void> updateSubcontractor(int id, Map<String, dynamic> body) async {
    final api = await ApiClient.create();

    await api.dio.put("/cis/subcontractors/$id", data: body);
  }

  Future<void> deleteSubcontractor(int id) async {
    final api = await ApiClient.create();

    await api.dio.delete("/cis/subcontractors/$id");
  }

  Future<void> verifySubcontractor(int id) async {
    final api = await ApiClient.create();

    await api.dio.post("/cis/subcontractors/$id/verify");
  }

  // ---------------- Deductions ----------------

  Future<List<Deduction>> getDeductions({String? month}) async {
    final api = await ApiClient.create();

    final res = await api.dio.get(
      "/cis/deductions",
      queryParameters: {
        if (month != null) "month": month,
      },
    );

    return (res.data['deductions'] as List)
        .map((e) => Deduction.fromJson(e))
        .toList();
  }

  Future<void> addDeduction(Map<String, dynamic> body) async {
    final api = await ApiClient.create();

    await api.dio.post("/cis/deductions", data: body);
  }

  Future<void> updateDeduction(int id, Map<String, dynamic> body) async {
    final api = await ApiClient.create();

    await api.dio.put("/cis/deductions/$id", data: body);
  }

  Future<void> deleteDeduction(int id) async {
    final api = await ApiClient.create();

    await api.dio.delete("/cis/deductions/$id");
  }

  // ---------------- Returns ----------------

  Future<CISReturn> getReturn(String month) async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/cis/returns/$month");

    return CISReturn.fromJson(res.data);
  }

  Future<void> submitReturn(String month, String utr) async {
    final api = await ApiClient.create();

    await api.dio.post(
      "/cis/returns/$month/submit",
      data: {"contractorUtr": utr},
    );
  }

  Future<List<TaxMonth>> getTaxMonths() async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/cis/tax-months");

    log("Data ${jsonEncode(res.data)}");

    return (res.data['taxMonths'] as List)
        .map((e) => TaxMonth.fromJson(e))
        .toList();
  }

  // ---------------- Dashboard ----------------

  Future<SummaryModel> getSummary() async {
    final api = await ApiClient.create();

    final res = await api.dio.get("/cis/summary");
    log("CIS Summary ${jsonEncode(res.data)}");

    return SummaryModel.fromJson(res.data);
  }

  // ---------------- Statement ----------------

  Future<StatementModel> getStatement(
      int id, {
        String? from,
        String? to,
      }) async {
    final api = await ApiClient.create();

    final res = await api.dio.get(
      "/cis/statement/$id",
      queryParameters: {
        if (from != null) "from": from,
        if (to != null) "to": to,
      },
    );

    return StatementModel.fromJson(res.data);
  }
}