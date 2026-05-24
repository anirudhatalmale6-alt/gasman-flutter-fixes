
class WarningNoticeRecord {
  final String id;
  String noticeNumber;

  String propertyAddress;
  String postcode;
  String occupierName;
  String landlordName;
  String phone;

  DateTime dateIssued;
  String timeIssued;

  List<WarningApplianceEntry> items;

  bool applianceShutOff;
  bool disconnected;
  bool warningLabelApplied;
  bool supplyCapped;
  String additionalActions;

  String responsiblePersonName;
  String responsiblePersonRole;
  bool responsiblePersonSigned;
  bool refusedToSign;
  String refusalNotes;

  String engineerName;
  String engineerGasSafeNo;
  String engineerCompanyName;
  String engineerCompanyAddress;
  String engineerCompanyPostcode;
  String engineerCompanyPhone;
  String engineerCompanyEmail;
  bool engineerSigned;

  WarningNoticeRecord({
    required this.id,
    required this.noticeNumber,
    this.propertyAddress = '',
    this.postcode = '',
    this.occupierName = '',
    this.landlordName = '',
    this.phone = '',
    DateTime? dateIssued,
    this.timeIssued = '',
    List<WarningApplianceEntry>? items,
    this.applianceShutOff = false,
    this.disconnected = false,
    this.warningLabelApplied = false,
    this.supplyCapped = false,
    this.additionalActions = '',
    this.responsiblePersonName = '',
    this.responsiblePersonRole = '',
    this.responsiblePersonSigned = false,
    this.refusedToSign = false,
    this.refusalNotes = '',
    this.engineerName = '',
    this.engineerGasSafeNo = '',
    this.engineerCompanyName = '',
    this.engineerCompanyAddress = '',
    this.engineerCompanyPostcode = '',
    this.engineerCompanyPhone = '',
    this.engineerCompanyEmail = '',
    this.engineerSigned = false,
  })  : dateIssued = dateIssued ?? DateTime.now(),
        items = items ?? [WarningApplianceEntry()];

  /// 🔥 FROM JSON
  factory WarningNoticeRecord.fromJson(Map<String, dynamic> json) {
    return WarningNoticeRecord(
      id: json['id'],
      noticeNumber: json['noticeNumber'] ?? '',
      propertyAddress: json['propertyAddress'] ?? '',
      postcode: json['postcode'] ?? '',
      occupierName: json['occupierName'] ?? '',
      landlordName: json['landlordName'] ?? '',
      phone: json['phone'] ?? '',
      dateIssued: json['dateIssued'] != null
          ? DateTime.parse(json['dateIssued'])
          : DateTime.now(),
      timeIssued: json['timeIssued'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => WarningApplianceEntry.fromJson(e))
          .toList() ??
          [WarningApplianceEntry()],
      applianceShutOff: json['applianceShutOff'] ?? false,
      disconnected: json['disconnected'] ?? false,
      warningLabelApplied: json['warningLabelApplied'] ?? false,
      supplyCapped: json['supplyCapped'] ?? false,
      additionalActions: json['additionalActions'] ?? '',
      responsiblePersonName: json['responsiblePersonName'] ?? '',
      responsiblePersonRole: json['responsiblePersonRole'] ?? '',
      responsiblePersonSigned: json['responsiblePersonSigned'] ?? false,
      refusedToSign: json['refusedToSign'] ?? false,
      refusalNotes: json['refusalNotes'] ?? '',
      engineerName: json['engineerName'] ?? '',
      engineerGasSafeNo: json['engineerGasSafeNo'] ?? '',
      engineerCompanyName: json['engineerCompanyName'] ?? '',
      engineerCompanyAddress: json['engineerCompanyAddress'] ?? '',
      engineerCompanyPostcode: json['engineerCompanyPostcode'] ?? '',
      engineerCompanyPhone: json['engineerCompanyPhone'] ?? '',
      engineerCompanyEmail: json['engineerCompanyEmail'] ?? '',
      engineerSigned: json['engineerSigned'] ?? false,
    );
  }

  /// 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "noticeNumber": noticeNumber,
      "propertyAddress": propertyAddress,
      "postcode": postcode,
      "occupierName": occupierName,
      "landlordName": landlordName,
      "phone": phone,
      "dateIssued": dateIssued.toIso8601String(),
      "timeIssued": timeIssued,
      "items": items.map((e) => e.toJson()).toList(),
      "applianceShutOff": applianceShutOff,
      "disconnected": disconnected,
      "warningLabelApplied": warningLabelApplied,
      "supplyCapped": supplyCapped,
      "additionalActions": additionalActions,
      "responsiblePersonName": responsiblePersonName,
      "responsiblePersonRole": responsiblePersonRole,
      "responsiblePersonSigned": responsiblePersonSigned,
      "refusedToSign": refusedToSign,
      "refusalNotes": refusalNotes,
      "engineerName": engineerName,
      "engineerGasSafeNo": engineerGasSafeNo,
      "engineerCompanyName": engineerCompanyName,
      "engineerCompanyAddress": engineerCompanyAddress,
      "engineerCompanyPostcode": engineerCompanyPostcode,
      "engineerCompanyPhone": engineerCompanyPhone,
      "engineerCompanyEmail": engineerCompanyEmail,
      "engineerSigned": engineerSigned,
    };
  }
}

class WarningApplianceEntry {
  String type;
  String make;
  String model;
  String location;
  String serialNumber;
  bool isID;
  String defectDetails;

  WarningApplianceEntry({
    this.type = '',
    this.make = '',
    this.model = '',
    this.location = '',
    this.serialNumber = '',
    this.isID = true,
    this.defectDetails = '',
  });

  factory WarningApplianceEntry.fromJson(Map<String, dynamic> json) {
    return WarningApplianceEntry(
      type: json['type'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      location: json['location'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      isID: json['isID'] ?? true,
      defectDetails: json['defectDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "make": make,
      "model": model,
      "location": location,
      "serialNumber": serialNumber,
      "isID": isID,
      "defectDetails": defectDetails,
    };
  }
}


