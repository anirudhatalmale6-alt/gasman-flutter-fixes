import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_client.dart';

class PayrollService {
  Future<List<dynamic>> listEmployees() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/employees");
    log("Employee List ${jsonEncode(res.data)}");
    return res.data["employees"] as List;
  }

  Future<Map<String, dynamic>> createEmployee({required String fullName, String? email, String taxCode = "1257L"}) async {
    final api = await ApiClient.create();
    final res = await api.dio.post("/employees", data: {
      "fullName": fullName,
      "email": email,
      "taxCode": taxCode,
    });
    return Map<String, dynamic>.from(res.data["employee"]);
  }

  Future<List<dynamic>> listRuns() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/payroll-runs");
    log("Response Body ${jsonEncode(res.data)}");
    return res.data["payrollRuns"] as List;
  }

  Future<Map<String, dynamic>> createRun(Map<String, dynamic> body,{int? id}) async {
    final api = await ApiClient.create();
    print("JsonCode ${jsonEncode(body)}");
    final res = id != null ? await api.dio.put("/payroll-runs/$id", data: body) : await api.dio.post("/payroll-runs", data: body);
    return Map<String, dynamic>.from(res.data["payrollRun"]);
  }

  Future<Map<String, dynamic>> getRun(int runId) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/payroll-runs/$runId");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> deleteRun(int runId) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete("/payroll-runs/$runId");
    return Map<String, dynamic>.from(res.data);
  }

   // PUT /payroll-runs/:id/status - Change status: { "status": "APPROVED" }
  Future<Map<String, dynamic>> updateStatus(int runId) async {
    final api = await ApiClient.create();
    final res = await api.dio.put("payroll-runs/$runId/status");
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> postRun(int runId) async {
    final api = await ApiClient.create();
    await api.dio.post("/payroll-runs/$runId/post");
  }

  Future<Uint8List> downloadPayslipPdf(int payslipId) async {
    final api = await ApiClient.create();
    final res = await api.dio.get(
      "/payslips/$payslipId/pdf",
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data as List<int>);
  }
}