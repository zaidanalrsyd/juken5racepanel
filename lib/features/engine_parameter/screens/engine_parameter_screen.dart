
import 'package:flutter/material.dart';

import 'engine_parameter_portrait.dart';
import 'engine_parameter_landscape.dart';

class EngineParameterScreen extends StatelessWidget {
  const EngineParameterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const EngineParameterLandscape();
        }

        return const EngineParameterPortrait();
      },
    );
  }
}
