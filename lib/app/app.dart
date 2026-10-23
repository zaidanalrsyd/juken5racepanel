
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/providers/engine_data_provider.dart';
import '../shared/layouts/main_layout.dart';

class JukenRacePanelApp extends StatelessWidget {
  const JukenRacePanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EngineDataProvider(),
      child: MaterialApp(
        title: 'JUKEN 5+ Race Panel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainLayout(),
      ),
    );
  }
}
