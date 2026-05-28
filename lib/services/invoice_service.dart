
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/main.dart';

import '../pages/new_tax_and_invoice/data_models/invoice_detail.dart';
import 'api_client.dart';

class InvoiceService {
  Future<List<dynamic>> list() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/invoices");
    print("Response body ${res.data}");
    return (res.data["invoices"] as List);
  }

  Future<List<dynamic>> listOverdue() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/invoices/overdue");
    return (res.data["invoices"] as List);
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/invoices/$id");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body, {int? id}) async {
    final api = await ApiClient.create();
    final res = id != null ? await api.dio.put("/invoices/$id", data: body) :await api.dio.post("/invoices", data: body);
    return Map<String, dynamic>.from(res.data["invoice"]);
  }

  Future<InvoiceDetailMaster> getDetail(int id) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/invoices/$id");
    log("Hello ${jsonEncode(res.data)}");
    return InvoiceDetailMaster.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Map<String, dynamic>> deleteInvoice(int id,{Function? onError}) async {
    try {
      final api = await ApiClient.create(onError: (){
        if(onError != null){
          onError();
        }
      });
      final res = await api.dio.delete("/invoices/$id");
      return Map<String, dynamic>.from(res.data);
    } on Exception catch (e) {
      if(onError != null){
        onError();
      }
      // TODO
      return {};
    }
  }

  void _handleDioError(DioException e, ) {
    String message = "Something went wrong";

    if (e.response != null) {
      final data = e.response!.data;

      // API error message
      if (data is Map && data["error"] != null) {
        message = data["error"];
      }

      // Optional: handle specific cases
      if (message.contains("Cannot delete a PAID invoice")) {
        message = "This invoice is already paid. You must VOID it instead.";
      }
    } else {
      message = e.message ?? "Network error";
    }

    ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
