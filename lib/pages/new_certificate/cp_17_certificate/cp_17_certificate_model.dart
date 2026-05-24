class Cp17Certificate {
  int? id;

  String certificateRef;
  String certificateNumber;
  final String inspectionDate;
  final String nextInspectionDue;
  final String reminderDate;

  String siteName;
  String siteAddress;
  String clientName;
  String responsiblePerson;

  String engineerName;
  String gasSafeNumber;
  String companyName;
  String companyAddress;
  String companyPhone;
  String engineerEmail;

  String gasType;
  String meterLocation;
  String emergencyControlLocation;

  bool tightnessTestCompleted;
  String tightnessTestResult;

  bool emergencyControlsAccessible;
  bool ventilationSatisfactory;
  bool fluesSatisfactory;
  bool appliancesSecure;
  bool warningNoticesPresent;

  String defectClassification; // Safe, AR, ID
  String defectDetails;
  String actionTaken;

  String observations;
  String recommendations;

  String engineerSignatureBase64;
  String customerSignatureBase64;

  bool locked;

  Cp17Certificate({
    this.id,
    required this.certificateRef,
    required this.certificateNumber,
    required this.inspectionDate,
    required this.nextInspectionDue,
    required this.reminderDate,
    this.siteName = '',
    this.siteAddress = '',
    this.clientName = '',
    this.responsiblePerson = '',
    this.engineerName = '',
    this.gasSafeNumber = '',
    this.companyName = '',
    this.companyAddress = '',
    this.companyPhone = '',
    this.engineerEmail = '',
    this.gasType = 'Natural Gas',
    this.meterLocation = '',
    this.emergencyControlLocation = '',
    this.tightnessTestCompleted = false,
    this.tightnessTestResult = 'Pass',
    this.emergencyControlsAccessible = false,
    this.ventilationSatisfactory = false,
    this.fluesSatisfactory = false,
    this.appliancesSecure = false,
    this.warningNoticesPresent = false,
    this.defectClassification = 'Safe',
    this.defectDetails = '',
    this.actionTaken = '',
    this.observations = '',
    this.recommendations = '',
    this.engineerSignatureBase64 = '',
    this.customerSignatureBase64 = '',
    this.locked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'certificateRef': certificateRef,
      'certificateNumber': certificateNumber,
      'inspectionDate': inspectionDate,
      'nextInspectionDue': nextInspectionDue,
      'reminderDate': reminderDate,
      'siteName': siteName,
      'siteAddress': siteAddress,
      'clientName': clientName,
      'responsiblePerson': responsiblePerson,
      'engineerName': engineerName,
      'gasSafeNumber': gasSafeNumber,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'engineerEmail': engineerEmail,
      'gasType': gasType,
      'meterLocation': meterLocation,
      'emergencyControlLocation': emergencyControlLocation,
      'tightnessTestCompleted': tightnessTestCompleted,
      'tightnessTestResult': tightnessTestResult,
      'emergencyControlsAccessible': emergencyControlsAccessible,
      'ventilationSatisfactory': ventilationSatisfactory,
      'fluesSatisfactory': fluesSatisfactory,
      'appliancesSecure': appliancesSecure,
      'warningNoticesPresent': warningNoticesPresent,
      'defectClassification': defectClassification,
      'defectDetails': defectDetails,
      'actionTaken': actionTaken,
      'observations': observations,
      'recommendations': recommendations,
      'engineerSignatureBase64': engineerSignatureBase64,
      'customerSignatureBase64': customerSignatureBase64,
      'locked': locked,
    };
  }

  factory Cp17Certificate.fromMap(Map<String, dynamic> map) {
    return Cp17Certificate(
      id: map['id'],
      certificateRef: map['certificateRef'] ?? '',
      certificateNumber: map['certificateNumber'] ?? '',
      inspectionDate: map['inspectionDate'] ?? '',
      nextInspectionDue: map['nextInspectionDue'] ?? '',
      reminderDate: map['reminderDate'] ?? '',
      siteName: map['siteName'] ?? '',
      siteAddress: map['siteAddress'] ?? '',
      clientName: map['clientName'] ?? '',
      responsiblePerson: map['responsiblePerson'] ?? '',
      engineerName: map['engineerName'] ?? '',
      gasSafeNumber: map['gasSafeNumber'] ?? '',
      companyName: map['companyName'] ?? '',
      companyAddress: map['companyAddress'] ?? '',
      companyPhone: map['companyPhone'] ?? '',
      engineerEmail: map['engineerEmail'] ?? '',
      gasType: map['gasType'] ?? 'Natural Gas',
      meterLocation: map['meterLocation'] ?? '',
      emergencyControlLocation: map['emergencyControlLocation'] ?? '',
      tightnessTestCompleted: map['tightnessTestCompleted'] ?? false,
      tightnessTestResult: map['tightnessTestResult'] ?? 'Pass',
      emergencyControlsAccessible: map['emergencyControlsAccessible'] ?? false,
      ventilationSatisfactory: map['ventilationSatisfactory'] ?? false,
      fluesSatisfactory: map['fluesSatisfactory'] ?? false,
      appliancesSecure: map['appliancesSecure'] ?? false,
      warningNoticesPresent: map['warningNoticesPresent'] ?? false,
      defectClassification: map['defectClassification'] ?? 'Safe',
      defectDetails: map['defectDetails'] ?? '',
      actionTaken: map['actionTaken'] ?? '',
      observations: map['observations'] ?? '',
      recommendations: map['recommendations'] ?? '',
      engineerSignatureBase64: map['engineerSignatureBase64'] ?? '',
      customerSignatureBase64: map['customerSignatureBase64'] ?? '',
      locked: map['locked'] ?? false,
    );
  }

  bool get isAtRisk => defectClassification == 'AR';

  bool get isImmediatelyDangerous => defectClassification == 'ID';

  bool get isUnsafe => isAtRisk || isImmediatelyDangerous;

  bool get hasSignatures =>
      engineerSignatureBase64.isNotEmpty &&
          customerSignatureBase64.isNotEmpty;

  bool get safetyChecksComplete =>
      emergencyControlsAccessible &&
          ventilationSatisfactory &&
          fluesSatisfactory &&
          appliancesSecure;

  bool get hasRequiredUnsafeInfo {
    if (!isUnsafe) return true;
    return defectDetails.isNotEmpty && actionTaken.isNotEmpty;
  }

  bool get canLock {
    if (!hasSignatures) return false;
    if (!safetyChecksComplete) return false;
    if (!hasRequiredUnsafeInfo) return false;
    return true;
  }
}





