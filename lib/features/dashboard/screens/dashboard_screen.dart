
import 'package:flutter/material.dart';

import 'dashboard_landscape.dart';
import 'dashboard_portrait.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080D),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return const DashboardLandscape();
            }

            return const DashboardPortrait();
          },
        ),
      ),
    );
  }
}
