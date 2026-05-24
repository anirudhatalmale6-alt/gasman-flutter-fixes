import 'appliance_check.dart';

class LandlordGasSafety {
  // Minimal set; expand as needed
  String landlord;
  String propertyAddress;
  String tenant;
  DateTime dateOfIssue;
  DateTime nextInspectionDue;
  List<ApplianceCheck> appliances;
  String comments;

  LandlordGasSafety({
    required this.landlord,
    required this.propertyAddress,
    required this.tenant,
    required this.dateOfIssue,
    required this.nextInspectionDue,
    required this.appliances,
    required this.comments,
  });
}
