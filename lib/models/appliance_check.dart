class ApplianceCheck {
  String location;
  String type;
  String makeModel;
  bool tightnessOk;
  bool ventilationOk;
  bool flueOk;

  ApplianceCheck({
    required this.location,
    required this.type,
    required this.makeModel,
    required this.tightnessOk,
    required this.ventilationOk,
    required this.flueOk,
  });
}
