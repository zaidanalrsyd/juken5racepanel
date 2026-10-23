class EngineData {
  static const Object _sentinel = Object();

  // Parameter utama mesin.
  final int rpm;
  final double tps;
  final double? eot;
  final double afr;

  // Tegangan aki dalam volt.
  // Null berarti data belum tersedia.
  final double? batteryVoltage;

  const EngineData({
    required this.rpm,
    required this.tps,
    required this.eot,
    required this.afr,
    this.batteryVoltage,
  });

  // Nilai awal simulasi aplikasi.
  factory EngineData.initial() {
    return const EngineData(
      rpm: 12500,
      tps: 68,
      eot: null,
      afr: 12.8,
      batteryVoltage: null,
    );
  }

  EngineData copyWith({
    Object? rpm = _sentinel,
    Object? tps = _sentinel,
    Object? eot = _sentinel,
    Object? afr = _sentinel,
    Object? batteryVoltage = _sentinel,
  }) {
    return EngineData(
      rpm: rpm == _sentinel ? this.rpm : rpm as int,
      tps: tps == _sentinel ? this.tps : tps as double,
      eot: eot == _sentinel ? this.eot : eot as double?,
      afr: afr == _sentinel ? this.afr : afr as double,
      batteryVoltage: batteryVoltage == _sentinel
          ? this.batteryVoltage
          : batteryVoltage as double?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EngineData &&
        other.rpm == rpm &&
        other.tps == tps &&
        other.eot == eot &&
        other.afr == afr &&
        other.batteryVoltage == batteryVoltage;
  }

  @override
  int get hashCode => Object.hash(rpm, tps, eot, afr, batteryVoltage);

  @override
  String toString() {
    return 'EngineData('
        'rpm: $rpm, '
        'tps: $tps, '
        'eot: $eot, '
        'afr: $afr, '
        'batteryVoltage: $batteryVoltage'
        ')';
  }
}
