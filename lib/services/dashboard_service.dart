import 'dart:convert';
import 'dart:developer';

import 'api_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> getSummary() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/dashboard/summary");
    return Map<String, dynamic>.from(res.data);
  }
}