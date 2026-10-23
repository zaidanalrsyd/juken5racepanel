import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:juken_race_panel/data/models/engine_data.dart';
import 'package:juken_race_panel/features/ecu_connection/services/ecu_data_parser.dart';

void main() {
  group('EcuLineBuffer', () {
    test('reassembles a line split across input chunks', () {
      final buffer = EcuLineBuffer();

      expect(
        buffer.add(Uint8List.fromList(utf8.encode('a603;0;13.93'))),
        isEmpty,
      );

      final lines = buffer.add(Uint8List.fromList(utf8.encode(';2;0\r\n')));

      expect(lines, hasLength(1));
      expect(utf8.decode(lines.single), 'a603;0;13.93;2;0\r\n');
    });

    test('returns every complete line in a chunk', () {
      final buffer = EcuLineBuffer();

      final lines = buffer.add(
        Uint8List.fromList(utf8.encode('a603;1\r\na603;2\r\n')),
      );

      expect(lines, hasLength(2));
      expect(utf8.decode(lines[0]), 'a603;1\r\n');
      expect(utf8.decode(lines[1]), 'a603;2\r\n');
    });

    test('does not return an incomplete final line', () {
      final buffer = EcuLineBuffer();

      final lines = buffer.add(
        Uint8List.fromList(utf8.encode('a603;1\r\na603;')),
      );

      expect(lines, hasLength(1));
      expect(utf8.decode(lines.single), 'a603;1\r\n');

      expect(
        buffer.add(Uint8List.fromList(utf8.encode('2\r\n'))),
        hasLength(1),
      );
    });

    test('clears an overlong frame and reports a format error', () {
      final buffer = EcuLineBuffer(maxLineBytes: 4);

      expect(
        () => buffer.add(Uint8List.fromList([1, 2, 3, 4, 5])),
        throwsFormatException,
      );

      expect(
        buffer.add(Uint8List.fromList(utf8.encode('ok\r\n'))),
        hasLength(1),
      );
    });
  });

  group('EcuDataParser.parseRawSensorFields', () {
    test('extracts field values from A603 without assigning labels', () {
      final fields = EcuDataParser.parseRawSensorFields(
        Uint8List.fromList(
          utf8.encode('a603;0;13.88;2;0;493;-20;15.8;3.07;340;150;0;257;\r\n'),
        ),
      );

      expect(fields, [
        '0',
        '13.88',
        '2',
        '0',
        '493',
        '-20',
        '15.8',
        '3.07',
        '340',
        '150',
        '0',
        '257',
      ]);
    });

    test('ignores lines with a different header', () {
      final fields = EcuDataParser.parseRawSensorFields(
        Uint8List.fromList(utf8.encode('A602;0;1\r\n')),
      );

      expect(fields, isNull);
    });

    test('maps confirmed A603 fields to ECU sensor readings', () {
      final readings = EcuDataParser.parseConfirmedSensorReadings(
        Uint8List.fromList(
          utf8.encode(
            'A603;0;13.95;2;1866;512;-20;15.5;3.04;325;125;0;249;\r\n',
          ),
        ),
      );

      expect(readings?.tps, 0);
      expect(readings?.batteryVoltage, 13.95);
      expect(readings?.rpm, 1866);
      expect(readings?.afr, 15.5);
    });

    test('ignores other headers and rejects invalid confirmed fields', () {
      expect(
        EcuDataParser.parseConfirmedSensorReadings(
          Uint8List.fromList(utf8.encode('A602;0;1;1866\r\n')),
        ),
        isNull,
      );

      final readings = EcuDataParser.parseConfirmedSensorReadings(
        Uint8List.fromList(
          utf8.encode('A603;101;13.95;2;bad;512;-20;15.5\r\n'),
        ),
      );

      expect(readings?.tps, isNull);
      expect(readings?.batteryVoltage, 13.95);
      expect(readings?.rpm, isNull);
      expect(readings?.afr, 15.5);
    });

    test('does not assign fields as EOT because it is unconfirmed', () {
      final readings = EcuDataParser.parseConfirmedSensorReadings(
        Uint8List.fromList(
          utf8.encode('A603;10;13.95;2;1866;512;-20;15.5\r\n'),
        ),
      );

      expect(readings, isNotNull);
      expect(readings?.tps, 10);
      expect(readings?.batteryVoltage, 13.95);
      expect(readings?.rpm, 1866);
      expect(readings?.afr, 15.5);
      expect(EngineData.initial().eot, isNull);
    });
  });
}
