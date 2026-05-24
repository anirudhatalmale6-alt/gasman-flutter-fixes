import 'package:flutter/material.dart';
import '../../../../services/employee_service.dart';
import '../../../../utils_class/dialog_utils.dart';
import 'create_employee_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeService _svc = EmployeeService();
  final TextEditingController _search = TextEditingController();

  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _svc.getEmployees(search: _search.text);
    } catch (e) {
      debugPrint("Failed to load employees: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void deleteEmployee(int id) async {
    final success = await DialogUtils.showDeleteDialog(
      context: context,
      itemName: "Employee",
      onDelete: () async {
        await _svc.deleteEmployee(id: id);
        _load();
      },
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee deleted")),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _employeeTile(dynamic e) {
    final name =
    "${e["first_name"] ?? ""} ${e["last_name"] ?? ""}".trim();
    final email = e["email"] ?? "";
    final phone = e["phone"] ?? "";
    final job = e["job_title"] ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "E",
          ),
        ),
        title: Text(
          name.isEmpty ? "Employee" : name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [job, email, phone]
                .where((e) => e.toString().isNotEmpty)
                .join(" • "),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeNewScreen(
                      employeeDetails: e,
                    ),
                  ),
                );
                _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteEmployee(e["id"]),
            ),
          ],
        ),
        onTap: () {
          Navigator.pop(context, e["id"]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeNewScreen(),
                ),
              );
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: "Search employees",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),

          // 📋 List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? const Center(child: Text("No employees found"))
                  : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) =>
                    _employeeTile(_items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}