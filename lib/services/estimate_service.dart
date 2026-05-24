import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import 'api_client.dart';

class EstimateService {
  /// NEXT ESTIMATE NUMBER
  Future<String> getNextEstimateNumber() async {
    try {
      final api = await ApiClient.create();

      final res = await api.dio.get(
        "/estimates/next-number",
      );

      log("Next Estimate Number ${jsonEncode(res.data)}");

      return res.data["nextEstimateNumber"]?.toString() ?? "EST-0001";
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to get estimate number",
      );
    }
  }

  /// CREATE ESTIMATE
  Future<Map<String, dynamic>> createEstimate({
    required String estimateNumber,
    required String estimateDate,
    required String expiryDate,
    required int customerId,
    String? notes,
    String? terms,
    required List<Map<String, dynamic>> lines,
  }) async {
    try {
      final api = await ApiClient.create();

      final body = {
        "estimateNumber": estimateNumber,
        "estimateDate": estimateDate,
        "expiryDate": expiryDate,
        "customerId": customerId,
        "notes": notes,
        "terms": terms,
        "lines": lines,
      };

      final res = await api.dio.post(
        "/estimates",
        data: body,
      );

      return Map<String, dynamic>.from(
        res.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to create estimate",
      );
    }
  }

  /// GET ESTIMATES
  Future<List<dynamic>> getEstimates({
    String? status,
    int? customerId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final api = await ApiClient.create();

      final query = {
        if (status != null) "status": status,
        if (customerId != null) "customerId": customerId,
        if (dateFrom != null) "dateFrom": dateFrom,
        if (dateTo != null) "dateTo": dateTo,
      };

      final res = await api.dio.get(
        "/estimates",
        queryParameters: query,
      );

      print("Estaimates ${jsonEncode(res.data)}");

      return res.data["estimates"] as List;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to load estimates",
      );
    }
  }

  /// GET SINGLE ESTIMATE
  Future<Map<String, dynamic>> getEstimate(
    int id,
  ) async {
    try {
      final api = await ApiClient.create();

      final res = await api.dio.get(
        "/estimates/$id",
      );

      log("Estimate Details ${jsonEncode(res.data)}");

      return Map<String, dynamic>.from(
        res.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to load estimate",
      );
    }
  }

  /// UPDATE ESTIMATE
  Future<Map<String, dynamic>> updateEstimate({
    required int id,
    String? estimateNumber,
    String? estimateDate,
    String? expiryDate,
    int? customerId,
    String? notes,
    String? terms,
    List<Map<String, dynamic>>? lines,
  }) async {
    try {
      final api = await ApiClient.create();

      final body = {
        if (estimateNumber != null) "estimateNumber": estimateNumber,
        if (estimateDate != null) "estimateDate": estimateDate,
        if (expiryDate != null) "expiryDate": expiryDate,
        if (customerId != null) "customerId": customerId,
        if (notes != null) "notes": notes,
        if (terms != null) "terms": terms,
        if (lines != null) "lines": lines,
      };

      final res = await api.dio.put(
        "/estimates/$id",
        data: body,
      );

      return Map<String, dynamic>.from(
        res.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to update estimate",
      );
    }
  }

  /// DELETE ESTIMATE
  Future<void> deleteEstimate(
    int id,
  ) async {
    try {
      final api = await ApiClient.create();

      await api.dio.delete(
        "/estimates/$id",
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? e.message ?? "Failed to delete estimate",
      );
    }
  }

  /// CONVERT TO INVOICE
  Future<Map<String, dynamic>> convertEstimateToInvoice(
    int id,
  ) async {
    try {
      final api = await ApiClient.create();

      final res = await api.dio.post(
        "/estimates/$id/convert-to-invoice",
      );

      return Map<String, dynamic>.from(
        res.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to convert estimate",
      );
    }
  }
}
