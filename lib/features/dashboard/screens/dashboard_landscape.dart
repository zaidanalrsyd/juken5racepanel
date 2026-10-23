import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/engine_data.dart';
import '../../../data/providers/engine_data_provider.dart';
import '../widgets/rpm_gauge.dart';

class DashboardLandscape extends StatelessWidget {
  const DashboardLandscape({super.key});

  static const Color bg = Color(0xFF05070A);
  static const Color panel = Color(0xFF10151D);
  static const Color border = Color(0xFF28313D);
  static const Color yellow = Color(0xFFFFD21F);
  static const Color red = Color(0xFFFF4055);
  static const Color green = Color(0xFF27E58A);
  static const Color blue = Color(0xFF22B8F0);
  static const Color muted = Color(0xFF8C98A8);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();
    final EngineData data = provider.data;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 300;
        final headerHeight = compact ? 30.0 : 38.0;
        final sensorHeight = compact ? 68.0 : 88.0;

        return Container(
          color: bg,
          padding: EdgeInsets.fromLTRB(
            12,
            compact ? 2 : 5,
            12,
            compact ? 3 : 7,
          ),
          child: Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: _buildHeader(provider.connectionStatus),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, area) {
                          final short = area.maxHeight < 115;
                          final rpmFont = short ? 48.0 : 76.0;
                          final gaugeHeight = short ? 32.0 : 43.0;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        data.rpm.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: rpmFont,
                                          height: 0.95,
                                          fontWeight: FontWeight.w900,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: -2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'RPM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: compact ? 10 : 15,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: short ? 2 : 6),
                              SizedBox(
                                height: gaugeHeight,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: RpmGauge(
                                    rpm: data.rpm,
                                    maxRpm: 13000,
                                    redlineRpm: 11000,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: compact ? 3 : 7),
                    SizedBox(
                      height: sensorHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: _sensorCard(
                              title: 'EOT',
                              subtitle: 'ENGINE OIL TEMP',
                              value: data.eot?.toStringAsFixed(0) ?? '--',
                              unit: '°C',
                              color: red,
                              icon: Icons.thermostat_rounded,
                              progress: data.eot == null
                                  ? 0
                                  : (data.eot! / 150).clamp(0.0, 1.0),
                              minLabel: '0',
                              maxLabel: '150',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _sensorCard(
                              title: 'TPS',
                              subtitle: 'THROTTLE POSITION',
                              value: data.tps.toStringAsFixed(0),
                              unit: '%',
                              color: green,
                              icon: Icons.speed_rounded,
                              progress: (data.tps / 100).clamp(0.0, 1.0),
                              minLabel: '0',
                              maxLabel: '100',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _sensorCard(
                              title: 'AFR',
                              subtitle: 'AIR / FUEL RATIO',
                              value: data.afr.toStringAsFixed(1),
                              unit: '',
                              color: blue,
                              icon: Icons.donut_large_rounded,
                              progress: ((data.afr - 10) / 8).clamp(0.0, 1.0),
                              minLabel: '10.0',
                              maxLabel: '18.0',
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
        );
      },
    );
  }

  Widget _buildHeader(String connectionStatus) {
    final connected = connectionStatus == 'ECU CONNECTED';
    final statusColor = connected ? green : red;

    return Row(
      children: [
        const Text(
          'JUKEN',
          style: TextStyle(
            color: yellow,
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Text(
          ' 5+',
          style: TextStyle(
            color: red,
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 10),
        Container(width: 1, height: 23, color: border),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'ENGINE MONITOR',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                connectionStatus,
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

  Widget _sensorCard({
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
    required double progress,
    required String minLabel,
    required String maxLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.48)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.045), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 7,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (unit.isNotEmpty)
                  Text(
                    ' $unit',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 4,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: const TextStyle(color: muted, fontSize: 7)),
              Text(maxLabel, style: const TextStyle(color: muted, fontSize: 7)),
            ],
          ),
        ],
      ),
    );
  }
}
