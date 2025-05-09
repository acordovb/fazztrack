import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/colors.dart';
import 'package:fazztrack_app/services/local_storages/bar_storage_service.dart';

class BarSelectionScreen extends StatefulWidget {
  final Widget nextScreen;

  const BarSelectionScreen({super.key, required this.nextScreen});

  @override
  State<BarSelectionScreen> createState() => _BarSelectionScreenState();
}

class _BarSelectionScreenState extends State<BarSelectionScreen> {
  final List<String> _barList = ['Bar Ecomundo', 'Bar Moderna'];

  String? _selectedBar;

  @override
  void initState() {
    super.initState();
    _loadSavedBar();
  }

  Future<void> _loadSavedBar() async {
    final savedBar = await BarStorageService.getSelectedBar();
    if (savedBar != null) {
      setState(() {
        _selectedBar = savedBar;
      });
    } else {
      setState(() {
        _selectedBar = _barList.first;
      });
    }
  }

  void _saveSelectionAndContinue() async {
    if (_selectedBar != null) {
      await BarStorageService.saveSelectedBar(_selectedBar!);
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
                  'Escoger el Bar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width > 500
                          ? 500
                          : double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBar,
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
                            _selectedBar = value;
                          });
                        },
                        items:
                            _barList.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
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
