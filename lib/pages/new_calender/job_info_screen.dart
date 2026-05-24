import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobInfoScreen extends StatelessWidget {
  final Map item;

  const JobInfoScreen({
    super.key,
    required this.item,
  });

  Color hexToColor(String hex) {
    return Color(
      int.parse(
        hex.replaceFirst('#', '0xFF'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engineer = item["engineer"];
    final nextJob = item["nextJob"];
    final jobsToday = item["jobsToday"] ?? [];

    final engineerColor =
    hexToColor(engineer["colour"] ?? "#2563EB");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Engineer Jobs"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Engineer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: engineerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: engineerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: engineerColor,
                    child: Text(
                      engineer["name"][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          engineer["name"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(engineer["email"]),

                        const SizedBox(height: 4),

                        Text(engineer["phone"]),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Status
            Row(
              children: [
                const Icon(Icons.circle,
                    color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text(
                  "Status: ${item["status"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Next Job
            if (nextJob != null) ...[
              const Text(
                "Next Job",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextJob["title"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                            "Customer: ${nextJob["customer_name"]}"),

                        Text(
                            "Type: ${nextJob["job_type"]}"),

                        Text(
                            "Address: ${nextJob["address"]}"),

                        Text(
                            "Status: ${nextJob["status"]}"),

                        const SizedBox(height: 10),

                        Text(
                          "Start: ${DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(nextJob["start_time"]))}",
                        ),

                        Text(
                          "End: ${DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(nextJob["end_time"]))}",
                        ),

                        const SizedBox(height: 10),

                        Text(
                          nextJob["description"] ?? "",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// Today's Jobs
            const Text(
              "Today's Jobs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...jobsToday.map<Widget>((job) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: engineerColor,
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(job["title"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(job["customer_name"] ?? ""),
                      Text(job["address"] ?? ""),
                    ],
                  ),
                  trailing: Text(
                    job["status"] ?? "",
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}