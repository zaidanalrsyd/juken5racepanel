import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/engine_data_provider.dart';

class EngineParameterLandscape extends StatelessWidget {
  const EngineParameterLandscape({super.key});

  static const Color _background = Color(0xFF05080D);
  static const Color _surface = Color(0xFF101720);
  static const Color _border = Color(0xFF263543);
  static const Color _yellow = Color(0xFFFFD21F);
  static const Color _red = Color(0xFFFF2638);
  static const Color _green = Color(0xFF00E676);
  static const Color _blue = Color(0xFF00A8FF);
  static const Color _purple = Color(0xFFB388FF);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();
    final data = provider.data;
    final statusColor = provider.isConnected ? _green : const Color(0xFFFFA726);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 360;
            final gap = compact ? 6.0 : 9.0;

            return Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: Column(
                children: [
                  _buildHeader(provider.connectionStatus, statusColor, compact),
                  SizedBox(height: gap),
                  _buildSectionTitle(),
                  SizedBox(height: gap),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildRpmCard(data.rpm, compact),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildSensorCard(
                                        title: 'TPS',
                                        value: data.tps.toStringAsFixed(0),
                                        unit: '%',
                                        color: _green,
                                        icon: Icons.speed,
                                        progress: (data.tps / 100).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        compact: compact,
                                      ),
                                    ),
                                    SizedBox(width: gap),
                                    Expanded(
                                      child: _buildSensorCard(
                                        title: 'EOT',
                                        value:
                                            data.eot?.toStringAsFixed(0) ??
                                            '--',
                                        unit: '°C',
                                        color: _red,
                                        icon: Icons.device_thermostat,
                                        progress: data.eot == null
                                            ? 0
                                            : (data.eot! / 150).clamp(0.0, 1.0),
                                        compact: compact,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: gap),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildSensorCard(
                                        title: 'AFR',
                                        value: data.afr.toStringAsFixed(1),
                                        unit: 'AFR',
                                        color: _blue,
                                        icon: Icons.air,
                                        progress: (data.afr / 20).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        compact: compact,
                                      ),
                                    ),
                                    SizedBox(width: gap),
                                    Expanded(
                                      child: _buildSensorCard(
                                        title: 'BATTERY',
                                        value:
                                            data.batteryVoltage
                                                ?.toStringAsFixed(2) ??
                                            '--',
                                        unit: 'V',
                                        color: _purple,
                                        icon: Icons.battery_charging_full,
                                        progress: data.batteryVoltage == null
                                            ? 0
                                            : (data.batteryVoltage! / 16).clamp(
                                                0.0,
                                                1.0,
                                              ),
                                        compact: compact,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: gap),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildConnectionStatus(
                          provider.connectionStatus,
                          statusColor,
                          compact,
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(flex: 6, child: _buildSimulationNotice(compact)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String status, Color statusColor, bool compact) {
    return Row(
      children: [
        Container(
          width: compact ? 30 : 36,
          height: compact ? 30 : 36,
          decoration: BoxDecoration(
            color: _yellow.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _yellow.withValues(alpha: 0.35)),
          ),
          child: Icon(Icons.speed, color: _yellow, size: compact ? 18 : 21),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'JUKEN ',
                    style: TextStyle(
                      color: _yellow,
                      fontSize: compact ? 15 : 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    '5+',
                    style: TextStyle(
                      color: _red,
                      fontSize: compact ? 15 : 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const Text(
                'ENGINE PARAMETERS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: statusColor, size: 7),
              const SizedBox(width: 5),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      children: [
        Icon(Icons.monitor_heart_outlined, color: _yellow, size: 15),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'LIVE ENGINE DATA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ),
        Text(
          'MONITORING',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRpmCard(int rpm, bool compact) {
    final progress = (rpm / 13000).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17212D), Color(0xFF0C121A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: _yellow, size: 16),
              SizedBox(width: 6),
              Text(
                'ENGINE SPEED',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 7 : 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$rpm',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 34 : 48,
                height: 1,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'RPM',
            style: TextStyle(
              color: _yellow,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 8 : 13),
          _rpmBar(progress),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(color: Colors.white38, fontSize: 8)),
              Text(
                '13,000',
                style: TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rpmBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(height: 8, color: const Color(0xFF26313E)),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, _yellow, Color(0xFFFF8A00), _red],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
    required double progress,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(compact ? 8 : 11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 24 : 29,
                height: compact ? 24 : 29,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: compact ? 15 : 18),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 8 : 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: compact ? 23 : 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFF27313D),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(String status, Color color, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_disabled, color: color, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationNotice(bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFFFA726).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFFA726), size: 15),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'SIMULASI • Data ECU nyata belum tersedia. Mapping tidak diubah.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}
