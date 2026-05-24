enum PipeMaterial { copper, steel }


class PipeSection {
  final PipeMaterial material;
  final double diameterMm; // for copper (or nominal for steel)
  final double lengthM;
  final int bends45;
  final int bends90;
  final int teesEntering;
  final int teesExiting;
  final List<Appliance> appliances; // 🔥 KEY FIX


  const PipeSection({
    required this.material,
    required this.diameterMm,
    required this.lengthM,
    required this.bends45,
    required this.bends90,
    required this.teesEntering,
    required this.teesExiting,
    required this.appliances,

  });

  double get totalKw {
    return appliances.fold(0, (sum, a) => sum + a.kw);
  }

  double get totalM3 {
    return totalKw / 11.2;
  }

}

class Appliance {
  String name;
  double kw;

  Appliance({required this.name, required this.kw});
}


