import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/engine_data.dart';
import '../../../data/providers/engine_data_provider.dart';
import '../widgets/rpm_gauge.dart';
import '../widgets/sensor_card.dart';

class DashboardPortrait extends StatefulWidget {
  const DashboardPortrait({super.key});

  @override
  State<DashboardPortrait> createState() => _DashboardPortraitState();
}

class _DashboardPortraitState extends State<DashboardPortrait> {
  Timer? _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateClock();

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateClock(),
    );
  }

  void _updateClock() {
    if (!mounted) return;

    final now = DateTime.now();

    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EngineDataProvider>();
    final data = provider.data;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Column(
        children: [
          _buildHeader(provider.connectionStatus),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRpm(data),
                    const SizedBox(height: 18),
                    RpmGauge(rpm: data.rpm, maxRpm: 13000, redlineRpm: 11000),
                    const SizedBox(height: 20),
                    SizedBox(height: 92, child: _buildSensors(data)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String status) {
    final connected = status == 'ECU CONNECTED';
    final statusColor = connected
        ? AppColors.racingGreen
        : const Color(0xFFFFA726);

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const Expanded(child: _Brand()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 7, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRpm(EngineData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.rpm.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 62,
                height: 1,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        const Text(
          'RPM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSensors(EngineData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SensorCard(
            title: 'EOT',
            value: data.eot?.toStringAsFixed(0) ?? '--',
            unit: '°C',
            accentColor: AppColors.racingRed,
            icon: Icons.device_thermostat,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: SensorCard(
            title: 'TPS',
            value: data.tps.toStringAsFixed(0),
            unit: '%',
            accentColor: AppColors.racingGreen,
            icon: Icons.speed,
            progress: (data.tps / 100).clamp(0.0, 1.0),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: SensorCard(
            title: 'AFR',
            value: data.afr.toStringAsFixed(1),
            unit: '',
            accentColor: AppColors.racingBlue,
            icon: Icons.adjust,
          ),
        ),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'JUKEN ',
              style: TextStyle(
                color: Color(0xFFFFD21F),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '5+',
              style: TextStyle(
                color: Color(0xFFFF2638),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        Text(
          'RACE PANEL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
