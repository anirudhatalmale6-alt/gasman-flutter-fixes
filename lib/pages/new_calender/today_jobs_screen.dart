import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_calender/job_form_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../services/job_service.dart';

class TodayJobsScreen extends StatefulWidget {
  const TodayJobsScreen({super.key});

  @override
  State<TodayJobsScreen> createState() => _TodayJobsScreenState();
}

class _TodayJobsScreenState extends State<TodayJobsScreen> {
  final JobService _svc = JobService();

  bool loading = true;

  List<dynamic> jobs = [];

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() => loading = true);
    }
    try {
      jobs = await _svc.getTodayJobs();
    } catch (e) {
      debugPrint("Failed to load today's jobs: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      case "in_progress":
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Jobs"),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : jobs.isEmpty
              ? const Center(
                  child: Text(
                    "No jobs today",
                  ),
                )
              : ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (_, i) {
                    final job = jobs[i];

                    return Card(
                      margin: const EdgeInsets.all(5),
                      child: ListTile(
                        onTap: (){
                          push(JobFormScreen(job: job,));
                        },
                        leading: CircleAvatar(
                          backgroundColor: statusColor(
                            job["status"] ?? "scheduled",
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(job["title"]?.toString() ?? "Untitled Job"),
                        subtitle: Text(
                          "${job["customer_name"] ?? ""}\n"
                          "${job["address"] ?? ""}",
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
