import 'package:flutter/material.dart';

import '../../services/team_service.dart';




class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final TeamService _svc = TeamService();

  bool loading = true;
  List<dynamic> members = [];

  final roles = ["owner", "admin", "engineer", "accountant"];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      members = await _svc.getTeamMembers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Color roleColor(String role) {
    switch (role) {
      case "owner":
        return Colors.purple;
      case "admin":
        return Colors.blue;
      case "engineer":
        return Colors.green;
      case "accountant":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData roleIcon(String role) {
    switch (role) {
      case "owner":
        return Icons.star;
      case "admin":
        return Icons.admin_panel_settings;
      case "engineer":
        return Icons.engineering;
      case "accountant":
        return Icons.calculate;
      default:
        return Icons.person;
    }
  }

  Future<void> _showInviteDialog() async {
    final emailCtrl = TextEditingController();
    String selectedRole = "engineer";

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Invite Team Member"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email *",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                    items: roles.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r[0].toUpperCase() + r.substring(1)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setDialogState(() => selectedRole = v!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (emailCtrl.text.trim().isEmpty) return;
                    try {
                      await _svc.inviteMember(
                        email: emailCtrl.text.trim(),
                        role: selectedRole,
                      );
                      Navigator.pop(ctx, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Invite"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) await load();
  }

  Future<void> _editMember(Map member) async {
    String role = member["role"] ?? "engineer";
    bool isActive = member["is_active"] ?? true;

    final nameController =
    TextEditingController(text: member["name"] ?? "");

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Member"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// NAME
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ROLE
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                      items: roles.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(
                            r[0].toUpperCase() + r.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setDialogState(() => role = v!);
                      },
                    ),

                    const SizedBox(height: 12),

                    /// ACTIVE
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Active"),
                      value: isActive,
                      onChanged: (v) {
                        setDialogState(() => isActive = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _svc.updateMember(
                        id: member["id"],
                        name: nameController.text.trim(),
                        role: role,
                        isActive: isActive,
                      );

                      Navigator.pop(ctx, true);
                    } catch (e) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      });
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

   // nameController.dispose();

    if (result == true) await load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team"),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteDialog,
        child: const Icon(Icons.person_add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text("No team members yet"))
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (_, i) {
          final m = members[i];
          final role = m["role"] ?? "engineer";
          final active = m["is_active"] ?? true;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                textColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                splashColor:
                roleColor(role).withOpacity(0.08),

                tileColor: Colors.white,

                leading: CircleAvatar(
                  backgroundColor: roleColor(role),

                  child: Icon(
                    roleIcon(role),
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  "${m["name"] ?? 'User'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),

                      decoration: BoxDecoration(
                        color:
                        roleColor(role).withOpacity(0.12),

                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Text(
                        role.toUpperCase(),

                        style: TextStyle(
                          color: roleColor(role),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (!active)

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),

                        decoration: BoxDecoration(
                          color:
                          Colors.red.withOpacity(0.12),

                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        child: const Text(
                          "INACTIVE",

                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.edit),

                  onPressed: () => _editMember(m),
                ),

                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}