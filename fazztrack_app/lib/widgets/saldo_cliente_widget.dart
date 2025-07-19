import 'dart:async';

import 'package:fazztrack_app/config/build.config.dart';
import 'package:fazztrack_app/config/general.config.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/estudiantes/control_historico_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaldoClienteWidget extends StatefulWidget {
  final Function(
    EstudianteModel? estudiante,
    ControlHistoricoModel controlHistorico,
  )?
  onUserChange;

  const SaldoClienteWidget({super.key, this.onUserChange});

  @override
  State<SaldoClienteWidget> createState() => _SaldoClienteWidgetState();
}

class _SaldoClienteWidgetState extends State<SaldoClienteWidget> {
  String? selectedClient;
  String? selectedClientId;
  double balance = 0.0;
  EstudianteModel? selectedEstudiante;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<EstudianteModel> filteredEstudiantes = [];
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final ControlHistoricoApiService _controlHistoricoService =
      ControlHistoricoApiService();
  ControlHistoricoModel? _controlHistorico;
  bool _isLoading = false;
  bool _isLoadingBalance = false;
  bool _hasBalanceError = false;
  bool _hasSearchError = false;
  String _currentSearchQuery = '';
  final bool _isAdmin = BuildConfig.appLevel == AppConfig.appLevel.admin;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchStudentBalance(String estudianteId) async {
    setState(() {
      _isLoadingBalance = true;
      _hasBalanceError = false;
    });

    try {
      _controlHistorico = await _controlHistoricoService
          .getControlHistoricoByEstudianteId(estudianteId);
      if (_controlHistorico != null) {
        setState(() {
          balance =
              _controlHistorico!.totalAbono -
              _controlHistorico!.totalVenta +
              _controlHistorico!.totalPendienteUltMesAbono -
              _controlHistorico!.totalPendienteUltMesVenta;
          _isLoadingBalance = false;
        });
      } else {
        setState(() {
          balance = 0.0;
          _isLoadingBalance = false;
          _hasBalanceError = true;
        });
      }

      if (widget.onUserChange != null && _controlHistorico != null) {
        widget.onUserChange!(selectedEstudiante, _controlHistorico!);
      }
    } catch (e) {
      setState(() {
        balance = 0.0;
        _isLoadingBalance = false;
        _hasBalanceError = true;
      });

      // Only notify parent widget if we have valid data
      if (widget.onUserChange != null && _controlHistorico != null) {
        widget.onUserChange!(selectedEstudiante, _controlHistorico!);
      }
    }
  }

  void _searchEstudiantes(String query) {
    // Remove debounce timer entirely to eliminate delay
    setState(() {
      _isLoading = true;
      _hasSearchError = false;
      _currentSearchQuery = query;
    });

    // Execute search immediately without delay
    if (query.isEmpty) {
      setState(() {
        filteredEstudiantes = [];
        _isLoading = false;
      });
      return;
    }

    try {
      _estudiantesService
          .searchEstudiantesByName(query)
          .then((estudiantes) {
            setState(() {
              filteredEstudiantes = estudiantes;
              _isLoading = false;
            });
          })
          .catchError((e) {
            setState(() {
              filteredEstudiantes = [];
              _isLoading = false;
              _hasSearchError = true;
            });
          });
    } catch (e) {
      setState(() {
        filteredEstudiantes = [];
        _isLoading = false;
        _hasSearchError = true;
      });
    }
  }

  void _retrySearch() {
    if (_currentSearchQuery.isNotEmpty) {
      _searchEstudiantes(_currentSearchQuery);
    }
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
      locale: 'en_US',
      symbol: '\$',
    ).format(balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: selectedClient ?? "Buscar estudiante...",
                    hintStyle: TextStyle(
                      color:
                          selectedClient != null
                              ? AppColors.textPrimary
                              : AppColors.lightGray,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.lightGray,
                      size: 20,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty ||
                                selectedClient != null
                            ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: AppColors.lightGray,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  filteredEstudiantes = [];
                                  selectedClient = null;
                                  selectedClientId = null;
                                  selectedEstudiante = null;
                                  balance = 0.0;
                                });
                              },
                            )
                            : null,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  onTap: () {
                    if (selectedClient != null) {
                      setState(() {
                        selectedClient = null;
                        _searchController.clear();
                        _isSearching = false;
                        _hasSearchError = false;
                        // Keep the selectedEstudiante and balance for reference
                        // until a new search is performed
                      });
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                      if (!value.isNotEmpty) {
                        _hasSearchError = false;
                      }
                    });
                    _searchEstudiantes(value);
                  },
                ),
              ),
              if (_isSearching &&
                  (_isLoading ||
                      filteredEstudiantes.isNotEmpty ||
                      _hasSearchError))
                Container(
                  height: 220,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryTurquoise.withAlpha(50),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
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
                          : _hasSearchError
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Error al buscar estudiantes',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _retrySearch,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryTurquoise,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: filteredEstudiantes.length,
                            separatorBuilder:
                                (context, index) => const Divider(
                                  height: 1,
                                  color: AppColors.shadow,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            itemBuilder: (context, index) {
                              final estudiante = filteredEstudiantes[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      setState(() {
                                        selectedClient = estudiante.nombre;
                                        selectedClientId = estudiante.id;
                                        selectedEstudiante = estudiante;
                                        _searchController.clear();
                                        filteredEstudiantes = [];
                                        _isSearching = false;
                                      });
                                      await _fetchStudentBalance(estudiante.id);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            color: AppColors.primaryTurquoise,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  estudiante.nombre,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  _isAdmin
                                                      ? getStudentDetails(
                                                        estudiante,
                                                      )
                                                      : (estudiante.curso ??
                                                          ''),
                                                  style: const TextStyle(
                                                    color: AppColors.lightGray,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.lightGray,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        _isLoadingBalance
            ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryTurquoise,
              ),
            )
            : _hasBalanceError
            ? Column(
              children: [
                const Text(
                  'Error al cargar el saldo',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed:
                      selectedClientId != null
                          ? () => _fetchStudentBalance(selectedClientId!)
                          : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTurquoise,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
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

  // Helper method to format student details display
  String getStudentDetails(EstudianteModel estudiante) {
    // If both bar and curso are available, show both
    if (estudiante.bar?.nombre != null && estudiante.curso != null) {
      return '${estudiante.bar!.nombre} • ${estudiante.curso!}';
    }
    // If only bar is available
    else if (estudiante.bar?.nombre != null) {
      return estudiante.bar!.nombre;
    }
    // If only curso is available
    else if (estudiante.curso != null) {
      return estudiante.curso!;
    }
    // If neither are available
    return '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
