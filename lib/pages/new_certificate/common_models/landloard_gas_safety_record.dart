/*import 'gas_appliance_entry.dart';

class LandlordGasSafetyRecord {
  final String id;
  String certificateNumber;

  // Landlord & property
  String landlordName;
  String landlordAddress;
  String landlordPostcode;
  String landlordPhone;
  String landlordEmail;

  String tenantName;
  String propertyAddress;
  String propertyPostcode;

  DateTime inspectionDate;
  DateTime nextInspectionDate;

  // Pipework / tightness
  bool pipeworkVisualOk;
  bool pipeworkSecure;
  bool tightnessTestDone;
  String standingPressure;
  String workingPressure;
  String letByResult;
  String tightnessDrop;

  // Flue / chimney
  bool flueConditionOk;
  bool flueTerminationOk;
  String flueNotes;

  // Defects & actions
  DefectClassification defectClass;
  String unsafeDetails;
  String actionsTaken;
  String adviceGiven;

  // Engineer
  String engineerName;
  String engineerGasSafeNo;
  String engineerCompanyName;
  String engineerCompanyAddress;
  String engineerCompanyPostcode;
  String engineerCompanyPhone;
  String engineerCompanyEmail;

  // Signatures (you will store image bytes or paths in real app)
  // For now just booleans / placeholders.
  bool engineerSigned;
  bool landlordSigned;

  List<GasApplianceEntry> appliances;

  LandlordGasSafetyRecord({
    required this.id,
    required this.certificateNumber,
    this.landlordName = '',
    this.landlordAddress = '',
    this.landlordPostcode = '',
    this.landlordPhone = '',
    this.landlordEmail = '',
    this.tenantName = '',
    this.propertyAddress = '',
    this.propertyPostcode = '',
    DateTime? inspectionDate,
    DateTime? nextInspectionDate,
    this.pipeworkVisualOk = true,
    this.pipeworkSecure = true,
    this.tightnessTestDone = true,
    this.standingPressure = '',
    this.workingPressure = '',
    this.letByResult = '',
    this.tightnessDrop = '',
    this.flueConditionOk = true,
    this.flueTerminationOk = true,
    this.flueNotes = '',
    this.defectClass = DefectClassification.none,
    this.unsafeDetails = '',
    this.actionsTaken = '',
    this.adviceGiven = '',
    this.engineerName = '',
    this.engineerGasSafeNo = '',
    this.engineerCompanyName = '',
    this.engineerCompanyAddress = '',
    this.engineerCompanyPostcode = '',
    this.engineerCompanyPhone = '',
    this.engineerCompanyEmail = '',
    this.engineerSigned = false,
    this.landlordSigned = false,
    List<GasApplianceEntry>? appliances,
  })  : inspectionDate = inspectionDate ?? DateTime.now(),
        nextInspectionDate =
            nextInspectionDate ?? DateTime.now().add(const Duration(days: 365)),
        appliances = appliances ?? [GasApplianceEntry()];
}*/

