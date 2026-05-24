import '../models/pipe_section.dart';

class PipeCalcResult {
  final double totalLengthM;
  final double equivLengthM;
  final double pressureDropMb; // simplified illustrative calc
  PipeCalcResult(this.totalLengthM, this.equivLengthM, this.pressureDropMb);
}

class PipeSizing {
  // Very simplified equivalent-length method (illustrative). Replace with your tables if needed.
  static PipeCalcResult calculate({
    required List<PipeSection> sections,
    required double gasRateM3h,
  }) {
    double totalLen = 0, equivLen = 0;
    for (final s in sections) {
      totalLen += s.lengthM;
      final k45 = 0.5;
      final k90 = 1.0;
      final kTeeIn = 1.0;
      final kTeeOut = 0.5;
      final dia = s.diameterMm / 1000.0;
      final el = s.lengthM +
          (s.bends45 * k45 + s.bends90 * k90 + s.teesEntering * kTeeIn + s.teesExiting * kTeeOut) * dia * 25;
      equivLen += el;
    }
    // Crude pressure drop model: ΔP ∝ (Q^1.82) * L / d^4.82 (Weymouth-like). Here we normalise for demo.
    final dRef = (sections.isNotEmpty ? sections.last.diameterMm : 22) / 1000.0;
    final dp = (gasRateM3h.clamp(0, 20)).toDouble();
    final mb = (dp * 1.82) * (equivLen / 30) / (dRef * dRef * dRef * dRef).clamp(0.2, 20);
    return PipeCalcResult(totalLen, equivLen, mb);
  }
}
