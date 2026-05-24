import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_calender/job_form_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../services/job_service.dart';

class UpcomingJobsScreen extends StatefulWidget {
  const UpcomingJobsScreen({super.key});

  @override
  State<UpcomingJobsScreen> createState() => _UpcomingJobsScreenState();
}

class _UpcomingJobsScreenState extends State<UpcomingJobsScreen> {
  final JobService _svc = JobService();

  bool loading = true;
  List<dynamic> jobs = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    jobs = await _svc.getUpcomingJobs();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Jobs"),

      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Upcoming Jobs", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (jobs.isEmpty)
                const Text("No upcoming jobs")
              else
                ...jobs.take(5).map((job) {
                  final start = DateTime.parse(job["start_time"]);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        // Open Job Details
                        push(JobFormScreen(job: job,));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Colors.indigo,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    job["title"] ?? "Job",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      ),

                                      const SizedBox(width: 4),

                                      Expanded(
                                        child: Text(
                                          job["customer_name"] ?? "Unknown Customer",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        const Icon(
                                          Icons.access_time,
                                          size: 15,
                                          color: Colors.orange,
                                        ),

                                        const SizedBox(width: 6),

                                        Text(
                                          "${start.day}/${start.month}/${start.year}  "
                                              "${start.hour.toString().padLeft(2, '0')}:"
                                              "${start.minute.toString().padLeft(2, '0')}",
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            // const Icon(
                            //   Icons.chevron_right,
                            //   color: Colors.grey,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

