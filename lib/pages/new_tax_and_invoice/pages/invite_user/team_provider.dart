import 'package:flutter/material.dart';

import '../../../../services/invite_services.dart';
import '../../data_models/invitation.dart';
import '../../data_models/team_member.dart';


class TeamProvider extends ChangeNotifier {
  final InviteService _service = InviteService();

  List<Members> members = [];
  List<Invitations> invitations = [];

  bool isLoading = false;
  String? error;

  // 🔄 Load Members + Invitations
  Future<void> loadData() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      final memberRes = await _service.getMembers();
      if(memberRes != null && memberRes.members != null && memberRes.members!.isNotEmpty){
        members = memberRes.members!;
      }

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInvitations() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      final inviteRes = await _service.getInvitations();
      invitations = inviteRes!;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ➕ Invite Accountant
  Future<void> invite(String email) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.invite(email);

      await loadData(); // refresh after invite
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ❌ Remove Member
  Future<void> removeMember(String id) async {
    try {
      await _service.removeMember(id);

      members.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // 🚫 Cancel Invitation
  Future<void> cancelInvitation(String id) async {
    try {
      await _service.cancelInvitation(id);

      invitations.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}