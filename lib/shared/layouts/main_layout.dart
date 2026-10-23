import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/engine_parameter/screens/engine_parameter_screen.dart';
import '../../features/ecu_connection/screens/ecu_diagnostics_screen.dart';
import '../../features/settings/screens/setting_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    DashboardScreen(),
    EngineParameterScreen(),
    EcuDiagnosticsScreen(),
    SettingScreen(),
  ];

  static const Color _background = Color(0xFF101720);
  static const Color _indicator = Color(0xFF263543);
  static const Color _accent = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF05080D),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: isLandscape ? 38 : 76,
          decoration: const BoxDecoration(
            color: _background,
            border: Border(
              top: BorderSide(
                color: Color(0xFF1B2733),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildDestination(
                index: 0,
                label: 'Dashboard',
                icon: Icons.speed_outlined,
                selectedIcon: Icons.speed,
                compact: isLandscape,
              ),
              _buildDestination(
                index: 1,
                label: 'Engine Data',
                icon: Icons.analytics_outlined,
                selectedIcon: Icons.analytics,
                compact: isLandscape,
              ),
              _buildDestination(
                index: 2,
                label: 'ECU Diagnostics',
                icon: Icons.cable_outlined,
                selectedIcon: Icons.cable,
                compact: isLandscape,
              ),
              _buildDestination(
                index: 3,
                label: 'Settings',
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                compact: isLandscape,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestination({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool compact,
  }) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 2,
              vertical: compact ? 2 : 6,
            ),
            child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        size: 18,
                        color: selected ? _accent : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: selected ? 52 : 38,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                              selected ? _indicator : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          selected ? selectedIcon : icon,
                          size: 22,
                          color: selected ? _accent : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
