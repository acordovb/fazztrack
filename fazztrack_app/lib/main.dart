import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/pages/splash/splash_screen.dart';
import 'package:fazztrack_app/pages/local_selection/local_selection_screen.dart';
import 'package:fazztrack_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Asegura que Flutter esté inicializado antes de llamar a cualquier plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa los servicios antes de ejecutar la aplicación
  await LocalStorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fazztrack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTurquoise,
        ),
      ),
      home: SplashScreen(
        nextScreen: LocalSelectionScreen(
          nextScreen: const MyHomePage(title: 'Fazztrack App'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedLocal;

  @override
  void initState() {
    super.initState();
    _loadSelectedLocal();
  }

  Future<void> _loadSelectedLocal() async {
    final local = await LocalStorageService.getSelectedLocal();
    if (mounted) {
      setState(() {
        selectedLocal = local;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tu local seleccionado:',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(
              selectedLocal ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
