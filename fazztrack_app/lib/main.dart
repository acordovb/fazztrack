import 'package:fazztrack_app/config/general.config.dart';
import 'package:fazztrack_app/pages/init/route_decider.dart';
import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/pages/splash/splash_screen.dart';

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
      home: const SplashScreen(nextScreen: RouteDecider()),
      debugShowCheckedModeBanner: false,
    );
  }
}
