import 'dart:convert';
import 'dart:developer';

import 'package:logger/logger.dart';

import 'api_client.dart';

class BankingService {
  Future<List<dynamic>> listBankAccounts() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/bank-accounts");
    return res.data["bankAccounts"] as List;
  }

  Future<Map<String, dynamic>> createBankAccount({
    required String name,
    String currencyCode = "GBP",
  }) async {
    final api = await ApiClient.create();
    final res = await api.dio.post("/bank-accounts", data: {
      "name": name,
      "currencyCode": currencyCode,
    });
    return Map<String, dynamic>.from(res.data["bankAccount"]);
  }

  Future<List<dynamic>> listTransactions(
    int bankAccountId, {
    String? fromDate,
    String? toDate,
    String? type,
  }) async {
    final api = await ApiClient.create();

    final queryParams = <String, dynamic>{};

    if (fromDate != null) {
      queryParams["from_date"] = fromDate;
    }

    if (toDate != null) {
      queryParams["to_date"] = toDate;
    }
    if (type != null) {
      queryParams["type"] = type;
    }

    final res = await api.dio.get(
      "/bank-transactions",
      queryParameters: queryParams,
    );
    log("RRRRRRR => ${jsonEncode(res.data)}");

    return res.data["transactions"] as List;
  }

  Future<Map<String, dynamic>> createTransaction({
    required int bankAccountId,
     int? id,
    required String txnDate, // yyyy-mm-dd
    required String type,
    required double amount,
    required String description,
    String? reference,
    String? category,
  }) async {
    final api = await ApiClient.create();

    final data = {
      "bankAccountId": bankAccountId,
      "transactionDate": txnDate,
      "type": type,
      "amount": amount,
      "description": description,
      "isReconciled": false,
      if (reference != null && reference.isNotEmpty) "reference": reference,
      if (category != null && category.isNotEmpty) "category": category,
    };

    final res = id != null ?await api.dio.put(
      "/bank-transactions/$id",
      data: data,
    ) :await api.dio.post(
      "/bank-transactions",
      data: data,
    );

    print("Api Url ${res.realUri}");
    print("Payload => $data");

    return Map<String, dynamic>.from(res.data["transaction"]);
  }

  Future<Map<String, dynamic>> suggestMatches(int txnId) async {
    final api = await ApiClient.create();
    final res = await api.dio.post("/bank-transactions/reconcile", data: {
      "transactionIds": [txnId]
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> match({
    required int txnId,
    required String referenceType, // INVOICE or BILL
    required int referenceId,
  }) async {
    final api = await ApiClient.create();
    await api.dio.post("/reconciliation/match", data: {
      "txnId": txnId,
      "referenceType": referenceType,
      "referenceId": referenceId,
    });
  }

  Future<Map<String, dynamic>> deleteTransaction(int id) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete("/bank-transactions/$id");
    return Map<String, dynamic>.from(res.data);
  }
}
