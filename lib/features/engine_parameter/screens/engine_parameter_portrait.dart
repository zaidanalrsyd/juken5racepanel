import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/engine_data_provider.dart';

class EngineParameterPortrait extends StatelessWidget {
  const EngineParameterPortrait({super.key});

  static const Color background = Color(0xFF07090E);
  static const Color surface = Color(0xFF101821);
  static const Color border = Color(0xFF293642);
  static const Color yellow = Color(0xFFFFD329);
  static const Color green = Color(0xFF12D982);
  static const Color red = Color(0xFFFF354D);
  static const Color blue = Color(0xFF19A9FF);
  static const Color purple = Color(0xFFB779FF);
  static const Color muted = Color(0xFF858C98);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();
    final data = provider.data;
    final connected = provider.isConnected;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 14,
                6,
                compact ? 10 : 14,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(connected, compact),
                  const SizedBox(height: 12),
                  _sectionTitle('LIVE ENGINE DATA', 'MONITORING'),
                  const SizedBox(height: 10),

                  _buildRpmCard(data.rpm, compact),

                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildSensorCard(
                          title: 'TPS',
                          description: 'THROTTLE POSITION',
                          value: data.tps.toStringAsFixed(0),
                          unit: '%',
                          color: green,
                          icon: Icons.speed_rounded,
                          progress: (data.tps / 100).clamp(0.0, 1.0),
                          compact: compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSensorCard(
                          title: 'EOT',
                          description: 'OIL TEMPERATURE',
                          value: data.eot?.toStringAsFixed(0) ?? '--',
                          unit: '°C',
                          color: red,
                          icon: Icons.thermostat_rounded,
                          progress: data.eot == null
                              ? 0
                              : (data.eot! / 150).clamp(0.0, 1.0),
                          compact: compact,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildSensorCard(
                          title: 'AFR',
                          description: 'AIR FUEL RATIO',
                          value: data.afr.toStringAsFixed(1),
                          unit: 'AFR',
                          color: blue,
                          icon: Icons.air_rounded,
                          progress: (data.afr / 20).clamp(0.0, 1.0),
                          compact: compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSensorCard(
                          title: 'BAT',
                          description: 'BATTERY VOLTAGE',
                          value:
                              data.batteryVoltage?.toStringAsFixed(1) ?? '--',
                          unit: 'V',
                          color: purple,
                          icon: Icons.battery_charging_full_rounded,
                          progress: data.batteryVoltage == null
                              ? 0
                              : (data.batteryVoltage! / 16).clamp(0.0, 1.0),
                          compact: compact,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _sectionTitle('SYSTEM STATUS', 'ECU LINK'),
                  const SizedBox(height: 10),
                  _buildConnectionCard(connected, compact),
                  const SizedBox(height: 10),
                  _buildReadOnlyCard(compact),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool connected, bool compact) {
    final iconSize = compact ? 48.0 : 54.0;

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: const Color(0xFF17160F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: yellow.withValues(alpha: 0.4)),
          ),
          child: Icon(
            Icons.speed_rounded,
            color: yellow,
            size: compact ? 27 : 30,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: compact ? 23 : 27,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                    children: const [
                      TextSpan(
                        text: 'JUKEN ',
                        style: TextStyle(color: yellow),
                      ),
                      TextSpan(
                        text: '5+',
                        style: TextStyle(color: red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'ENGINE PARAMETERS',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 9,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF17140E),
            border: Border.all(
              color: connected
                  ? green.withValues(alpha: 0.6)
                  : const Color(0xFF60471C),
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 7,
                color: connected ? green : const Color(0xFFFFA52E),
              ),
              const SizedBox(width: 5),
              Text(
                connected ? 'ECU ONLINE' : 'ECU OFFLINE',
                style: TextStyle(
                  color: connected ? green : const Color(0xFFFFB547),
                  fontSize: compact ? 8 : 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String trailing) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: Color(0xFF626873),
            fontSize: 8,
            letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRpmCard(int rpm, bool compact) {
    final progress = (rpm / 13000).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: yellow, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ENGINE SPEED',
                  style: TextStyle(
                    color: Color(0xFFB5BBC5),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'RPM',
                style: TextStyle(
                  color: yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$rpm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 46 : 54,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(
                    text: ' RPM',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF2B3541),
              valueColor: const AlwaysStoppedAnimation<Color>(yellow),
            ),
          ),
          const SizedBox(height: 7),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 RPM', style: TextStyle(color: muted, fontSize: 9)),
              Text(
                'MAX 13,000 RPM',
                style: TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String description,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
    required double progress,
    required bool compact,
  }) {
    final padding = compact ? 10.0 : 12.0;

    return Container(
      constraints: const BoxConstraints(minHeight: 155),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 34 : 40,
                height: compact ? 34 : 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: compact ? 20 : 23),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            maxLines: 2,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
              height: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color,
                      fontSize: compact ? 28 : 33,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF29323D),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(bool connected, bool compact) {
    final color = connected ? green : const Color(0xFFFFB547);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ECU CONNECTION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connected
                      ? 'Perangkat Bluetooth tersambung.'
                      : 'Belum ada koneksi ECU yang aktif.',
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            connected ? 'CONNECTED' : 'ECU OFFLINE',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyCard(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: green, size: 25),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'READ-ONLY MONITORING',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aplikasi hanya memantau data dan tidak mengubah mapping ECU.',
                  style: TextStyle(color: muted, fontSize: 10, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
