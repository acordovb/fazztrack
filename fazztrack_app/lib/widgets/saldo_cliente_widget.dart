import 'dart:async';

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
  Timer? _debounceTimer;
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final ControlHistoricoApiService _controlHistoricoService =
      ControlHistoricoApiService();
  ControlHistoricoModel? _controlHistorico;
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
      _controlHistorico = await _controlHistoricoService
          .getControlHistoricoByEstudianteId(estudianteId);
      if (_controlHistorico != null) {
        setState(() {
          balance =
              _controlHistorico!.totalAbono - _controlHistorico!.totalVenta;
          _isLoadingBalance = false;
        });
      } else {
        setState(() {
          balance = 0.0;
          _isLoadingBalance = false;
        });
      }

      if (widget.onUserChange != null) {
        widget.onUserChange!(selectedEstudiante, _controlHistorico!);
      }
    } catch (e) {
      setState(() {
        balance = 0.0;
        _isLoadingBalance = false;
      });

      // Notify parent widget even in case of error
      if (widget.onUserChange != null) {
        widget.onUserChange!(selectedEstudiante, _controlHistorico!);
      }
    }
  }

  void _searchEstudiantes(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    setState(() {
      _isLoading = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
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
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: AppColors.lightGray,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  filteredEstudiantes = [];
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
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                    _searchEstudiantes(value);
                  },
                ),
              ),
              if ((_isSearching && filteredEstudiantes.isNotEmpty) ||
                  _isLoading)
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
                                                if (estudiante.curso != null)
                                                  Text(
                                                    estudiante.curso!,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.lightGray,
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
