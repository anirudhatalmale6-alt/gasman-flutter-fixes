import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app/app_model.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import '../new_certificate/home_owner_gst/home_owner_gst_new_page.dart';
import '../new_certificate/landloard_gst_safety_page/landloard_gas_safety_page.dart';
import 'job_form_screen.dart';

class JobCalendarScreen extends StatefulWidget {
  const JobCalendarScreen({super.key});

  @override
  State<JobCalendarScreen> createState() => _JobCalendarScreenState();
}

class _JobCalendarScreenState extends State<JobCalendarScreen> {
  final JobService _svc = JobService();

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  bool loading = true;
  List<dynamic> jobs = [];

  var height12 = SizedBox(
    height: 12.0,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<AppModel>(context, listen: false).load();
    });
    loadJobs();
  }

  Future<void> loadJobs() async {
    setState(() => loading = true);

    try {
      final from =
          DateTime(focusedDay.year, focusedDay.month, 1).toIso8601String();
      final to = DateTime(focusedDay.year, focusedDay.month + 1, 0, 23, 59)
          .toIso8601String();

      jobs = await _svc.getJobs(dateFrom: from, dateTo: to);
    } catch (e) {
      debugPrint("Failed to load jobs: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  List<dynamic> jobsForDay(DateTime day) {
    final appModel = context.read<AppModel>();
    final List<dynamic> events = [];

    bool isSameReminderDate(String? date) {
      if (date == null || date.isEmpty) return false;

      DateTime? reminder;

      try {
        // yyyy-MM-dd OR ISO format
        reminder = DateTime.parse(date);
      } catch (e) {
        try {
          // dd/MM/yyyy format
          final parts = date.split('/');

          if (parts.length == 3) {
            reminder = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        } catch (_) {
          return false;
        }
      }

      return reminder!.year == day.year &&
          reminder.month == day.month &&
          reminder.day == day.day;
    }

    // Jobs
    events.addAll(
      jobs.where((j) {
        final start = DateTime.parse(j["start_time"]);

        return start.year == day.year &&
            start.month == day.month &&
            start.day == day.day;
      }),
    );

    // Homeowner Gas Safety Records
    events.addAll(
      appModel.allHomeRecords.where(
        (r) => isSameReminderDate(r.reminderDate),
      ),
    );

    // Service Records
    events.addAll(
      appModel.allServiceRecords.where(
        (r) => isSameReminderDate(r.reminderDate),
      ),
    );

    // Landlord Gas Safety Records
    events.addAll(
      appModel.allLandloardRecrds.where(
        (r) => isSameReminderDate(r.reminderDate),
      ),
    );

    return events;
  }

  List<dynamic> jobListForDay(DateTime day) {
    return jobs.where((j) {
      final start = DateTime.parse(j["start_time"]);
      return start.year == day.year &&
          start.month == day.month &&
          start.day == day.day;
    }).toList();
  }

  Future<void> openNewJob() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => JobFormScreen(initialDate: selectedDay)),
    );
    loadJobs();
  }

  Future<void> openEditJob(dynamic job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => JobFormScreen(job: Map<String, dynamic>.from(job))),
    );
    loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final dayJobs = jobListForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Calendar"),
        actions: [
          IconButton(onPressed: openNewJob, icon: const Icon(Icons.add)),
          IconButton(onPressed: loadJobs, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2035),
              focusedDay: focusedDay,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              eventLoader: jobsForDay,
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selected, focused) async {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
                await app.getHomeOwnerCertificateList(selected);
                await app.getServiceRecordList(selected);
                await app.getLandloardCertificates(selected);
              },
              onPageChanged: (focused) {
                focusedDay = focused;
                loadJobs();
              },
            ),
            const Divider(height: 10),
            loading
                ? const Center(child: CircularProgressIndicator())
                : dayJobs.isEmpty
                    ? Container(
                        width: double.infinity,
                        height: 50.0,
                        child: Center(
                          child: Text("No jobs found"),
                        ))
                    : ListView.separated(
                        itemCount: dayJobs.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final job = dayJobs[i];
                          final start = DateTime.parse(job["start_time"]);

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => openEditJob(job),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job["title"] ?? "Job",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
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
                                                  job["customer_name"] ??
                                                      "Unknown Customer",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 14,
                                                      color: Colors.orange,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  job["status"] ?? "Pending",
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            if (app.homeRecords.isNotEmpty) ...[
              height12,
              getTitle('Home Service Records'),
              ListView.builder(
                itemCount: app.homeRecords.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final record = app.homeRecords[index];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(record.homeownerName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Address: ${record.homeownerAddress}"),
                          Text("Postcode: ${record.homeownerPostcode}"),
                          Text("Certificate: ${record.certificateNumber}"),

                          /// ✅ INSPECTION DATE
                          Text(
                              "Reminder Date: ${formatDate(record.reminderDate)}"),
                        ],
                      ),

                      /// ✅ ACTION BUTTONS (FIXED INDEX)
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final originalIndex =
                                  app.homeRecords.indexOf(record);
                              goToEdit(originalIndex);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final originalIndex =
                                  app.homeRecords.indexOf(record);
                              app.deleteHomeRecord(originalIndex);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
            if (app.landloardRecrds.isNotEmpty) ...[
              height12,
              getTitle('Landloard Service Records'),
              ListView.builder(
                itemCount: app.landloardRecrds.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final record = app.landloardRecrds[index];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(record.landlordName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Property: ${record.propertyAddress}"),
                          Text("Reminder Date: ${record.reminderDate}"),
                          Text("Certificate: ${record.certificateNumber}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => goToLandLoardEdit(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              app.deleteLandloardGasRecord(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
            if (app.serviceRecords.isNotEmpty) ...[
              height12,
              getTitle('Gas Service Records'),
              ListView.builder(
                itemCount: app.serviceRecords.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final record = app.serviceRecords[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(
                        record.recordNumber.isNotEmpty
                            ? record.recordNumber
                            : "No Record Number",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Customer: ${record.customerName}"),
                          Text("Property: ${record.propertyAddress}"),
                          Text(
                              "Reminder Date: ${formatDate(record.reminderDate)}"),
                          Text("Appliances: ${record.appliances.length}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final originalIndex =
                                  app.serviceRecords.indexOf(record);
                              goToServiceEdit(originalIndex);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final originalIndex =
                                  app.serviceRecords.indexOf(record);
                              app.deleteServiceRecord(originalIndex);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        final originalIndex =
                            app.serviceRecords.indexOf(record);
                        goToServiceEdit(originalIndex);
                      },
                    ),
                  );
                },
              )
            ],
            SizedBox(
              height: 100.0,
            )
          ],
        ),
      ),
    );
  }

  getTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 12.0),
        color: AppColors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            '$title',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> goToEdit(int originalIndex) async {
    final app = Provider.of<AppModel>(context, listen: false);
    final record = app.homeRecords[originalIndex];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeownerGasSafetyNewPage(
          record: record,
        ),
      ),
    );
    // app.getHomeOwnerCertificateList();
  }

  Future<void> goToServiceEdit(int originalIndex) async {
    final app = Provider.of<AppModel>(context, listen: false);
    final record = app.landloardRecrds[originalIndex];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordGasSafetyPage(
          record: record,
        ),
      ),
    );

    //  app.getHomeOwnerCertificateList();
  }

  Future<void> goToLandLoardEdit(int originalIndex) async {
    final app = Provider.of<AppModel>(context, listen: false);
    final record = app.landloardRecrds[originalIndex];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordGasSafetyPage(
          record: record,
        ),
      ),
    );

    //  app.getHomeOwnerCertificateList();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
