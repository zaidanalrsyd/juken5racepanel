
import 'dart:async';

import 'package:bluetooth_spp/bluetooth_spp.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum EcuConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class BluetoothService {
  BluetoothService({BluetoothSpp? bluetooth})
      : _bluetooth = bluetooth ?? BluetoothSpp.instance;

  final BluetoothSpp _bluetooth;

  EcuConnectionState _state = EcuConnectionState.disconnected;

  SppConnection? _connection;

  StreamSubscription<Uint8List>? _dataSubscription;
  StreamSubscription<SppConnectionState>? _connectionStateSubscription;

  final StreamController<Uint8List> _dataController =
      StreamController<Uint8List>.broadcast();

  final StreamController<EcuConnectionState> _stateController =
      StreamController<EcuConnectionState>.broadcast();

  bool _isConnecting = false;
  bool _isDisposed = false;

  EcuConnectionState get state => _state;

  bool get isConnected =>
      !_isDisposed &&
      _state == EcuConnectionState.connected &&
      (_connection?.isConnected ?? false);

  Stream<Uint8List> get incomingData => _dataController.stream;

  Stream<EcuConnectionState> get connectionStateChanges =>
      _stateController.stream;

  void _setState(EcuConnectionState newState) {
    if (_isDisposed || _state == newState) return;

    _state = newState;

    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }

    debugPrint('[BT STATE] $_state');
  }

  Future<bool> requestBluetoothPermissions() async {
    final connectStatus = await Permission.bluetoothConnect.request();

    if (!connectStatus.isGranted) {
      debugPrint(
        '[BT PERMISSION] Izin Bluetooth Connect belum diberikan.',
      );
      return false;
    }

    final scanStatus = await Permission.bluetoothScan.request();

    if (!scanStatus.isGranted) {
      debugPrint(
        '[BT PERMISSION] Izin Bluetooth Scan belum diberikan.',
      );
      return false;
    }

    debugPrint('[BT PERMISSION] Izin Bluetooth diberikan.');

    return true;
  }

  Future<bool> enableBluetooth() async {
    final permitted = await requestBluetoothPermissions();

    if (!permitted) return false;

    try {
      return await _bluetooth.requestEnable();
    } catch (error) {
      debugPrint('[BT ENABLE ERROR] $error');
      return false;
    }
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    final permitted = await requestBluetoothPermissions();

    if (!permitted) {
      throw StateError(
        'Izin Bluetooth belum diberikan. '
        'Periksa izin aplikasi melalui Pengaturan Android.',
      );
    }

    final devices = await _bluetooth.bondedDevices();

    debugPrint('[BT DEVICES] ${devices.length} perangkat dipasangkan.');

    for (final device in devices) {
      debugPrint(
        '[BT DEVICE] ${device.name ?? "Tanpa nama"} - '
        '${device.address}',
      );
    }

    return devices;
  }

  Future<void> connect(BluetoothDevice device) async {
    if (_isDisposed) {
      throw StateError('BluetoothService sudah ditutup.');
    }

    if (_isConnecting) {
      throw StateError('Koneksi Bluetooth sedang berlangsung.');
    }

    if (isConnected) {
      debugPrint('[BT CONNECT] Koneksi sudah aktif.');
      return;
    }

    final permitted = await requestBluetoothPermissions();

    if (!permitted) {
      throw StateError('Izin Bluetooth belum diberikan.');
    }

    _isConnecting = true;

    try {
      await _closeCurrentConnection();

      _setState(EcuConnectionState.connecting);

      debugPrint(
        '[BT CONNECT] Menghubungkan ke '
        '${device.name ?? "Perangkat Bluetooth"} '
        '(${device.address})',
      );

      final connection = await _bluetooth.connect(
        device.address,
        insecureFallback: true,
        rfcommChannelFallback: true,
        timeout: const Duration(seconds: 15),
      );

      if (_isDisposed) {
        await connection.close();
        return;
      }

      _connection = connection;

      debugPrint(
        '[BT CONNECT] Objek koneksi diperoleh. '
        'isConnected=${connection.isConnected}',
      );

      _dataSubscription = connection.input.listen(
        (Uint8List bytes) {
          debugPrint(
            '[BT RX] Menerima ${bytes.length} byte: '
            '${_formatBytes(bytes)}',
          );

          if (!_dataController.isClosed) {
            _dataController.add(bytes);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[BT RX ERROR] $error');

          if (!_dataController.isClosed) {
            _dataController.addError(error, stackTrace);
          }

          _setState(EcuConnectionState.error);
        },
        onDone: () {
          debugPrint('[BT RX] Stream input ditutup.');

          if (identical(_connection, connection)) {
            _connection = null;
            _setState(EcuConnectionState.disconnected);
          }
        },
        cancelOnError: false,
      );

      _connectionStateSubscription = connection.state.listen(
        (SppConnectionState connectionState) {
          debugPrint('[BT CONNECTION EVENT] $connectionState');

          if (connectionState == SppConnectionState.disconnected &&
              identical(_connection, connection)) {
            _connection = null;
            _setState(EcuConnectionState.disconnected);
          }
        },
        onError: (Object error) {
          debugPrint('[BT CONNECTION ERROR] $error');
          _setState(EcuConnectionState.error);
        },
      );

      if (connection.isConnected) {
        _setState(EcuConnectionState.connected);
      } else {
        debugPrint(
          '[BT CONNECT] Socket diperoleh tetapi belum terhubung.',
        );
        _setState(EcuConnectionState.disconnected);
      }
    } catch (error, stackTrace) {
      debugPrint('[BT CONNECT ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);

      _connection = null;
      _setState(EcuConnectionState.error);

      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  /// Mengirim byte melalui Bluetooth SPP.
  ///
  /// Gunakan hanya untuk paket protokol ECU yang sudah terverifikasi.
  /// Metode ini tidak membuat atau menebak perintah ECU.
  Future<void> sendRawBytes(Uint8List bytes) async {
    if (_isDisposed) {
      throw StateError('BluetoothService sudah ditutup.');
    }

    final connection = _connection;

    if (connection == null || !connection.isConnected || !isConnected) {
      throw StateError('ECU belum terhubung.');
    }

    if (bytes.isEmpty) {
      throw ArgumentError('Data yang dikirim tidak boleh kosong.');
    }

    debugPrint(
      '[BT TX] Mengirim ${bytes.length} byte: '
      '${_formatBytes(bytes)}',
    );

    try {
      await connection.write(bytes);

      debugPrint('[BT TX] Penulisan byte selesai.');
    } catch (error, stackTrace) {
      debugPrint('[BT TX ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  String _formatBytes(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  Future<void> _closeCurrentConnection() async {
    await _dataSubscription?.cancel();
    _dataSubscription = null;

    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    final connection = _connection;
    _connection = null;

    if (connection != null) {
      try {
        await connection.close();
      } catch (error) {
        debugPrint('[BT CLOSE WARNING] $error');
      }
    }
  }

  Future<void> disconnect() async {
    await _closeCurrentConnection();

    _setState(EcuConnectionState.disconnected);

    debugPrint('[BT DISCONNECT] Koneksi Bluetooth ditutup.');
  }

  Future<void> dispose() async {
    if (_isDisposed) return;

    await disconnect();

    _isDisposed = true;

    await _dataController.close();
    await _stateController.close();
  }
}
