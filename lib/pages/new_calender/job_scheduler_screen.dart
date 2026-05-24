import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../services/job_service.dart';
import '../../utils_class/utils.dart';
import 'job_form_screen.dart';

class JobSchedulerScreen extends StatefulWidget {
  const JobSchedulerScreen({super.key});

  @override
  State<JobSchedulerScreen> createState() => _JobSchedulerScreenState();
}

class _JobSchedulerScreenState extends State<JobSchedulerScreen> {
  final JobService _svc = JobService();

  bool loading = true;

  List<dynamic> jobs = [];

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      final now = DateTime.now();

      final from = DateTime(
        now.year,
        now.month,
        1,
      ).toIso8601String();

      final to = DateTime(
        now.year + 1,
        now.month,
        0,
        23,
        59,
      ).toIso8601String();

      jobs = await _svc.getJobs(
        dateFrom: from,
        dateTo: to,
      );
    } catch (e) {
      debugPrint("Failed to load jobs: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> onDragEnd(
    AppointmentDragEndDetails details,
  ) async {
    final appointment = details.appointment as Appointment;

    final newStart = details.droppingTime;

    if (newStart == null) return;

    final duration = appointment.endTime.difference(appointment.startTime);

    final newEnd = newStart.add(duration);

    await _svc.rescheduleJob(
      id: appointment.id as int,
      startTime: newStart,
      endTime: newEnd,
    );

    await load();
  }

  Color parseColour(String hex) {
    final clean = hex.replaceAll("#", "");

    return Color(
      int.parse("FF$clean", radix: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
     final appointments = <Appointment>[];
    for (final j in jobs) {
      try {
        final start =
            DateTime.tryParse(j["start_time"] ?? "") ?? DateTime.now();
        final end = j["end_time"] != null
            ? (DateTime.tryParse(j["end_time"]) ??
                start.add(const Duration(hours: 1)))
            : start.add(const Duration(hours: 1));

        appointments.add(Appointment(
          id: j["id"],
          startTime: start,
          endTime: end,
          subject: j["title"]?.toString() ?? "Job",
          notes: j["customer_name"]?.toString() ?? "",
          color: parseColour(j["engineer_colour"]?.toString() ?? "#2563EB"),
        ));
      } catch (_) {}
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Scheduler"),
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
          : SfCalendar(
              view: CalendarView.week,
              allowDragAndDrop: true,
              dataSource: JobCalendarDataSource(
                appointments,
              ),
              onDragEnd: onDragEnd,
              onTap: (calenderTaDetails) async {
                if (calenderTaDetails.appointments != null &&
                    calenderTaDetails.appointments!.isNotEmpty) {
                  final Appointment appointment =
                      calenderTaDetails.appointments!.first as Appointment;
                  try {
                    Utils.showLoading();
                    dynamic jobItem = await _svc.getJobInfo(
                        jobId: int.parse(appointment.id.toString()));
                    Utils.hideLoading();
                    push(JobFormScreen(
                      job: jobItem,
                    ));
                  } on Exception catch (e) {
                    Utils.hideLoading();
                    // TODO
                  }
                } else {
                  push(JobFormScreen(
                    initialDate: calenderTaDetails.date,
                  ));
                }
              },
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 5,
                endHour: 24,
                timeIntervalHeight: 70,
              ),
            ),
    );
  }

  List<Appointment> generateAppointments() {
    final appointments = <Appointment>[];

    for (final j in jobs) {
      try {
        final start =
            DateTime.tryParse(j["start_time"] ?? "") ?? DateTime.now();

        final end = j["end_time"] != null
            ? (DateTime.tryParse(j["end_time"]) ??
                start.add(const Duration(hours: 1)))
            : start.add(const Duration(hours: 1));

        final recurrence = j["recurrence"]?.toString().toLowerCase();

        /// CREATE MAIN APPOINTMENT
        appointments.add(
          Appointment(
            id: j["id"],
            startTime: start,
            endTime: end,
            subject: j["title"]?.toString() ?? "Job",
            notes: j["customer_name"]?.toString() ?? "",
            color: parseColour(
              j["engineer_colour"]?.toString() ?? "#2563EB",
            ),
          ),
        );

        /// GENERATE RECURRING APPOINTMENTS
        if (recurrence == "weekly") {
          for (int i = 1; i <= 52; i++) {
            appointments.add(
              Appointment(
                id: "${j["id"]}_w_$i",
                startTime: start.add(
                  Duration(days: 7 * i),
                ),
                endTime: end.add(
                  Duration(days: 7 * i),
                ),
                subject: j["title"]?.toString() ?? "Job",
                notes: j["customer_name"]?.toString() ?? "",
                color: parseColour(
                  j["engineer_colour"]?.toString() ?? "#2563EB",
                ),
              ),
            );
          }
        } else if (recurrence == "monthly") {
          for (int i = 1; i <= 24; i++) {
            appointments.add(
              Appointment(
                id: "${j["id"]}_m_$i",
                startTime: DateTime(
                  start.year,
                  start.month + i,
                  start.day,
                  start.hour,
                  start.minute,
                ),
                endTime: DateTime(
                  end.year,
                  end.month + i,
                  end.day,
                  end.hour,
                  end.minute,
                ),
                subject: j["title"]?.toString() ?? "Job",
                notes: j["customer_name"]?.toString() ?? "",
                color: parseColour(
                  j["engineer_colour"]?.toString() ?? "#2563EB",
                ),
              ),
            );
          }
        } else if (recurrence == "yearly") {
          for (int i = 1; i <= 10; i++) {
            appointments.add(
              Appointment(
                id: "${j["id"]}_y_$i",
                startTime: DateTime(
                  start.year + i,
                  start.month,
                  start.day,
                  start.hour,
                  start.minute,
                ),
                endTime: DateTime(
                  end.year + i,
                  end.month,
                  end.day,
                  end.hour,
                  end.minute,
                ),
                subject: j["title"]?.toString() ?? "Job",
                notes: j["customer_name"]?.toString() ?? "",
                color: parseColour(
                  j["engineer_colour"]?.toString() ?? "#2563EB",
                ),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return appointments;
  }
}

class JobCalendarDataSource extends CalendarDataSource {
  JobCalendarDataSource(
    List<Appointment> appointments,
  ) {
    this.appointments = appointments;
  }
}
