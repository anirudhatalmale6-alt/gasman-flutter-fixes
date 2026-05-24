import 'dart:convert';
import 'dart:developer';

import 'api_client.dart';

class EmployeeService {


  // ===========================
  // EMPLOYEE APIs
  // ===========================

  Future<List<dynamic>> getEmployees({String? search}) async {
    final api = await ApiClient.create();
    final res = await api.dio.get(
      "/employees",
      queryParameters: {
        if (search != null && search.trim().isNotEmpty)
          "search": search.trim(),
      },
    );

    log("Employees 👹 ${jsonEncode(res.data)}");

    return (res.data is List)
        ? (res.data as List)
        : (res.data["employees"] as List? ?? []);
  }

  Future<Map<String, dynamic>> createEmployee({
    int? id,
    required String firstName,
    String? lastName,
    String? email,
    String? phone,
    String? jobTitle,
    String? department,
    double? salary,
    String? startDate,
    String? niNumber,
    String? taxCode,
  }) async {
    final api = await ApiClient.create();

    final body = {
      "firstName": firstName,
      if (lastName != null && lastName.trim().isNotEmpty)
        "lastName": lastName.trim(),
      if (email != null && email.trim().isNotEmpty)
        "email": email.trim(),
      if (phone != null && phone.trim().isNotEmpty)
        "phone": phone.trim(),
      if (jobTitle != null && jobTitle.trim().isNotEmpty)
        "jobTitle": jobTitle.trim(),
      if (department != null && department.trim().isNotEmpty)
        "department": department.trim(),
      if (salary != null) "salary": salary,
      if (startDate != null && startDate.trim().isNotEmpty)
        "startDate": startDate.trim(),
      if (niNumber != null && niNumber.trim().isNotEmpty)
        "niNumber": niNumber.trim(),
      if (taxCode != null && taxCode.trim().isNotEmpty)
        "taxCode": taxCode.trim(),
    };

    final res = id != null
        ? await api.dio.put("/employees/$id", data: body)
        : await api.dio.post("/employees", data: body);

    log("Employee Save 👹 ${jsonEncode(res.data)}");

    return Map<String, dynamic>.from(
      (res.data["employee"] ?? res.data) as Map,
    );
  }

  Future<Map<String, dynamic>> deleteEmployee({required int id}) async {
    final api = await ApiClient.create();
    final res = await api.dio.delete("/employees/$id");

    log("Delete Employee 👹 ${jsonEncode(res.data)}");

    return Map<String, dynamic>.from(res.data as Map);
  }


}