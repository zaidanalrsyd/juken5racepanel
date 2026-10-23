import 'dart:typed_data';

/// Utilitas untuk menampilkan data mentah Bluetooth.
class EcuDataParser {
  EcuDataParser._();

  /// Mengubah byte menjadi teks hexadecimal untuk pemeriksaan.
  ///
  /// Belum menerjemahkan byte menjadi RPM, TPS, EOT, atau AFR
  /// karena protokol ECU belum terverifikasi.
  static String formatRawBytes(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Extracts unlabelled fields from a complete A603 line.
  ///
  /// The field order and units are not confirmed, so values remain strings.
  static List<String>? parseRawSensorFields(Uint8List line) {
    final text = String.fromCharCodes(line).trim();
    final parts = text.split(';');

    if (parts.isEmpty || parts.first.trim().toUpperCase() != 'A603') {
      return null;
    }

    final fields = parts.skip(1).map((field) => field.trim()).toList();
    while (fields.isNotEmpty && fields.last.isEmpty) {
      fields.removeLast();
    }

    return List<String>.unmodifiable(fields);
  }

  /// Parses sensor fields whose meaning has been confirmed on this ECU.
  ///
  /// Protocol field numbering is one-based: Field 1 TPS, Field 2 battery
  /// voltage, Field 4 RPM, and Field 7 AFR.
  static EcuSensorReadings? parseConfirmedSensorReadings(Uint8List line) {
    final fields = parseRawSensorFields(line);
    if (fields == null || fields.length < 7) return null;

    final tps = double.tryParse(fields[0]);
    final batteryVoltage = double.tryParse(fields[1]);
    final rpm = int.tryParse(fields[3]);
    final afr = double.tryParse(fields[6]);

    return EcuSensorReadings(
      tps: tps != null && tps.isFinite && tps >= 0 && tps <= 100 ? tps : null,
      batteryVoltage:
          batteryVoltage != null &&
              batteryVoltage.isFinite &&
              batteryVoltage >= 0 &&
              batteryVoltage <= 20
          ? batteryVoltage
          : null,
      rpm: rpm != null && rpm >= 0 ? rpm : null,
      afr: afr != null && afr.isFinite && afr > 0 && afr <= 40 ? afr : null,
    );
  }
}

class EcuSensorReadings {
  const EcuSensorReadings({this.tps, this.batteryVoltage, this.rpm, this.afr});

  final double? tps;
  final double? batteryVoltage;
  final int? rpm;
  final double? afr;
}

/// Reassembles text protocol lines because Bluetooth may split one line
/// across multiple input events or deliver several lines in one event.
class EcuLineBuffer {
  EcuLineBuffer({this.maxLineBytes = 4096});

  final int maxLineBytes;
  final List<int> _pending = [];

  List<Uint8List> add(Uint8List chunk) {
    final lines = <Uint8List>[];

    for (final byte in chunk) {
      if (_pending.length >= maxLineBytes) {
        _pending.clear();
        throw FormatException(
          'ECU line exceeded the $maxLineBytes-byte limit.',
        );
      }

      _pending.add(byte);

      if (byte == 0x0A) {
        lines.add(Uint8List.fromList(_pending));
        _pending.clear();
      }
    }

    return lines;
  }

  void reset() {
    _pending.clear();
  }
}
