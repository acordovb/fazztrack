import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/model/estudiante_model.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/control_historico_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SaldoClienteWidget extends StatefulWidget {
  const SaldoClienteWidget({super.key});

  @override
  State<SaldoClienteWidget> createState() => _SaldoClienteWidgetState();
}

class _SaldoClienteWidgetState extends State<SaldoClienteWidget> {
  String? selectedClient;
  String? selectedClientId;
  double balance = 0.0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<EstudianteModel> filteredEstudiantes = [];
  Timer? _debounceTimer;
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final ControlHistoricoApiService _controlHistoricoService =
      ControlHistoricoApiService();
  bool _isLoading = false;
  bool _isLoadingBalance = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchStudentBalance(String estudianteId) async {
    setState(() {
      _isLoadingBalance = true;
    });

    try {
      final controlHistorico = await _controlHistoricoService
          .getControlHistoricoByEstudianteId(estudianteId);

      if (controlHistorico != null) {
        setState(() {
          balance = controlHistorico.totalAbono - controlHistorico.totalVenta;
          _isLoadingBalance = false;
        });
      } else {
        setState(() {
          balance = 0.0;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      setState(() {
        balance = 0.0;
        _isLoadingBalance = false;
      });
    }
  }

  void _searchEstudiantes(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    setState(() {
      _isLoading = true;
    });

    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      if (query.isEmpty) {
        setState(() {
          filteredEstudiantes = [];
          _isLoading = false;
        });
        return;
      }

      try {
        final estudiantes = await _estudiantesService.searchEstudiantesByName(
          query,
        );
        setState(() {
          filteredEstudiantes = estudiantes;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          filteredEstudiantes = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceColor =
        balance > 0
            ? AppColors.success
            : balance < 0
            ? AppColors.error
            : Colors.white;
    final balanceText = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    ).format(balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  filteredEstudiantes = [];
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedClient ?? 'Buscar estudiante...',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSearching ? 50 : 0,
                    child:
                        _isSearching
                            ? TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.lightGray,
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 40,
                                ),
                                hintText: "Buscar estudiante...",
                                hintStyle: TextStyle(
                                  color: AppColors.lightGray,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                isDense: true,
                                alignLabelWithHint: true,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              onChanged: _searchEstudiantes,
                              autofocus: true,
                            )
                            : null,
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSearching ? 150 : 0,
                    child:
                        _isSearching
                            ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child:
                                  _isLoading
                                      ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(
                                            color: AppColors.primaryTurquoise,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                      : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredEstudiantes.length,
                                        itemBuilder: (context, index) {
                                          final estudiante =
                                              filteredEstudiantes[index];
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              estudiante.nombre,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            onTap: () async {
                                              setState(() {
                                                selectedClient =
                                                    estudiante.nombre;
                                                selectedClientId =
                                                    estudiante.id;
                                                _isSearching = false;
                                                _searchController.clear();
                                              });
                                              await _fetchStudentBalance(
                                                estudiante.id,
                                              );
                                            },
                                          );
                                        },
                                      ),
                            )
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        _isLoadingBalance
            ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryTurquoise,
              ),
            )
            : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: balanceColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                balanceText,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

        const SizedBox(height: 10),

        const Text(
          'Saldo actual',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
