import 'package:flutter_test/flutter_test.dart';
import 'package:juken_race_panel/data/models/engine_data.dart';

void main() {
  test('copyWith preserves existing values unless overridden', () {
    final data = const EngineData(
      rpm: 8000,
      tps: 45,
      eot: 78,
      afr: 12.4,
      batteryVoltage: 13.5,
    );

    final updated = data.copyWith(rpm: 9000);

    expect(updated.rpm, 9000);
    expect(updated.tps, 45);
    expect(updated.eot, 78);
    expect(updated.afr, 12.4);
    expect(updated.batteryVoltage, 13.5);
  });

  test('copyWith can explicitly clear batteryVoltage to null', () {
    final data = const EngineData(
      rpm: 8000,
      tps: 45,
      eot: 78,
      afr: 12.4,
      batteryVoltage: 13.5,
    );

    final cleared = data.copyWith(batteryVoltage: null);

    expect(cleared.batteryVoltage, isNull);
    expect(cleared, isNot(equals(data)));
  });
}
