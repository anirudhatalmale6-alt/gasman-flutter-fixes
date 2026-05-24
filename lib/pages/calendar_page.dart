/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/pages/new_certificate/landloard_gst_safety_page/landloard_gas_safety_page.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import '../models/job.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils_class/dialog_utils.dart';
import 'new_certificate/home_owner_gst/home_owner_gst_new_page.dart';

class CalendarPage extends StatefulWidget {
  static const route = '/calendar';

  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      //Provider.of<AppModel>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final upcoming = app.upcoming(days: 90);

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs & Calendar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newJobDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TableCalendar<Job>(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focused,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            selectedDayPredicate: (d) =>
                _selected != null && isSameDay(_selected, d),
            eventLoader: (day) => app.jobsOnDay(day),
            onDaySelected: (sel, foc) async {
              _selected = sel;
              _focused = foc;

              await app.getHomeOwnerCertificateList(sel);
              await app.getServiceRecordList(sel);
              await app.getLandloardCertificates(sel);

              // If using Provider / ChangeNotifier
              setState(() {});
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(.3),
                  shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 16),
          getTitle("Upcoming"),
          const SizedBox(height: 6),
          ...upcoming.map((j) => Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: Text(j.title),
                  onTap: () {
                    _newJobDialog(context, jobDetails: j); // 👈 edit on tap
                  },
                  subtitle: Text('${j.customer} • ${j.address}'),
                  trailing: SizedBox(
                    width: 170, // adjust if needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 📅 DATE
                        Expanded(
                          child: Text(
                            '${j.start.day}/${j.start.month} '
                            '${j.start.hour.toString().padLeft(2, '0')}:'
                            '${j.start.minute.toString().padLeft(2, '0')}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 6),

                        // ✏️ EDIT
                        GestureDetector(
                          onTap: () {
                            _newJobDialog(context, jobDetails: j);
                          },
                          child: const Icon(Icons.edit,
                              size: 18, color: Colors.blue),
                        ),

                        const SizedBox(width: 8),

                        // 🗑 DELETE
                      */
/*  GestureDetector(
                          onTap: () async {
                            final confirm = await DialogUtils.showDeleteDialog(
                              context: context,
                              itemName: j.title,
                              onDelete: () async {
                                app.jobs.removeWhere(
                                    (jobElement) => jobElement.id == j.id);
                                setState(() {});
                              },
                            );
                          },
                          child: const Icon(Icons.delete,
                              size: 18, color: Colors.red),
                        ),*//*

                      ],
                    ),
                  ),
                ),
              )),
          if (upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No upcoming jobs. Add one with the + button.'),
            ),
          if (app.homeRecords.isNotEmpty) ...[
            getTitle('Home Service Records'),
            ListView.builder(
              itemCount: app.homeRecords.length,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final record = app.homeRecords[index];

                return Card(
                  margin: const EdgeInsets.all(8),
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
            getTitle('Landloard Service Records'),
            ListView.builder(
              itemCount: app.landloardRecrds.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final record = app.landloardRecrds[index];

                return Card(
                  margin: const EdgeInsets.all(8),
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
            getTitle('Gas Service Records'),
            ListView.builder(
              itemCount: app.serviceRecords.length,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final record = app.serviceRecords[index];
                return Card(
                  margin: const EdgeInsets.all(8),
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
                      final originalIndex = app.serviceRecords.indexOf(record);
                      goToServiceEdit(originalIndex);
                    },
                  ),
                );
              },
            )
          ]
        ],
      ),
    );
  }

  Future<void> _newJobDialog(BuildContext context, {Job? jobDetails}) async {
    final title = TextEditingController();
    final customer = TextEditingController();
    final address = TextEditingController();
    final contactDetails = TextEditingController();
    DateTime start = DateTime.now().add(const Duration(days: 1, hours: 1));
    DateTime end = start.add(const Duration(hours: 1));
    final app = context.read<AppModel>();
    final id = const Uuid().v4();
    if (jobDetails != null) {
      title.text = jobDetails.title;
      customer.text = jobDetails.customer;
      address.text = jobDetails.address;
      contactDetails.text = jobDetails.notes;
      start = jobDetails.start;
      end = jobDetails.end;
    }

    await showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Add Job'),
              content: SingleChildScrollView(
                child: Column(children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: customer,
                      decoration: const InputDecoration(labelText: 'Customer')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: address,
                      decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: contactDetails,
                      decoration:
                          const InputDecoration(labelText: 'Contact Details')),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime(2035),
                            initialDate: start);
                        if (d != null) {
                          start = DateTime(
                              d.year, d.month, d.day, start.hour, start.minute);
                          end = start.add(
                              Duration(hours: end.difference(start).inHours));
                        }
                      },
                      child: const Text('Date'),
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(start));
                        if (t != null) {
                          start = DateTime(start.year, start.month, start.day,
                              t.hour, t.minute);
                          end = start.add(const Duration(hours: 1));
                        }
                      },
                      child: const Text('Time'),
                    )),
                  ])
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      if (jobDetails != null) {
                        jobDetails = Job(
                            id: jobDetails!.id,
                            title: title.text,
                            customer: customer.text,
                            address: address.text,
                            start: start,
                            end: end,
                            notes: contactDetails.text.trim());
                        app.updateJob(jobDetails!);
                      } else {
                        app.addJob(Job(
                            id: id,
                            title: title.text,
                            customer: customer.text,
                            address: address.text,
                            start: start,
                            end: end,
                            notes: contactDetails.text.trim()));
                      }

                      Navigator.pop(c);
                    },
                    child: const Text('Save')),
              ],
            ));
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

  /// ================= DATE FORMAT =================
  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  getTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 2,
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
}
*/
