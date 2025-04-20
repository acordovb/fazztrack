import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/services/local_storage_service.dart';

class LocalSelectionScreen extends StatefulWidget {
  final Widget nextScreen;

  const LocalSelectionScreen({super.key, required this.nextScreen});

  @override
  State<LocalSelectionScreen> createState() => _LocalSelectionScreenState();
}

class _LocalSelectionScreenState extends State<LocalSelectionScreen> {
  // Lista de nombres de locales (ejemplo)
  final List<String> _localesList = ['Local Barcelona', 'Local Madrid'];

  // Valor seleccionado por defecto
  String? _selectedLocal;

  @override
  void initState() {
    super.initState();
    // Intentar recuperar un local guardado previamente
    _loadSavedLocal();
  }

  // Cargar local guardado si existe
  Future<void> _loadSavedLocal() async {
    final savedLocal = await LocalStorageService.getSelectedLocal();
    if (savedLocal != null) {
      setState(() {
        _selectedLocal = savedLocal;
      });
    } else {
      setState(() {
        _selectedLocal = _localesList.first; // Valor por defecto
      });
    }
  }

  // Guardar la selección y navegar a la siguiente pantalla
  void _saveSelectionAndContinue() async {
    if (_selectedLocal != null) {
      await LocalStorageService.saveSelectedLocal(_selectedLocal!);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.nextScreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.gradient,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Escoger el local',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocal,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundSecondary,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedLocal = value;
                        });
                      },
                      items:
                          _localesList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveSelectionAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
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
