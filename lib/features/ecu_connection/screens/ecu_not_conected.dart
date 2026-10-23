
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_spp/bluetooth_spp.dart';

import '../../../data/providers/engine_data_provider.dart';

class EcuNotConnectedScreen extends StatefulWidget {
  const EcuNotConnectedScreen({super.key});

  @override
  State<EcuNotConnectedScreen> createState() =>
      _EcuNotConnectedScreenState();
}

class _EcuNotConnectedScreenState
    extends State<EcuNotConnectedScreen> {
  List<BluetoothDevice> _devices = [];
  String _message = 'Perangkat Bluetooth belum dimuat.';
  String? _connectingAddress;
  bool _loading = false;

  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _message = 'Memuat perangkat yang sudah dipasangkan...';
    });

    try {
      final provider = context.read<EngineDataProvider>();
      final enabled = await provider.enableBluetooth();

      if (!enabled) {
        if (!mounted) return;

        setState(() {
          _devices = [];
          _message = 'Bluetooth belum aktif.';
        });
        return;
      }

      final devices = await provider.getPairedDevices();

      if (!mounted) return;

      setState(() {
        _devices = devices;
        _message = devices.isEmpty
            ? 'Tidak ada perangkat yang sudah dipasangkan.'
            : 'Pilih perangkat Bluetooth untuk dihubungkan.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Gagal memuat perangkat: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() {
      _connectingAddress = device.address;
    });

    try {
      await context
          .read<EngineDataProvider>()
          .connectToDevice(device);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koneksi Bluetooth berhasil.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi gagal: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _connectingAddress = null);
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await context
          .read<EngineDataProvider>()
          .disconnectFromDevice();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth terputus.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memutus koneksi: $error'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDevices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'ECU CONNECTION',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: provider.isConnected
                      ? Colors.green
                      : Colors.redAccent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONNECTION STATUS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.connectionStatus,
                    style: TextStyle(
                      color: provider.isConnected
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Read-only connection. ECU mapping tidak diubah.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  if (provider.isConnected) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _disconnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('DISCONNECT'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'PAIRED DEVICES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _loadDevices,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('REFRESH'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.yellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_devices.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _message,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              )
            else
              ..._devices.map((device) {
                final connecting =
                    _connectingAddress == device.address;

                final deviceName = device.name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white12,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.bluetooth,
                      color: Colors.lightBlueAccent,
                      size: 30,
                    ),
                    title: Text(
                      (deviceName?.isNotEmpty ?? false)
                          ? deviceName!
                          : 'Bluetooth device',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      device.address,
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed:
                          provider.isConnected ||
                                  _connectingAddress != null
                              ? null
                              : () => _connect(device),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        connecting ? 'WAIT...' : 'CONNECT',
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}