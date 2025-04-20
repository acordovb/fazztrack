import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/services/bar_storage_service.dart';
import 'package:flutter/material.dart';

class BaseProcedures extends StatefulWidget {
  const BaseProcedures({super.key, required this.title});
  final String title;

  @override
  State<BaseProcedures> createState() => _BaseProceduresState();
}

class _BaseProceduresState extends State<BaseProcedures> {
  String? selectedBar;

  @override
  void initState() {
    super.initState();
    _loadSelectedBar();
  }

  Future<void> _loadSelectedBar() async {
    final bar = await BarStorageService.getSelectedBar();
    if (mounted) {
      setState(() {
        selectedBar = bar;
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
              'Tu bar seleccionado:',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Text(
              selectedBar ?? 'Cargando...',
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
