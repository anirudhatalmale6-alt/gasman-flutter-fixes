import 'dart:convert';
import 'dart:developer';

import '../pages/new_tax_and_invoice/data_models/bill_detail.dart';
import 'api_client.dart';

class BillService {
  Future<List<dynamic>> list() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/bills");
    log("Response ${jsonEncode(res.data)}");
    return (res.data["bills"] as List);
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/bills/$id");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body,{int? id}) async {
    final api = await ApiClient.create();
    final res = (id != null) ? await api.dio.put("/bills/$id", data: body): await api.dio.post("/bills", data: body);
    return Map<String, dynamic>.from(res.data["bill"]);
  }


  Future<BillDetails> getDetail(int id) async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/bills/$id");
    log("Bill Details ${jsonEncode(res.data)}");
    return BillDetails.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Map<String, dynamic>> deleteBill({required int id}) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete("/bills/$id");
    return Map<String, dynamic>.from(res.data);
  }

}
