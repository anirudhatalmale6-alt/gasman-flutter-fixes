import 'dart:convert';
import 'dart:developer';

import 'api_client.dart';

class TeamService {
  Future<List<dynamic>> getTeamMembers() async {
    final api = await ApiClient.create();
    final res = await api.dio.get("/team");
    log("Members ${jsonEncode(res.data)}");
    return res.data["members"] ?? [];
  }

  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    final api = await ApiClient.create();
    await api.dio.post("/team/invite", data: {
      "email": email,
      "role": role,
    });
  }

  Future<void> updateMember({
    required int id,
    required String role,
    required String name,
    required bool isActive,
  }) async {
    final api = await ApiClient.create();
    await api.dio.put("/team/$id", data: {
      "role": role,
      "isActive": isActive,
      "name": name,
    });
  }
}