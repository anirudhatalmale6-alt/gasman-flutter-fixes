class GasApplianceEntry {
  String applianceType;
  String make;
  String model;
  String location;
  String operatingPressure;
  String heatInput;
  bool ventilationOk;
  bool flueChimneyOk;
  bool safetyDevicesOk;
  bool combustionOk;
  bool applianceSafeToUse;

  GasApplianceEntry({
    this.applianceType = '',
    this.make = '',
    this.model = '',
    this.location = '',
    this.operatingPressure = '',
    this.heatInput = '',
    this.ventilationOk = true,
    this.flueChimneyOk = true,
    this.safetyDevicesOk = true,
    this.combustionOk = true,
    this.applianceSafeToUse = true,
  });
}

enum DefectClassification { none, id, ar, ncs }
