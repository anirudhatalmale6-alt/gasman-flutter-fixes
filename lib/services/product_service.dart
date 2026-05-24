

 import 'dart:convert';
import 'dart:developer';

import 'api_client.dart';

class  ProductService {


   Future<List<dynamic>> getProducts({String? search}) async {
     final api = await ApiClient.create();
     final res = await api.dio.get(
       "/products",
       queryParameters: {
         if (search != null && search.isNotEmpty) "search": search,
       },
     );

     log("Response ${jsonEncode(res.data)}");

     return res.data["products"] ?? [];
   }

   Future<void> createProduct({
     required String name,
     String? description,
     String? sku,
     double price = 0,
     double cost = 0,
     double vatRate = 20,
     double stockQty = 0,
   }) async {

     final api = await ApiClient.create();
     await api.dio.post("/products", data: {
       "name": name,
       "description": description,
       "sku": sku,
       "price": price,
       "cost": cost,
       "vatRate": vatRate,
       "stockQty": stockQty,
     });
   }

   Future<void> updateProduct({
     required int id,
     required String name,
     String? description,
     String? sku,
     double price = 0,
     double cost = 0,
     double vatRate = 20,
     double stockQty = 0,
   }) async {
     final api = await ApiClient.create();
     await api.dio.put("/products/$id", data: {
       "name": name,
       "description": description,
       "sku": sku,
       "price": price,
       "cost": cost,
       "vatRate": vatRate,
       "stockQty": stockQty,
     });
   }

   Future<void> deleteProduct(int id) async {
     final api = await ApiClient.create();
     await api.dio.delete("/products/$id");
   }

   Future<List<dynamic>> getStockMovements(int productId) async {
     final api = await ApiClient.create();
     final res = await api.dio.get(
       "/products/$productId/stock-movements",
     );
     return res.data["movements"] ?? [];
   }

   Future<List> getStockTrend() async {
     final api = await ApiClient.create();
     final res = await api.dio.get("/reports/stock-trend?days=30");
     return res.data["trend"] ?? [];
   }

   Future<Map<String, dynamic>> getStockValuationByDate(String date) async {
     final api = await ApiClient.create();

     final res = await api.dio.get(
       "/reports/stock-valuation-by-date",
       queryParameters: {"date": date},
     );

     return res.data;
   }





}