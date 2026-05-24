import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_models/summary_data.dart';
import 'deduction_list_screen.dart';
import 'returns_screen.dart';
import 'subcontractor_list_screen.dart';
import 'view_models/dashboard_vm.dart';



class CisDashboardScreen extends StatelessWidget {
  const CisDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardVM()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text("CIS Dashboard"), actions: [
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: "Refresh",
                onPressed: () {
                  context.read<DashboardVM>().load();
                },
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],),
        body: Consumer<DashboardVM>(
          builder: (_, vm, __) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 👷 Subcontractor Card
                  _clickableCard(
                    context,
                    child: _kpiCard("Subcontractors", vm.count.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubcontractorListScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 💰 This Month
                    _clickableCard(
                      context,
                      child: _summaryCard("This Month", vm.currentMonth),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeductionListScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

                    // 📊 Year to Date
                    _clickableCard(
                      context,
                      child: _summaryCard("Year to Date", vm.ytd),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeductionListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                  const SizedBox(height: 12),

                  // ⚠️ Pending Returns
                  if (vm.pendingReturns > 0)
                    _clickableCard(
                      context,
                      child: _alertCard("${vm.pendingReturns} returns pending"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturnsScreen(),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // ⚡ Quick Actions
                  _quickActions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- CLICK WRAPPER ----------------

  Widget _clickableCard(
      BuildContext context, {
        required Widget child,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: child,
    );
  }

  // ---------------- KPI CARD ----------------

  Widget _kpiCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------- SUMMARY CARD ----------------

  Widget _summaryCard(String title, Summary s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Gross: £${s.gross}"),
            Text("Deductions: £${s.deductions}"),
            Text("Net: £${s.net}"),
          ],
        ),
      ),
    );
  }

  // ---------------- ALERT CARD ----------------

  Widget _alertCard(String text) {
    return Card(
      color: Colors.orange.shade100,
      child: const ListTile(
        leading: Icon(Icons.warning),
        title: Text("Pending Returns"),
      ),
    );
  }

  // ---------------- QUICK ACTIONS ----------------

  Widget _quickActions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Add Subcontractor"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubcontractorListScreen(), // or form screen
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("View Returns"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReturnsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Statements"),
            onTap: () {
              // You can navigate to a selector screen or last viewed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Select subcontractor first")),
              );
            },
          ),
        ],
      ),
    );
  }
}