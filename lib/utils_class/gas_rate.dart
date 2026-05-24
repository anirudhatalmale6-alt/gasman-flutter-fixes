class GasRateResult {
  final double grossKw;
  final double grossM3h;
  final double netKw;
  final double netM3h;
  const GasRateResult(this.grossKw, this.grossM3h, this.netKw, this.netM3h);
}

enum MeterType { metric, imperial }
enum FuelType { naturalGas, lpg }



class GasRate {
  // Calcs follow standard UK method
  static GasRateResult fromMetric({
    required double startM3,
    required double endM3,
    required double seconds,
    required FuelType fuel,
  }) {
    final usedM3 = (endM3 - startM3).abs();
    final m3h = usedM3 * (3600 / seconds);
    final kwGross = _kWFromM3h(m3h, fuel: fuel, net: false);
    final kwNet = _kWFromM3h(m3h, fuel: fuel, net: true);
    return GasRateResult(kwGross, m3h, kwNet, m3h);
  }

  static GasRateResult fromImperial({
    required double testDialFt3,
    required double secondsPerRev,
    required FuelType fuel,
  }) {
    final ft3h = (testDialFt3) * (3600 / secondsPerRev);
    final m3h = ft3h * 0.0283168;
    final kwGross = _kWFromM3h(m3h, fuel: fuel, net: false);
    final kwNet = _kWFromM3h(m3h, fuel: fuel, net: true);
    return GasRateResult(kwGross, m3h, kwNet, m3h);
  }

  static double _kWFromM3h(double m3h, {required FuelType fuel, required bool net}) {
    // Typical UK gross/net calorific values (approx.): NG 39.3/35.8 MJ/m3, LPG 93.1/85.8
    final (gross, netMJ) = switch (fuel) {
      FuelType.naturalGas => (39.3, 35.8),
      FuelType.lpg => (93.1, 85.8),
    };
    final mj = (net ? netMJ : gross) * m3h;
    return mj / 3.6; // MJ/h to kW
  }
}

