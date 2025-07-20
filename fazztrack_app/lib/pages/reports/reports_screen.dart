import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:fazztrack_app/services/reports/local_reports_service.dart';
import 'package:fazztrack_app/widgets/buscador_reporte.dart';
import 'package:fazztrack_app/widgets/student_summary.dart';
import 'package:flutter/material.dart';

class ReportsContent extends StatefulWidget {
  const ReportsContent({super.key});

  @override
  State<ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends State<ReportsContent> {
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final LocalReportsService _localReportsService = LocalReportsService();
  final TextEditingController _searchController = TextEditingController();

  List<EstudianteModel> _allEstudiantes = [];
  List<EstudianteModel> _filteredEstudiantes = [];
  Set<String> _selectedEstudiantes = {};
  bool _isLoading = false;
  bool _selectAll = false;
  bool _isMultiSelectMode = false;
  EstudianteModel? _selectedEstudiante;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadEstudiantes();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEstudiantes() async {
    if (!mounted || _isDisposed) return;
    setState(() => _isLoading = true);
    try {
      final estudiantes = await _estudiantesService.getAllEstudiantes();
      if (!mounted || _isDisposed) return;
      setState(() {
        _allEstudiantes = estudiantes;
        _filteredEstudiantes = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estudiantes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _filterEstudiantes(String query) {
    if (!mounted || _isDisposed) return;

    // Save the current selections before filtering
    final Set<String> previousSelections = Set.from(_selectedEstudiantes);

    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = _allEstudiantes;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredEstudiantes =
            _allEstudiantes.where((estudiante) {
              return estudiante.nombre.toLowerCase().contains(lowerQuery) ||
                  (estudiante.curso?.toLowerCase().contains(lowerQuery) ??
                      false) ||
                  (estudiante.nombreRepresentante?.toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false) ||
                  (estudiante.celular?.toLowerCase().contains(lowerQuery) ??
                      false);
            }).toList();
      }

      // Only clear selections if not in multi-select mode
      if (!_isMultiSelectMode) {
        _selectedEstudiantes.clear();
        _selectAll = false;
        _selectedEstudiante = null;
      } else {
        // In multi-select mode, preserve previous selections
        _selectedEstudiantes.clear();
        _selectedEstudiantes.addAll(previousSelections);

        // Update _selectAll based on whether all filtered items are selected
        _selectAll =
            _filteredEstudiantes.isNotEmpty &&
            _filteredEstudiantes.every(
              (e) => _selectedEstudiantes.contains(e.id),
            );
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterEstudiantes('');
  }

  void _toggleMultiSelectMode() {
    if (!mounted || _isDisposed) return;
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedEstudiantes.clear();
        _selectAll = false;
      }
      _selectedEstudiante = null;
    });
  }

  void _selectEstudiante(EstudianteModel estudiante) {
    if (!mounted || _isDisposed) return;
    setState(() {
      _selectedEstudiante = estudiante;
      if (_isMultiSelectMode) {
        _selectedEstudiantes.clear();
        _selectAll = false;
      }
    });
  }

  void _toggleSelectAll() {
    if (!mounted || _isDisposed) return;
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedEstudiantes = _filteredEstudiantes.map((e) => e.id).toSet();
      } else {
        _selectedEstudiantes.clear();
      }
    });
  }

  void _toggleStudentSelection(String id) {
    if (!mounted || _isDisposed) return;
    setState(() {
      if (_selectedEstudiantes.contains(id)) {
        _selectedEstudiantes.remove(id);
        _selectAll = false;
      } else {
        _selectedEstudiantes.add(id);
        // Only set _selectAll to true if all currently filtered students are selected
        if (_selectedEstudiantes.containsAll(
          _filteredEstudiantes.map((e) => e.id),
        )) {
          _selectAll = true;
        }
      }
    });
  }

  // Download Methods
  Future<void> _downloadIndividualReport() async {
    if (_selectedEstudiante == null) return;

    try {
      setState(() => _isLoading = true);

      // Use the single student in a list for the bulk method
      await _localReportsService.generateBulkStudentReportsWithProgress(
        context: context,
        estudiantes: [_selectedEstudiante!],
      );

      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadSelectedReports() async {
    if (_selectedEstudiantes.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      // Get selected students objects
      final selectedStudentObjects =
          _filteredEstudiantes
              .where(
                (estudiante) => _selectedEstudiantes.contains(estudiante.id),
              )
              .toList();

      await _localReportsService.generateBulkStudentReportsWithProgress(
        context: context,
        estudiantes: selectedStudentObjects,
      );

      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      // Limpiar selección después de solicitar reportes
      setState(() {
        _selectedEstudiantes.clear();
        _selectAll = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAllReports() async {
    try {
      setState(() => _isLoading = true);

      await _localReportsService.generateBulkStudentReportsWithProgress(
        context: context,
        estudiantes: _filteredEstudiantes,
      );

      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isMobile),
          SizedBox(height: isMobile ? 16 : 24),

          // Search and Actions Bar
          _buildSearchAndActionsBar(isMobile),
          SizedBox(height: isMobile ? 16 : 20),

          // Data Table and Student Info
          Expanded(child: _buildMainContent(isMobile, isTablet)),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile, bool isTablet) {
    if (isMobile && _selectedEstudiante != null) {
      // En móvil, mostrar solo el panel de información del estudiante cuando hay uno seleccionado
      return _buildStudentInfoPanel(isMobile);
    }

    if (isMobile) {
      // En móvil, mostrar solo la lista de estudiantes
      return _buildDataTable(isMobile);
    }

    // En tablet y desktop, mostrar ambos paneles como antes
    return Row(
      children: [
        // Lista de estudiantes
        Expanded(
          flex: _selectedEstudiante != null ? 1 : 3,
          child: _buildDataTable(isMobile),
        ),

        // Panel de información del estudiante seleccionado
        if (_selectedEstudiante != null) ...[
          const SizedBox(width: 20),
          Expanded(flex: 1, child: _buildStudentInfoPanel(isMobile)),
        ],
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assessment,
            size: isMobile ? 24 : 32,
            color: AppColors.primaryTurquoise,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reportes de Estudiantes',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!isMobile) // Solo mostrar subtítulo en tablets y desktop
                Text(
                  'Gestiona y descarga reportes de estudiantes',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary.withAlpha(70),
                  ),
                ),
            ],
          ),
        ),
        // Botón de regreso en móvil cuando hay un estudiante seleccionado
        if (isMobile && _selectedEstudiante != null)
          IconButton(
            onPressed: () {
              setState(() {
                _selectedEstudiante = null;
              });
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primaryTurquoise,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndActionsBar(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          // Search Bar
          BuscadorReporte(
            controller: _searchController,
            hintText: 'Buscar estudiantes...',
            onChanged: _filterEstudiantes,
            onClear: _clearSearch,
          ),
          const SizedBox(height: 12),

          // Action Buttons - Wrapped to handle overflow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                icon: Icons.refresh,
                label: 'Actualizar',
                onPressed: _loadEstudiantes,
                isCompact: true,
              ),
              _buildActionButton(
                icon:
                    _isMultiSelectMode
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                label: _isMultiSelectMode ? 'Salir' : 'Selección',
                onPressed: _toggleMultiSelectMode,
                isCompact: true,
              ),
              if (_isMultiSelectMode)
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Desc. Sel.',
                  onPressed:
                      _selectedEstudiantes.isNotEmpty
                          ? _downloadSelectedReports
                          : null,
                  isCompact: true,
                ),
              _buildActionButton(
                icon: Icons.download_for_offline,
                label: 'Desc. Todos',
                onPressed:
                    _filteredEstudiantes.isNotEmpty
                        ? _downloadAllReports
                        : null,
                isCompact: true,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Search Bar
        Expanded(
          flex: 2,
          child: BuscadorReporte(
            controller: _searchController,
            hintText: 'Buscar por nombre, curso, representante o celular...',
            onChanged: _filterEstudiantes,
            onClear: _clearSearch,
          ),
        ),
        const SizedBox(width: 16),

        // Action Buttons
        _buildActionButton(
          icon: Icons.refresh,
          label: 'Actualizar',
          onPressed: _loadEstudiantes,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon:
              _isMultiSelectMode
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
          label: _isMultiSelectMode ? 'Salir Selección' : 'Selección Múltiple',
          onPressed: _toggleMultiSelectMode,
        ),
        const SizedBox(width: 12),
        // Botones de descarga múltiple (solo en modo selección múltiple)
        if (_isMultiSelectMode) ...[
          _buildActionButton(
            icon: Icons.download,
            label: 'Descargar Seleccionados',
            onPressed:
                _selectedEstudiantes.isNotEmpty
                    ? _downloadSelectedReports
                    : null,
          ),
          const SizedBox(width: 12),
        ],
        // Botón Descargar Todos (siempre visible)
        _buildActionButton(
          icon: Icons.download_for_offline,
          label: 'Descargar Todos',
          onPressed:
              _filteredEstudiantes.isNotEmpty ? _downloadAllReports : null,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isCompact = false,
  }) {
    final isEnabled = onPressed != null && !_isLoading;
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon:
          _isLoading && onPressed != null
              ? SizedBox(
                width: isCompact ? 16 : 18,
                height: isCompact ? 16 : 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryDarkBlue,
                  ),
                ),
              )
              : Icon(icon, size: isCompact ? 16 : 18),
      label: Text(label, style: TextStyle(fontSize: isCompact ? 12 : 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled ? AppColors.primaryTurquoise : AppColors.darkGray,
        foregroundColor:
            isEnabled
                ? AppColors.primaryDarkBlue
                : AppColors.textPrimary.withAlpha(50),
        elevation: isEnabled ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 12,
        ),
      ),
    );
  }

  Widget _buildDataTable(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTurquoise),
      );
    }

    if (_filteredEstudiantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isMobile ? 48 : 64,
              color: AppColors.textPrimary.withAlpha(30),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              _allEstudiantes.isEmpty
                  ? 'No hay estudiantes registrados'
                  : 'No se encontraron estudiantes',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: AppColors.textPrimary.withAlpha(70),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTurquoise.withAlpha(20)),
      ),
      child: Column(
        children: [
          // Table Header - Solo en tablet y desktop
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryTurquoise.withAlpha(10),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Select All Checkbox (solo en modo selección múltiple)
                  if (_isMultiSelectMode) ...[
                    Checkbox(
                      value: _selectAll,
                      onChanged: (_) => _toggleSelectAll(),
                      activeColor: AppColors.primaryTurquoise,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Headers
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Curso',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Bar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEstudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = _filteredEstudiantes[index];
                final isSelected = _selectedEstudiantes.contains(estudiante.id);

                return _buildStudentRow(
                  estudiante,
                  isSelected,
                  index,
                  isMobile,
                );
              },
            ),
          ),

          // Footer with selection info (solo en modo selección múltiple)
          if (_isMultiSelectMode && _selectedEstudiantes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryTurquoise.withAlpha(10),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryTurquoise,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedEstudiantes.length} estudiante(s) seleccionado(s) de ${_filteredEstudiantes.length}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(
    EstudianteModel estudiante,
    bool isSelected,
    int index,
    bool isMobile,
  ) {
    if (isMobile) {
      // Diseño tipo card para móvil
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              _isMultiSelectMode && isSelected
                  ? AppColors.primaryTurquoise.withAlpha(10)
                  : !_isMultiSelectMode &&
                      _selectedEstudiante?.id == estudiante.id
                  ? AppColors.primaryTurquoise.withAlpha(20)
                  : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                !_isMultiSelectMode && _selectedEstudiante?.id == estudiante.id
                    ? AppColors.primaryTurquoise
                    : AppColors.primaryTurquoise.withAlpha(20),
            width:
                !_isMultiSelectMode && _selectedEstudiante?.id == estudiante.id
                    ? 2
                    : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleStudentSelection(estudiante.id);
              } else {
                _selectEstudiante(estudiante);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Checkbox (solo en modo selección múltiple)
                  if (_isMultiSelectMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleStudentSelection(estudiante.id),
                      activeColor: AppColors.primaryTurquoise,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Información del estudiante
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estudiante.nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 14,
                              color: AppColors.textPrimary.withAlpha(100),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              estudiante.curso ?? '-',
                              style: TextStyle(
                                color: AppColors.textPrimary.withAlpha(150),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.local_cafe,
                              size: 14,
                              color: AppColors.textPrimary.withAlpha(100),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                estudiante.bar?.nombre ?? 'Bar desconocido',
                                style: TextStyle(
                                  color: AppColors.textPrimary.withAlpha(150),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Indicador de selección
                  if (!_isMultiSelectMode &&
                      _selectedEstudiante?.id == estudiante.id)
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryTurquoise,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Diseño tabla para tablet y desktop
    return Container(
      decoration: BoxDecoration(
        color:
            _isMultiSelectMode && isSelected
                ? AppColors.primaryTurquoise.withAlpha(10)
                : !_isMultiSelectMode &&
                    _selectedEstudiante?.id == estudiante.id
                ? AppColors.primaryTurquoise.withAlpha(20)
                : index % 2 == 0
                ? AppColors.card
                : AppColors.background.withAlpha(30),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryTurquoise.withAlpha(50),
            width: 0.5,
          ),
          left:
              !_isMultiSelectMode && _selectedEstudiante?.id == estudiante.id
                  ? BorderSide(color: AppColors.primaryTurquoise, width: 4)
                  : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleStudentSelection(estudiante.id);
            } else {
              _selectEstudiante(estudiante);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Checkbox (solo en modo selección múltiple)
                if (_isMultiSelectMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleStudentSelection(estudiante.id),
                    activeColor: AppColors.primaryTurquoise,
                  ),
                  const SizedBox(width: 12),
                ],

                // Data
                Expanded(
                  flex: 3,
                  child: Text(
                    estudiante.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    estudiante.curso ?? '-',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    estudiante.bar?.nombre ?? 'Bar desconocido',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoPanel(bool isMobile) {
    if (_selectedEstudiante == null) return Container();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTurquoise.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del panel
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.primaryTurquoise.withAlpha(10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.primaryTurquoise,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Información del Estudiante',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (!mounted || _isDisposed) return;
                    setState(() {
                      _selectedEstudiante = null;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textPrimary.withAlpha(70),
                    size: isMobile ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),

          // Contenido del panel
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de resumen con información general integrada
                  StudentSummaryWidget(
                    key: ValueKey(_selectedEstudiante!.id),
                    estudiante: _selectedEstudiante!,
                    onDownloadReport: _downloadIndividualReport,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
