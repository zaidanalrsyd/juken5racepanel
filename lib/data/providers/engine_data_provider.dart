import 'dart:async';
import 'dart:math' as math;

import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:flutter/foundation.dart';

import '../../features/ecu_connection/services/bluetooth_service.dart';
import '../../features/ecu_connection/services/ecu_data_parser.dart';
import '../../features/ecu_connection/services/ecu_protocol.dart';
import '../models/engine_data.dart';
import '../repositories/engine_repository.dart';

class EngineDataProvider extends ChangeNotifier {
  EngineDataProvider({
    EngineRepository? repository,
    BluetoothService? bluetoothService,
  }) : _repository = repository ?? EngineRepository(),
       _bluetoothService = bluetoothService ?? BluetoothService() {
    _connectionStateSubscription = _bluetoothService.connectionStateChanges
        .listen((_) {
          if (_disposed) return;
          notifyListeners();
        });
  }

  final EngineRepository _repository;
  final BluetoothService _bluetoothService;

  StreamSubscription<Uint8List>? _dataSubscription;
  StreamSubscription<EcuConnectionState>? _connectionStateSubscription;
  Timer? _simulationTimer;
  final EcuLineBuffer _ecuLineBuffer = EcuLineBuffer();

  final StreamController<Uint8List> _diagnosticsController =
      StreamController<Uint8List>.broadcast();

  bool _disposed = false;
  bool _simulationRunning = false;
  bool _connectingToDevice = false;
  bool _startingLive = false;
  bool _liveRequested = false;
  int _simulationSequence = 0;

  EngineData get data => _repository.currentData;

  Stream<Uint8List> get incomingDiagnosticsData =>
      _diagnosticsController.stream;

  bool get isConnected => _bluetoothService.isConnected;

  bool get isSimulationRunning => _simulationRunning;

  bool get isLiveRequested => _liveRequested;

  EcuConnectionState get connectionState => _bluetoothService.state;

  String get connectionStatus {
    switch (connectionState) {
      case EcuConnectionState.disconnected:
        return 'ECU OFFLINE';
      case EcuConnectionState.connecting:
        return 'CONNECTING ECU';
      case EcuConnectionState.connected:
        return _liveRequested ? 'LIVE REQUESTED' : 'ECU CONNECTED';
      case EcuConnectionState.error:
        return 'CONNECTION ERROR';
    }
  }

  Future<bool> enableBluetooth() {
    return _bluetoothService.enableBluetooth();
  }

  Future<List<BluetoothDevice>> getPairedDevices() {
    return _bluetoothService.getPairedDevices();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_disposed) {
      throw StateError('EngineDataProvider sudah ditutup.');
    }

    if (_connectingToDevice) {
      debugPrint('[ECU CONNECT] Proses koneksi sedang berlangsung.');
      return;
    }

    if (isConnected) {
      debugPrint('[ECU CONNECT] Bluetooth sudah terhubung.');
      return;
    }

    _connectingToDevice = true;

