import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'gas_appliance_entry.dart';

/// Classification for unsafe situations.
enum UnsafeClassification { none, id, ar, ncs }

class GasSafetyAppliance {
  final String type;
  final String make;
  final String model;
  final String location;
  final String operatingPressure; // text, e.g. "21 mbar"
  final String heatInput;         // e.g. "24 kW"
  final String coCo2Ratio;
  final String coPpm;

  GasSafetyAppliance({
    required this.type,
    required this.make,
    required this.model,
    required this.location,
    required this.operatingPressure,
    required this.heatInput,
    required this.coCo2Ratio,
    required this.coPpm,
  });
}

class GasSafetyCertificateData {
  // Certificate info
  final String certificateNumber;
  final bool isLandlordCertificate; // true = Landlord, false = Homeowner

  // Landlord / homeowner details
  final String landlordName;
  final String landlordAddress;
  final String landlordPostcode;
  final String landlordPhone;
  final String landlordEmail;

  // Property details
  final String tenantName; // can be empty
  final String propertyAddress;
  final String propertyPostcode;

  // Appliances
  final List<GasApplianceEntry> appliances;

  // Appliance checks (switches)
  final bool ventilationAdequate;
  final bool flueChimneySatisfactory;
  final bool safetyDevicesOk;
  final bool combustionReadingsOk;
  final bool applianceSafeToUse;

  // Flue / chimney checks
  final bool flueConditionSatisfactory;
  final bool terminationSatisfactory;
  final String flueNotes;

  // Gas installation pipework
  final bool visualConditionSatisfactory;
  final bool pipeworkSecure;
  final bool tightnessTestCarriedOut;
  final String standingPressure;
  final String workingPressure;
  final String letByResult;
  final String tightnessTestDrop;

  // Defects / unsafe situations
  final UnsafeClassification classification;
  final String defectDetails;
  final String actionTaken;
  final String adviceGiven;

  // Dates
  final String inspectionDate;
  final String nextInspectionDue;

  // Engineer / company
  final String engineerName;
  final String gasSafeRegNo;
  final String companyName;
  final String companyAddress;
  final String companyPostcode;
  final String companyPhone;
  final String companyEmail;

  // Signatures – these should be PNG bytes from your signature pad
  final Uint8List? engineerSignaturePng;
  final Uint8List? customerSignaturePng;

  GasSafetyCertificateData({
    required this.certificateNumber,
    required this.isLandlordCertificate,
    required this.landlordName,
    required this.landlordAddress,
    required this.landlordPostcode,
    required this.landlordPhone,
    required this.landlordEmail,
    required this.tenantName,
    required this.propertyAddress,
    required this.propertyPostcode,
    required this.appliances,
    required this.ventilationAdequate,
    required this.flueChimneySatisfactory,
    required this.safetyDevicesOk,
    required this.combustionReadingsOk,
    required this.applianceSafeToUse,
    required this.flueConditionSatisfactory,
    required this.terminationSatisfactory,
    required this.flueNotes,
    required this.visualConditionSatisfactory,
    required this.pipeworkSecure,
    required this.tightnessTestCarriedOut,
    required this.standingPressure,
    required this.workingPressure,
    required this.letByResult,
    required this.tightnessTestDrop,
    required this.classification,
    required this.defectDetails,
    required this.actionTaken,
    required this.adviceGiven,
    required this.inspectionDate,
    required this.nextInspectionDue,
    required this.engineerName,
    required this.gasSafeRegNo,
    required this.companyName,
    required this.companyAddress,
    required this.companyPostcode,
    required this.companyPhone,
    required this.companyEmail,
    this.engineerSignaturePng,
    this.customerSignaturePng,
  });
}
