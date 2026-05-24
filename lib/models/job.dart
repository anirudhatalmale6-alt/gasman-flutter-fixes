import 'package:the_gas_man_app/pages/new_certificate/gas_service_record/new_service_record_page.dart';
import 'package:the_gas_man_app/pages/new_certificate/home_owner_gst/home_owner_gst_new_page.dart';

import '../pages/new_certificate/landloard_gst_safety_page/landloard_gas_safety_page.dart';

class Job {
  final String id;
  final String title;
  final String customer;
  final String address;
  final DateTime start;
  final DateTime end;
  final String notes;

  Job({
    required this.id,
    required this.title,
    required this.customer,
    required this.address,
    required this.start,
    required this.end,
    required this.notes,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      customer: json['customer'],
      address: json['address'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customer': customer,
      'address': address,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'notes': notes,
    };
  }
}

sealed class CommonJobModel {}

class JobItem extends CommonJobModel {
  final Job job;

  JobItem(this.job);
}

class LandLoardItem extends CommonJobModel {
  final LandlordGasSafetyRecord landloardItem;

  LandLoardItem(this.landloardItem);
}

class HomeItem extends CommonJobModel {
  final HomeownerGasSafetyRecord homeRecord;

  HomeItem(this.homeRecord);
}

class ServiceItem extends CommonJobModel {
  final ServiceRecord serviceRecord;

  ServiceItem(this.serviceRecord);
}
