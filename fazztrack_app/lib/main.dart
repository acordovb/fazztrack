import 'package:fazztrack_app/config/general.config.dart';
import 'package:fazztrack_app/pages/procedures/base_procedures.dart';
import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/pages/splash/splash_screen.dart';
import 'package:fazztrack_app/pages/init/bar_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTurquoise,
        ),
      ),
      home: SplashScreen(
        nextScreen: BarSelectionScreen(
          nextScreen: const BaseProcedures(title: 'Fazztrack App'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
