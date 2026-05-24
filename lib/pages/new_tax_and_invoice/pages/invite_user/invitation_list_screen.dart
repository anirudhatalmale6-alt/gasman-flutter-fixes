import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invite_user/accept_invite_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import 'team_provider.dart';

class InvitationListScreen extends StatefulWidget {
  static const route = "/invitations";

  const InvitationListScreen({super.key});

  @override
  State<InvitationListScreen> createState() => _InvitationListScreenState();
}

class _InvitationListScreenState extends State<InvitationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeamProvider>().getInvitations());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Invitations"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.invitations.isEmpty
              ? const Center(child: Text("No pending invitations"))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.invitations.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final invite = provider.invitations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                        leading: const Icon(Icons.mail_outline),

                        title: Text(invite.email ?? ""),

                        subtitle: const Text(
                          "Pending",
                          style: TextStyle(fontSize: 12),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                push(AcceptInviteScreen(inviteCode: invite.inviteCode,));
                              },
                              child: const Text("Accept"),
                            ),

                            TextButton(
                              onPressed: () async {
                                await provider.cancelInvitation(invite.id!.toString());

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cancelled")),
                                );
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
