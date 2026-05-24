class Cp16Certificate {
  int? id;

  String certificateRef;
  String certificateNumber;
  final String inspectionDate;
  final String nextInspectionDue;
  final String reminderDate;

  String siteName;
  String siteAddress;
  String clientName;
  String contractorName;

  String engineerName;
  String gasSafeNumber;
  String companyName;
  String companyAddress;
  String companyPhone;
  String engineerEmail;

  String gasType;
  String pipeMaterial;
  String pipeSize;
  String installationLength;
  String installationVolume;

  String testMedium;

  String strengthTestPressure;
  String strengthTestDuration;
  String strengthPressureDrop;
  String strengthTestResult;

  String tightnessTestPressure;
  String tightnessStartPressure;
  String tightnessEndPressure;
  String tightnessStabilisationPeriod;
  String tightnessDuration;
  String tightnessPressureDrop;
  String tightnessResult;

  String purgeMethod;
  String purgeVolume;
  String purgePoint;
  String purgeVentLocation;
  String ventTerminationLocation;
  String gasDetectorUsed;
  String purgeSafetyPrecautions;

  bool riskAssessmentCompleted;
  bool areaVentilated;
  bool noIgnitionSources;
  bool warningNoticesDisplayed;
  bool emergencyProceduresInPlace;
  bool fireExtinguisherAvailable;
  bool responsiblePersonPresent;

  String defectsFound;
  String remedialAction;
  String isolationDetails;
  String comments;

  String engineerSignatureBase64;
  String customerSignatureBase64;

  bool locked;

  Cp16Certificate({
    this.id,
    required this.certificateRef,
    required this.certificateNumber,
    required this.inspectionDate,
    required this.nextInspectionDue,
    required this.reminderDate,
    this.siteName = '',
    this.siteAddress = '',
    this.clientName = '',
    this.contractorName = '',
    this.engineerName = '',
    this.gasSafeNumber = '',
    this.companyName = '',
    this.companyAddress = '',
    this.companyPhone = '',
    this.engineerEmail = '',
    this.gasType = 'Natural Gas',
    this.pipeMaterial = '',
    this.pipeSize = '',
    this.installationLength = '',
    this.installationVolume = '',
    this.testMedium = 'Air',
    this.strengthTestPressure = '',
    this.strengthTestDuration = '',
    this.strengthPressureDrop = '',
    this.strengthTestResult = 'Pass',
    this.tightnessTestPressure = '',
    this.tightnessStartPressure = '',
    this.tightnessEndPressure = '',
    this.tightnessStabilisationPeriod = '',
    this.tightnessDuration = '',
    this.tightnessPressureDrop = '',
    this.tightnessResult = 'Pass',
    this.purgeMethod = 'Direct Purge',
    this.purgeVolume = '',
    this.purgePoint = '',
    this.purgeVentLocation = '',
    this.ventTerminationLocation = '',
    this.gasDetectorUsed = '',
    this.purgeSafetyPrecautions = '',
    this.riskAssessmentCompleted = false,
    this.areaVentilated = false,
    this.noIgnitionSources = false,
    this.warningNoticesDisplayed = false,
    this.emergencyProceduresInPlace = false,
    this.fireExtinguisherAvailable = false,
    this.responsiblePersonPresent = false,
    this.defectsFound = '',
    this.remedialAction = '',
    this.isolationDetails = '',
    this.comments = '',
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
      'contractorName': contractorName,
      'engineerName': engineerName,
      'gasSafeNumber': gasSafeNumber,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'engineerEmail': engineerEmail,
      'gasType': gasType,
      'pipeMaterial': pipeMaterial,
      'pipeSize': pipeSize,
      'installationLength': installationLength,
      'installationVolume': installationVolume,
      'testMedium': testMedium,
      'strengthTestPressure': strengthTestPressure,
      'strengthTestDuration': strengthTestDuration,
      'strengthPressureDrop': strengthPressureDrop,
      'strengthTestResult': strengthTestResult,
      'tightnessTestPressure': tightnessTestPressure,
      'tightnessStartPressure': tightnessStartPressure,
      'tightnessEndPressure': tightnessEndPressure,
      'tightnessStabilisationPeriod': tightnessStabilisationPeriod,
      'tightnessDuration': tightnessDuration,
      'tightnessPressureDrop': tightnessPressureDrop,
      'tightnessResult': tightnessResult,
      'purgeMethod': purgeMethod,
      'purgeVolume': purgeVolume,
      'purgePoint': purgePoint,
      'purgeVentLocation': purgeVentLocation,
      'ventTerminationLocation': ventTerminationLocation,
      'gasDetectorUsed': gasDetectorUsed,
      'purgeSafetyPrecautions': purgeSafetyPrecautions,
      'riskAssessmentCompleted': riskAssessmentCompleted,
      'areaVentilated': areaVentilated,
      'noIgnitionSources': noIgnitionSources,
      'warningNoticesDisplayed': warningNoticesDisplayed,
      'emergencyProceduresInPlace': emergencyProceduresInPlace,
      'fireExtinguisherAvailable': fireExtinguisherAvailable,
      'responsiblePersonPresent': responsiblePersonPresent,
      'defectsFound': defectsFound,
      'remedialAction': remedialAction,
      'isolationDetails': isolationDetails,
      'comments': comments,
      'engineerSignatureBase64': engineerSignatureBase64,
      'customerSignatureBase64': customerSignatureBase64,
      'locked': locked,
    };
  }

  factory Cp16Certificate.fromMap(Map<String, dynamic> map) {
    return Cp16Certificate(
      id: map['id'],
      certificateRef: map['certificateRef'] ?? '',
      certificateNumber: map['certificateNumber'] ?? '',
      inspectionDate: map['inspectionDate'] ?? '',
      nextInspectionDue: map['nextInspectionDue'] ?? '',
      reminderDate: map['reminderDate'] ?? '',
      siteName: map['siteName'] ?? '',
      siteAddress: map['siteAddress'] ?? '',
      clientName: map['clientName'] ?? '',
      contractorName: map['contractorName'] ?? '',
      engineerName: map['engineerName'] ?? '',
      gasSafeNumber: map['gasSafeNumber'] ?? '',
      companyName: map['companyName'] ?? '',
      companyAddress: map['companyAddress'] ?? '',
      companyPhone: map['companyPhone'] ?? '',
      engineerEmail: map['engineerEmail'] ?? '',
      gasType: map['gasType'] ?? 'Natural Gas',
      pipeMaterial: map['pipeMaterial'] ?? '',
      pipeSize: map['pipeSize'] ?? '',
      installationLength: map['installationLength'] ?? '',
      installationVolume: map['installationVolume'] ?? '',
      testMedium: map['testMedium'] ?? 'Air',
      strengthTestPressure: map['strengthTestPressure'] ?? '',
      strengthTestDuration: map['strengthTestDuration'] ?? '',
      strengthPressureDrop: map['strengthPressureDrop'] ?? '',
      strengthTestResult: map['strengthTestResult'] ?? 'Pass',
      tightnessTestPressure: map['tightnessTestPressure'] ?? '',
      tightnessStartPressure: map['tightnessStartPressure'] ?? '',
      tightnessEndPressure: map['tightnessEndPressure'] ?? '',
      tightnessStabilisationPeriod:
      map['tightnessStabilisationPeriod'] ?? '',
      tightnessDuration: map['tightnessDuration'] ?? '',
      tightnessPressureDrop: map['tightnessPressureDrop'] ?? '',
      tightnessResult: map['tightnessResult'] ?? 'Pass',
      purgeMethod: map['purgeMethod'] ?? 'Direct Purge',
      purgeVolume: map['purgeVolume'] ?? '',
      purgePoint: map['purgePoint'] ?? '',
      purgeVentLocation: map['purgeVentLocation'] ?? '',
      ventTerminationLocation: map['ventTerminationLocation'] ?? '',
      gasDetectorUsed: map['gasDetectorUsed'] ?? '',
      purgeSafetyPrecautions: map['purgeSafetyPrecautions'] ?? '',
      riskAssessmentCompleted: map['riskAssessmentCompleted'] ?? false,
      areaVentilated: map['areaVentilated'] ?? false,
      noIgnitionSources: map['noIgnitionSources'] ?? false,
      warningNoticesDisplayed: map['warningNoticesDisplayed'] ?? false,
      emergencyProceduresInPlace:
      map['emergencyProceduresInPlace'] ?? false,
      fireExtinguisherAvailable:
      map['fireExtinguisherAvailable'] ?? false,
      responsiblePersonPresent:
      map['responsiblePersonPresent'] ?? false,
      defectsFound: map['defectsFound'] ?? '',
      remedialAction: map['remedialAction'] ?? '',
      isolationDetails: map['isolationDetails'] ?? '',
      comments: map['comments'] ?? '',
      engineerSignatureBase64: map['engineerSignatureBase64'] ?? '',
      customerSignatureBase64: map['customerSignatureBase64'] ?? '',
      locked: map['locked'] ?? false,
    );
  }

  double calculatePipeVolumeM3() {
    final diameterMm = double.tryParse(pipeSize.trim()) ?? 0;
    final lengthM = double.tryParse(installationLength.trim()) ?? 0;

    if (diameterMm <= 0 || lengthM <= 0) return 0;

    final diameterM = diameterMm / 1000;
    final radiusM = diameterM / 2;

    return 3.14159265359 * radiusM * radiusM * lengthM;
  }

  bool get hasFailedTests =>
      strengthTestResult == 'Fail' || tightnessResult == 'Fail';

  bool get safetyChecksComplete =>
      riskAssessmentCompleted &&
          areaVentilated &&
          noIgnitionSources &&
          emergencyProceduresInPlace &&
          responsiblePersonPresent;

  bool get hasSignatures =>
      engineerSignatureBase64.isNotEmpty &&
          customerSignatureBase64.isNotEmpty;

  bool get canLock {
    if (!safetyChecksComplete) return false;
    if (!hasSignatures) return false;
    if (purgeVolume.isEmpty) return false;

    if (hasFailedTests) {
      if (defectsFound.isEmpty || remedialAction.isEmpty) return false;
    }

    return true;
  }
}



