import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';

import 'api_client.dart';

class MasterDataService {
  Future<List<dynamic>> getCustomers({String? search}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get(
      "/customers",
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      },
    );
    log("👹👹👹👹👹 ${jsonEncode(res.data)}");
    return (res.data is List)
        ? (res.data as List)
        : (res.data["customers"] as List? ?? []);
  }

  Future<Map<String, dynamic>> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? vatNumber,
    String? contactPerson,
    int? id,
  }) async {
    final api = await ApiClient.create();
    final res = id != null
        ? await api.dio.put("/customers/$id", data: {
            "name": name,
            if (email != null && email.trim().isNotEmpty) "email": email.trim(),
            if (phone != null && phone.trim().isNotEmpty) "phone": phone.trim(),
            if (address != null && address.trim().isNotEmpty)
              "address": address.trim(),
            if (vatNumber != null && vatNumber.trim().isNotEmpty)
              "vatNumber": vatNumber.trim(),
            if (contactPerson != null && contactPerson.trim().isNotEmpty)
              "contactPerson": contactPerson.trim(),
          })
        : await api.dio.post("/customers", data: {
            "name": name,
            if (email != null && email.trim().isNotEmpty) "email": email.trim(),
            if (phone != null && phone.trim().isNotEmpty) "phone": phone.trim(),
            if (address != null && address.trim().isNotEmpty)
              "address": address.trim(),
            if (vatNumber != null && vatNumber.trim().isNotEmpty)
              "vatNumber": vatNumber.trim(),
            if (contactPerson != null && contactPerson.trim().isNotEmpty)
              "contactPerson": contactPerson.trim(),
          });
    return Map<String, dynamic>.from(
      (res.data["customer"] ?? res.data) as Map,
    );
  }

  Future<List<dynamic>> getSuppliers({String? search}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get(
      "/suppliers",
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      },
    );

    log("Suppliers 👹👹👹👹👹 ${jsonEncode(res.data)}");

    return (res.data is List)
        ? (res.data as List)
        : (res.data["suppliers"] as List? ?? []);
  }

  Future<Map<String, dynamic>> createSupplier({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? vatNumber,
    String? contactPerson,
    int? id,
  }) async {
    final api = await ApiClient.create();
    final res = id != null
        ? await api.dio.put("/suppliers/$id", data: {
            "name": name,
            if (email != null && email.trim().isNotEmpty) "email": email.trim(),
            if (phone != null && phone.trim().isNotEmpty) "phone": phone.trim(),
            if (address != null && address.trim().isNotEmpty)
              "address": address.trim(),
            if (vatNumber != null && vatNumber.trim().isNotEmpty)
              "vatNumber": vatNumber.trim(),
            if (contactPerson != null && contactPerson.trim().isNotEmpty)
              "contactPerson": contactPerson.trim(),
          })
        : await api.dio.post("/suppliers", data: {
            "name": name,
            if (email != null && email.trim().isNotEmpty) "email": email.trim(),
            if (phone != null && phone.trim().isNotEmpty) "phone": phone.trim(),
            if (address != null && address.trim().isNotEmpty)
              "address": address.trim(),
            if (vatNumber != null && vatNumber.trim().isNotEmpty)
              "vatNumber": vatNumber.trim(),
            if (contactPerson != null && contactPerson.trim().isNotEmpty)
              "contactPerson": contactPerson.trim(),
          });
    return Map<String, dynamic>.from(
      (res.data["supplier"] ?? res.data) as Map,
    );
  }

  Future<List<dynamic>> getBankAccounts() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/bank-accounts");
    return (res.data is List)
        ? (res.data as List)
        : (res.data["bankAccounts"] as List? ?? []);
  }

  Future<Map<String, dynamic>> createBankAccount({
    required String accountName,
    String? bankName,
    String? accountNumber,
    String? sortCode,
    String? iban,
    String? swiftBic,
    String currency = "GBP",
    double openingBalance = 0,
    bool isDefault = false,
  }) async {
    final api = await ApiClient.create();
    final res = await api.dio.post("/bank-accounts", data: {
      "accountName": accountName,
      if (bankName != null && bankName.trim().isNotEmpty)
        "bankName": bankName.trim(),
      if (accountNumber != null && accountNumber.trim().isNotEmpty)
        "accountNumber": accountNumber.trim(),
      if (sortCode != null && sortCode.trim().isNotEmpty)
        "sortCode": sortCode.trim(),
      if (iban != null && iban.trim().isNotEmpty) "iban": iban.trim(),
      if (swiftBic != null && swiftBic.trim().isNotEmpty)
        "swiftBic": swiftBic.trim(),
      "currency": currency,
      "openingBalance": openingBalance,
      "isDefault": isDefault,
    });
    return Map<String, dynamic>.from(
      (res.data["bankAccount"] ?? res.data) as Map,
    );
  }

  Future<Map<String, dynamic>> getVatSummary({
    required String dateFrom,
    required String dateTo,
  }) async {
    final api = await ApiClient.create();
    print("Json data ${jsonEncode({
      "dateFrom": dateFrom,
      "dateTo": dateTo,
    })}");
    final res = await api.dio.get(
      "/vat/summary",
      queryParameters: {
        "dateFrom": dateFrom,
        "dateTo": dateTo,
      },
    );

    log("Vat Summary Data ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(
      (res.data["summary"] ?? res.data) as Map,
    );
  }

  Future<Map<String, dynamic>> deleteCustomer({
    required int id,
  }) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete(
      "/customers/$id",
    );
    log("Delete Customer 👹👹👹👹👹 ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(
      (res.data) as Map,
    );
  }

  Future<Map<String, dynamic>> deleteSupplier({
    required int id,
  }) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete(
      "/suppliers/$id",
    );
    log("Delete Customer 👹👹👹👹👹 ${jsonEncode(res.data)}");
    return Map<String, dynamic>.from(
      (res.data) as Map,
    );
  }
}
