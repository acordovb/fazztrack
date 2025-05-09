import 'package:flutter/material.dart';
import 'package:fazztrack_app/common/constants/colors_constants.dart';
import 'package:fazztrack_app/services/bar/bar_storage_service.dart';
import 'package:fazztrack_app/services/bar/bar_api_service.dart';
import 'package:fazztrack_app/common/model/bar_model.dart';

class BarSelectionScreen extends StatefulWidget {
  final Widget nextScreen;

  const BarSelectionScreen({super.key, required this.nextScreen});

  @override
  State<BarSelectionScreen> createState() => _BarSelectionScreenState();
}

class _BarSelectionScreenState extends State<BarSelectionScreen> {
  final List<BarModel> _barList = [];
  final BarApiService _barApiService = BarApiService();
  bool _isLoading = true;
  String? _selectedBarId;

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    try {
      final bars = await _barApiService.getAllBars();
      setState(() {
        _barList.clear();
        _barList.addAll(bars);
        _isLoading = false;
      });
      _loadSavedBar();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedBar() async {
    final savedBarId = await BarStorageService.getSelectedBar();
    if (savedBarId != null && _barList.isNotEmpty) {
      final selectedBar = _barList.firstWhere(
        (bar) => bar.id == savedBarId,
        orElse: () => _barList.first,
      );
      setState(() {
        _selectedBarId = selectedBar.id;
      });
    } else if (_barList.isNotEmpty) {
      setState(() {
        _selectedBarId = _barList.first.id;
      });
    }
  }

  void _saveSelectionAndContinue() async {
    if (_selectedBarId != null) {
      await BarStorageService.saveSelectedBar(_selectedBarId!);
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
                if (_isLoading)
                  const CircularProgressIndicator(color: AppColors.primary)
                else
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
                          value: _selectedBarId,
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
                              _selectedBarId = value;
                            });
                          },
                          items:
                              _barList.map<DropdownMenuItem<String>>((
                                BarModel bar,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: bar.id,
                                  child: Text(bar.nombre),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed:
                      _barList.isEmpty ? null : _saveSelectionAndContinue,
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
