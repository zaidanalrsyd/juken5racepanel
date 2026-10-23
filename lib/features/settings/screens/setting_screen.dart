
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF05080D);
    const surface = Color(0xFF101720);
    const border = Color(0xFF263543);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'APPEARANCE',
            style: TextStyle(
              color: Color(0xFFFFD21F),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: SwitchListTile(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
              },
              activeThumbColor: const Color(0xFFFF2638),
              secondary: Icon(
                _darkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFFFFD21F),
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _darkMode
                    ? 'Dark appearance selected'
                    : 'Light appearance selected',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ABOUT',
            style: TextStyle(
              color: Color(0xFFFFD21F),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JUKEN 5+ RACE PANEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Motorcycle engine monitoring dashboard.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'ECU integration: Not connected',
                  style: TextStyle(
                    color: Color(0xFFFFA726),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
