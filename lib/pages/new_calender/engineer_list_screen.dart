import 'package:flutter/material.dart';

import '../../services/engineer_service.dart';

class EngineerListScreen extends StatefulWidget {
  const EngineerListScreen({super.key});

  @override
  State<EngineerListScreen> createState() => _EngineerListScreenState();
}

class _EngineerListScreenState extends State<EngineerListScreen> {
  final EngineerService _svc = EngineerService();

  bool loading = true;
  List<dynamic> engineers = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    engineers = await _svc.getEngineers();
    if (mounted) setState(() => loading = false);
  }

  Future<void> addEngineer() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Engineer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    );

    if (ok != true || name.text.trim().isEmpty) return;

    await _svc.createEngineer(
      name: name.text.trim(),
      email: email.text.trim(),
      phone: phone.text.trim(),
    );

    await load();
  }

  Color parseColour(String hex) {
    final clean = hex.replaceAll("#", "");
    return Color(int.parse("FF$clean", radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Engineers"),
        actions: [
          IconButton(onPressed: addEngineer, icon: const Icon(Icons.add)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: engineers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = engineers[i];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: parseColour(e["colour"] ?? "#2563EB"),
              child: Text(
                (e["name"] ?? "E").toString().substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(e["name"] ?? "Engineer"),
            subtitle: Text(
              [
                e["email"] ?? "",
                e["phone"] ?? "",
              ].where((x) => x.toString().isNotEmpty).join(" • "),
            ),
          );
        },
      ),
    );
  }
}

