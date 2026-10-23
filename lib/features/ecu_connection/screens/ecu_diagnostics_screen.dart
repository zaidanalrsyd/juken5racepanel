import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

import '../../../data/providers/engine_data_provider.dart';
import '../services/ecu_data_parser.dart';
import '../services/bluetooth_service.dart';

class EcuDiagnosticsScreen extends StatefulWidget {
  const EcuDiagnosticsScreen({super.key});

  @override
  State<EcuDiagnosticsScreen> createState() => _EcuDiagnosticsScreenState();
}

class _EcuDiagnosticsScreenState extends State<EcuDiagnosticsScreen> {
  StreamSubscription<Uint8List>? _subscription;

  final List<String> _logs = [];
  List<String> _latestA603Fields = const [];

  int _totalBytes = 0;
  bool _listening = false;
  bool _searchingDevices = false;
  bool _startingLive = false;
  bool _requestingSensorSnapshot = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_listening) return;
    _listening = true;

    final provider = context.read<EngineDataProvider>();

    _subscription = provider.incomingDiagnosticsData.listen(
      _handleIncomingData,
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _addLog('ERROR: $error'));
      },
    );
  }

  void _handleIncomingData(Uint8List bytes) {
    if (!mounted) return;

    final raw = EcuDataParser.formatRawBytes(bytes);
    final time = TimeOfDay.now().format(context);
    final decoded = utf8.decode(bytes, allowMalformed: true);
    final isSimulation = decoded.startsWith('SIM,');
    final rawSensorFields = EcuDataParser.parseRawSensorFields(bytes);

    setState(() {
      _totalBytes += bytes.length;
      if (rawSensorFields != null) {
        _latestA603Fields = rawSensorFields;
      }

      if (isSimulation) {
        _addLog('$time | SIMULATION | ${bytes.length} byte | $raw');
      } else {
        _addLog(
          '$time | ECU LINE | ${bytes.length} byte | '
          '${decoded.trimRight()} | HEX: $raw',
        );
      }
    });
  }

  void _addLog(String message) {
    _logs.insert(0, message);
    if (_logs.length > 100) _logs.removeLast();
  }

  void _toggleSimulation(EngineDataProvider provider) {
    if (provider.isSimulationRunning) {
      provider.stopSimulation();
    } else {
      provider.startSimulation();
    }
  }

  Future<void> _connectBluetooth(EngineDataProvider provider) async {
    if (_searchingDevices || provider.isConnected) return;

    setState(() => _searchingDevices = true);

    try {
      final enabled = await provider.enableBluetooth();

      if (!mounted) return;

      if (!enabled) {
        _showMessage(
          'Bluetooth belum aktif. Aktifkan Bluetooth lalu coba lagi.',
        );
        return;
      }

      final devices = await provider.getPairedDevices();

      if (!mounted) return;

      if (devices.isEmpty) {
        _showMessage(
          'Tidak ada perangkat yang dipasangkan. '
          'Pasangkan perangkat ECU melalui pengaturan Bluetooth Android.',
        );
        return;
      }

      final device = await showDialog<BluetoothDevice>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF171717),
            title: const Text(
              'PILIH PERANGKAT ECU',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: devices.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final name = device.name?.trim().isNotEmpty == true
                      ? device.name!
                      : 'Perangkat Bluetooth';

                  return ListTile(
                    leading: const Icon(
                      Icons.bluetooth,
                      color: Color(0xFF22B8F0),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      device.address,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () => Navigator.pop(dialogContext, device),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('BATAL'),
              ),
            ],
          );
        },
      );

      if (!mounted || device == null) return;

      await provider.connectToDevice(device);

      if (!mounted) return;

      _showMessage(
        provider.isConnected
            ? 'Bluetooth berhasil terhubung.'
            : 'Koneksi belum terkonfirmasi. Periksa perangkat ECU.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal menghubungkan Bluetooth: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _searchingDevices = false);
      }
    }
  }

  /// Meminta data sensor memakai perintah yang telah teruji di perangkat ini.
  Future<void> _startLive(EngineDataProvider provider) async {
    if (_startingLive || provider.isLiveRequested) return;

    setState(() => _startingLive = true);

    try {
      await provider.startLive();

      if (mounted) {
        _showMessage(
          'Permintaan data Live terkirim. Periksa baris A603 yang masuk.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal memulai Live: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _startingLive = false);
      }
    }
  }

  Future<void> _requestSensorSnapshot(EngineDataProvider provider) async {
    if (_requestingSensorSnapshot) return;

    setState(() => _requestingSensorSnapshot = true);

    try {
      await provider.requestSensorSnapshot();

      if (mounted) {
        _showMessage(
          'Permintaan sensor terkirim. Periksa log untuk data masuk.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal meminta snapshot sensor: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _requestingSensorSnapshot = false);
      }
    }
  }

  Future<void> _disconnectBluetooth(EngineDataProvider provider) async {
    try {
      await provider.disconnectFromDevice();

      if (mounted) {
        _showMessage('Bluetooth diputus.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal memutus koneksi: $error');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _totalBytes = 0;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();
    final simulationRunning = provider.isSimulationRunning;
    final connected = provider.isConnected;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text('ECU DIAGNOSTICS', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 300;
            final padding = compact ? 10.0 : 16.0;
            final logHeight = (constraints.maxHeight * 0.30)
                .clamp(90.0, 180.0)
                .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusCard(provider, compact),

                  SizedBox(height: compact ? 6 : 10),

                  // CONNECT ECU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: connected || _searchingDevices
                          ? null
                          : () => _connectBluetooth(provider),
                      icon: _searchingDevices
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(
                        _searchingDevices
                            ? 'MENCARI PERANGKAT...'
                            : 'CONNECT ECU',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22B8F0),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white12,
                        disabledForegroundColor: Colors.white38,
                        padding: EdgeInsets.symmetric(
                          vertical: compact ? 8 : 13,
                        ),
                      ),
                    ),
                  ),

                  // START LIVE dan DISCONNECT hanya tersedia
                  // setelah koneksi Bluetooth terkonfirmasi.
                  if (connected) ...[
                    const SizedBox(height: 6),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _requestingSensorSnapshot
                            ? null
                            : () => _requestSensorSnapshot(provider),
                        icon: _requestingSensorSnapshot
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sensors),
                        label: Text(
                          _requestingSensorSnapshot
                              ? 'MEMINTA DATA SENSOR...'
                              : 'TEST READ SENSOR ONCE',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF22B8F0),
                          side: const BorderSide(color: Color(0xFF22B8F0)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startingLive || provider.isLiveRequested
                            ? null
                            : () => _startLive(provider),
                        icon: _startingLive
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          _startingLive
                              ? 'MEMULAI LIVE...'
                              : provider.isLiveRequested
                              ? 'LIVE REQUESTED'
                              : 'START LIVE',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22B8F0),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white12,
                          disabledForegroundColor: Colors.white38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _disconnectBluetooth(provider),
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('DISCONNECT ECU'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: compact ? 6 : 10),

                  // SIMULASI DATA LOKAL
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: connected
                          ? null
                          : () => _toggleSimulation(provider),
                      icon: Icon(
                        simulationRunning
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                      ),
                      label: Text(
                        simulationRunning
                            ? 'STOP SIMULATION'
                            : 'START DATA SIMULATION',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD21F),
                        side: const BorderSide(color: Color(0xFFFFD21F)),
                        padding: EdgeInsets.symmetric(
                          vertical: compact ? 7 : 12,
                        ),
                      ),
                    ),
                  ),

                  if (simulationRunning) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'SIMULATION ACTIVE • DATA UJI, BUKAN DATA ECU ASLI',
                      style: TextStyle(color: Color(0xFFFFD21F), fontSize: 10),
                    ),
                  ],

                  SizedBox(height: compact ? 7 : 12),

                  if (_latestA603Fields.isNotEmpty) ...[
                    _buildRawSensorFields(),
                    SizedBox(height: compact ? 7 : 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          'COMPLETE-LINE BYTES',
                          '$_totalBytes',
                          compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _metricCard(
                          'LOG ENTRIES',
                          '${_logs.length}',
                          compact,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: compact ? 7 : 12),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'RAW BLUETOOTH DATA / TEST DATA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _clearLogs,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('CLEAR'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.yellow,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  SizedBox(height: logHeight, child: _buildLogPanel()),

                  SizedBox(height: compact ? 6 : 10),

                  const Text(
                    'READ-ONLY • Data uji lokal tidak dikirim ke ECU. '
                    'Protokol sensor ECU belum diverifikasi.',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: _logs.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data masuk.\n'
                'Hubungkan ECU atau mulai simulasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final isSimulation = _logs[index].contains('| SIMULATION |');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableText(
                    _logs[index],
                    style: TextStyle(
                      color: isSimulation
                          ? const Color(0xFFFFD21F)
                          : Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRawSensorFields() {
    const confirmedFields = <int, (String, String)>{
      0: ('TPS', '%'),
      1: ('BATTERY', 'V'),
      3: ('RPM', 'RPM'),
      6: ('AFR', 'AFR'),
    };
    final unmappedFieldIndexes = [
      for (var index = 0; index < _latestA603Fields.length; index++)
        if (!confirmedFields.containsKey(index)) index,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A603 • DATA SENSOR TERPISAH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'FIELD TERKONFIRMASI',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 6.0;
            final itemWidth = (constraints.maxWidth - spacing * 2) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final entry in confirmedFields.entries)
                  if (entry.key < _latestA603Fields.length)
                    _sensorFieldCard(
                      itemWidth: itemWidth,
                      fieldNumber: entry.key + 1,
                      label: entry.value.$1,
                      unit: entry.value.$2,
                      value: _latestA603Fields[entry.key],
                      color: Colors.greenAccent,
                    ),
              ],
            );
          },
        ),
        if (unmappedFieldIndexes.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'FIELD LAIN • BELUM DIKENALI',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 6.0;
              final itemWidth = (constraints.maxWidth - spacing * 2) / 3;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final index in unmappedFieldIndexes)
                    _sensorFieldCard(
                      itemWidth: itemWidth,
                      fieldNumber: index + 1,
                      label: 'BELUM DIPETAKAN',
                      value: _latestA603Fields[index],
                      color: Colors.white70,
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _sensorFieldCard({
    required double itemWidth,
    required int fieldNumber,
    required String label,
    required String value,
    required Color color,
    String? unit,
  }) {
    return Container(
      width: itemWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIELD $fieldNumber • $label',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          SelectableText(
            value.isEmpty
                ? '(kosong)'
                : '$value${unit == null ? '' : ' $unit'}',
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(EngineDataProvider provider, bool compact) {
    final connected = provider.isConnected;
    final connecting =
        provider.connectionState == EcuConnectionState.connecting;

    final statusColor = connected
        ? Colors.greenAccent
        : connecting
        ? Colors.orangeAccent
        : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONNECTION STATUS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            provider.connectionStatus,
            style: TextStyle(
              color: statusColor,
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 9 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          SizedBox(height: compact ? 3 : 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
