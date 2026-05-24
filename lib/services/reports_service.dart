import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import 'api_client.dart';

class ReportsService {
  Future<Map<String, dynamic>> trialBalance({String? dateFrom, String? dateTo}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/reports/tb", queryParameters: {
      if (dateFrom != null) "dateFrom": dateFrom,
      if (dateTo != null) "dateTo": dateTo,
    });
    log("Trial Balance Api ${jsonEncode(res.data)}");

    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> profitAndLoss({String? dateFrom, String? dateTo}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/reports/pl", queryParameters: {
      if (dateFrom != null) "dateFrom": dateFrom,
      if (dateTo != null) "dateTo": dateTo,
    });
    debugPrint("Reponsebody ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> balanceSheet({String? asOf}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/reports/bs", queryParameters: {
      if (asOf != null) "asOf": asOf,
    });
  //  print("RRRRRRR => ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> vatReturn({required String dateFrom, required String dateTo}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/vat/return", queryParameters: {
      "dateFrom": dateFrom,
      "dateTo": dateTo,
    });
    //print("Api Response Body ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(res.data);
  }
}