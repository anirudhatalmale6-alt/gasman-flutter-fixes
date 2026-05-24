import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invite_user/accept_invite_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invite_user/invitation_list_screen.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'team_provider.dart';

class TeamScreen extends StatefulWidget {
  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TeamProvider>().loadData(),
    );
  }

  void _showInviteDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return Consumer<TeamProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              title: const Text("Invite Accountant"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter email",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          await provider.invite(controller.text);
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Invite"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Members"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(), // 👈 fully rounded
              backgroundColor: AppColors.kChartVatSales,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              push(InvitationListScreen());
            },
            child: const Text(
              "Pending",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteDialog,
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.members.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: provider.loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.members.length,
                    itemBuilder: (context, index) {
                      final m = provider.members[index];

                      return _memberCard(
                        email: m.email!,
                        onDelete: () => provider.removeMember(m.id!.toString()),
                      );
                    },
                  ),
                ),
    );
  }

  // 🌟 Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No Team Members",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Invite accountants to manage your business",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.add),
            label: const Text("Invite Accountant"),
          )
        ],
      ),
    );
  }

  // 💎 Beautiful Member Card
  Widget _memberCard({
    required String email,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          email,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text("Accountant"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