    try {
      await _dataSubscription?.cancel();
      _dataSubscription = null;

      stopSimulation();
      _liveRequested = false;
      _ecuLineBuffer.reset();

      // Pasang listener sebelum koneksi Bluetooth dimulai.
      _dataSubscription = _bluetoothService.incomingData.listen(
        (Uint8List bytes) {
          if (_disposed || _diagnosticsController.isClosed) return;

          debugPrint(
            '[ECU RAW DATA] ${bytes.length} byte: '
            '${EcuDataParser.formatRawBytes(bytes)}',
          );

          try {
            final lines = _ecuLineBuffer.add(bytes);
            for (final line in lines) {
              if (_diagnosticsController.isClosed) return;

              debugPrint('[ECU LINE] ${EcuDataParser.formatRawBytes(line)}');
              final readings = EcuDataParser.parseConfirmedSensorReadings(line);
              if (readings != null) {
                _repository.updateData(
                  data.copyWith(
                    rpm: readings.rpm ?? data.rpm,
                    tps: readings.tps ?? data.tps,
                    afr: readings.afr ?? data.afr,
                    batteryVoltage:
                        readings.batteryVoltage ?? data.batteryVoltage,
                  ),
                );
                notifyListeners();
              }
              _diagnosticsController.add(line);
            }
          } on FormatException catch (error, stackTrace) {
            debugPrint('[ECU LINE ERROR] $error');
            if (!_diagnosticsController.isClosed) {
              _diagnosticsController.addError(error, stackTrace);
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[ECU STREAM ERROR] $error');

          if (!_diagnosticsController.isClosed) {
            _diagnosticsController.addError(error, stackTrace);
          }
        },
        onDone: () {
          debugPrint('[ECU STREAM] Stream data Bluetooth ditutup.');
          _ecuLineBuffer.reset();

          if (!_disposed) {
            _liveRequested = false;
            notifyListeners();
          }
        },
        cancelOnError: false,
      );

      debugPrint('[ECU CONNECT] Listener data sudah aktif.');

      await _bluetoothService.connect(device);

      debugPrint(
        '[ECU CONNECT] Proses koneksi selesai. '
        'connected=$isConnected',
      );
    } catch (error, stackTrace) {
      debugPrint('[ECU PROVIDER CONNECT ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);

      await _dataSubscription?.cancel();
      _dataSubscription = null;

      rethrow;
    } finally {
      _connectingToDevice = false;

      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Meminta data sensor menggunakan perintah yang sudah menghasilkan
  /// telemetry pada perangkat yang sedang diuji.
  ///
  /// OPEN_LIVE belum menghasilkan data pada perangkat ini, sementara
  /// READ_SENSOR telah menghasilkan baris A603.
  /// Status LIVE REQUESTED bukan bukti bahwa ECU sudah merespons.
  Future<void> startLive() async {
    if (_disposed) {
      throw StateError('EngineDataProvider sudah ditutup.');
    }

    if (!isConnected) {
      throw StateError('Bluetooth ECU belum terhubung.');
    }

    if (_startingLive || _liveRequested) {
      debugPrint('[ECU LIVE] Permintaan Live sudah berjalan.');
      return;
    }

    _startingLive = true;

    try {
      // Beri waktu agar koneksi dan listener siap.
      await Future<void>.delayed(const Duration(seconds: 1));

      if (_disposed || !isConnected) {
        throw StateError('Koneksi ECU terputus sebelum Live dimulai.');
      }

      // READ_SENSOR = ASCII "1609\r\n"; this command produced A603 data
      // on the tested ECU, unlike OPEN_LIVE.
      final command = Uint8List.fromList(EcuProtocol.readSensor.codeUnits);

      debugPrint('[ECU LIVE] Mengirim READ_SENSOR.');

      await _bluetoothService.sendRawBytes(command);

      _liveRequested = true;

      debugPrint(
        '[ECU LIVE] READ_SENSOR terkirim. '
        'Menunggu respons ECU.',
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('[ECU LIVE ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      _startingLive = false;
    }
  }

  /// Meminta satu snapshot sensor tanpa mengasumsikan format respons.
  Future<void> requestSensorSnapshot() async {
    if (_disposed) {
      throw StateError('EngineDataProvider sudah ditutup.');
    }

    if (!isConnected) {
      throw StateError('Bluetooth ECU belum terhubung.');
    }

    final command = Uint8List.fromList(EcuProtocol.readSensor.codeUnits);

    debugPrint('[ECU SENSOR] Mengirim permintaan snapshot sensor.');
    await _bluetoothService.sendRawBytes(command);
  }

  /// Mengirim permintaan berhenti Live.
  ///
  /// Gunakan saat memang perlu menghentikan streaming ECU.
  Future<void> stopLive() async {
    if (_disposed) {
      throw StateError('EngineDataProvider sudah ditutup.');
    }

    if (!isConnected) {
      _liveRequested = false;
      notifyListeners();
      return;
    }

    final command = Uint8List.fromList(EcuProtocol.stopLive.codeUnits);

    await _bluetoothService.sendRawBytes(command);

    _liveRequested = false;

    debugPrint('[ECU LIVE] STOP_LIVE terkirim.');

    notifyListeners();
  }

  Future<void> disconnectFromDevice() async {
    _liveRequested = false;
    _ecuLineBuffer.reset();

    await _dataSubscription?.cancel();
    _dataSubscription = null;

    await _bluetoothService.disconnect();

    if (!_disposed) {
      notifyListeners();
    }
  }

  // Simulasi hanya untuk pengujian tampilan lokal.
  // Data ini bukan pembacaan ECU asli.
  void startSimulation() {
    if (_disposed || _simulationRunning || isConnected) return;

    _simulationRunning = true;
    _simulationSequence = 0;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _generateSimulationData(),
    );

    _generateSimulationData();
    notifyListeners();
  }

  void _generateSimulationData() {
    if (_disposed || !_simulationRunning) return;

    _simulationSequence++;

    final phase = _simulationSequence / 3.0;

    final rpm = (4500 + 3500 * math.sin(phase)).round();

    final tps = (45 + 30 * math.sin(phase + 0.7)).clamp(0.0, 100.0).toDouble();

    final eot = (85 + 4 * math.sin(phase / 3)).clamp(20.0, 150.0).toDouble();

    final afr = (12.8 + 0.5 * math.sin(phase / 2)).clamp(8.0, 20.0).toDouble();

    final batteryVoltage = (13.8 + 0.15 * math.sin(phase / 4))
        .clamp(12.0, 14.8)
        .toDouble();

    _repository.updateData(
      EngineData(
        rpm: rpm,
        tps: tps,
        eot: eot,
        afr: afr,
        batteryVoltage: batteryVoltage,
      ),
    );

    final sample =
        'SIM,SEQ=$_simulationSequence,'
        'RPM=$rpm,'
        'TPS=${tps.toStringAsFixed(1)},'
        'EOT=${eot.toStringAsFixed(1)},'
        'AFR=${afr.toStringAsFixed(2)},'
        'BAT=${batteryVoltage.toStringAsFixed(2)}';

    if (!_diagnosticsController.isClosed) {
      _diagnosticsController.add(Uint8List.fromList(sample.codeUnits));
    }

    notifyListeners();
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;

    if (!_simulationRunning) return;

    _simulationRunning = false;

    if (!_disposed) {
      notifyListeners();
    }
  }

  void updateData(EngineData newData) {
    if (_disposed) return;

    _repository.updateData(newData);
    notifyListeners();
  }

  void setConnectionStatus(bool connected) {
    if (connected != isConnected) {
      debugPrint('Status koneksi hanya dapat diubah melalui BluetoothService.');
    }
  }

  void resetData() {
    if (_disposed) return;

    _repository.resetData();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;

    _simulationTimer?.cancel();
    _simulationTimer = null;

    _connectionStateSubscription?.cancel();
    _dataSubscription?.cancel();

    _diagnosticsController.close();

    // Tutup koneksi dan service Bluetooth.
    _bluetoothService.dispose();

    super.dispose();
  }
}
