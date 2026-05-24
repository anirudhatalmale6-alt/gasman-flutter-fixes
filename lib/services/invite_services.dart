import 'dart:convert';

import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/invitation.dart';

import '../pages/new_tax_and_invoice/api_service/auth_token_store.dart';
import '../pages/new_tax_and_invoice/data_models/team_member.dart';
import 'api_client.dart';

class InviteService {
  Future<MemberListMaster> getMembers() async {
    String? accountEmail = await AuthTokenStore.readEmail();
    final api = await ApiClient.create();
    final res = await api.dio.get("/team/members");
    return MemberListMaster.fromJson(res.data);
  }

  Future<List<Invitations>?> getInvitations() async {
  String? accountEmail = await AuthTokenStore.readEmail();
    final api = await ApiClient.create();
    final res =
        await api.dio.get("/auth/pending-invites?email=$accountEmail");
    return InvitationListMaster.fromJson(res.data!).invitations;
  }

  Future<void> invite(String email) async {
    final api = await ApiClient.create();
    await api.dio.post(
      "/team/invite",
      data: {
        "email": email,
        "role": "accountant",
      },
    );
  }

  Future<void> removeMember(String id) async {
    final api = await ApiClient.create();
    await api.dio.delete("/team/members/$id");
  }

  Future<void> cancelInvitation(String id) async {
    final api = await ApiClient.create();
    await api.dio.delete("/team/invitations/$id");
  }

  Future<void> acceptInvite({
    required String inviteCode,
    required String email,
    required String password,
  }) async {
    final api = await ApiClient.create();

    await api.dio.post(
      "/auth/accept-invite",
      data: {
        "inviteCode": inviteCode,
        "email": email,
        "password": password,
      },
    );
  }
}
