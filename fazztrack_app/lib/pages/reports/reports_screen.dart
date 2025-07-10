import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/bar/bar_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:fazztrack_app/services/reports/reports_api_service.dart';
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
  final BarApiService _barService = BarApiService();
  final ReportsApiService _reportsService = ReportsApiService();
  final TextEditingController _searchController = TextEditingController();

  List<EstudianteModel> _allEstudiantes = [];
  List<EstudianteModel> _filteredEstudiantes = [];
  List<BarModel> _bars = [];
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
    _loadBars();
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

  Future<void> _loadBars() async {
    try {
      final bars = await _barService.getAllBars();
      if (!mounted || _isDisposed) return;
      setState(() {
        _bars = bars;
      });
    } catch (e) {
      // Handle error silently
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

  String _getBarName(String barId) {
    try {
      final bar = _bars.firstWhere((bar) => bar.id == barId);
      return bar.nombre;
    } catch (e) {
      return 'Bar desconocido';
    }
  }

  // Download Methods
  Future<void> _downloadIndividualReport() async {
    if (_selectedEstudiante == null) return;

    try {
      setState(() => _isLoading = true);

      final response = await _reportsService.generateReportForStudent(
        _selectedEstudiante!.id,
      );

      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      // Mostrar mensaje de éxito en popup
      _showResponseDialog(
        title: 'Reporte Solicitado',
        message: response.message,
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      _showResponseDialog(
        title: 'Error',
        message: 'Error al solicitar reporte: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _downloadSelectedReports() async {
    if (_selectedEstudiantes.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      final response = await _reportsService.generateReportsForStudents(
        _selectedEstudiantes.toList(),
      );

      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      // Mostrar mensaje de éxito en popup
      _showResponseDialog(
        title: 'Reportes Solicitados',
        message: response.message,
        isSuccess: true,
      );

      // Opcional: Limpiar selección después de solicitar reportes
      setState(() {
        _selectedEstudiantes.clear();
        _selectAll = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      _showResponseDialog(
        title: 'Error',
        message: 'Error al solicitar reportes: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _downloadAllReports() async {
    try {
      setState(() => _isLoading = true);

      final response = await _reportsService.generateAllReports();

      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      // Mostrar mensaje de éxito en popup
      _showResponseDialog(
        title: 'Reportes Solicitados',
        message: response.message,
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted || _isDisposed) return;

      setState(() => _isLoading = false);

      _showResponseDialog(
        title: 'Error',
        message: 'Error al solicitar reportes: $e',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Search and Actions Bar
          _buildSearchAndActionsBar(),
          const SizedBox(height: 20),

          // Data Table
          Expanded(
            child: Row(
              children: [
                // Lista de estudiantes
                Expanded(
                  flex: _selectedEstudiante != null ? 2 : 3,
                  child: _buildDataTable(),
                ),

                // Panel de información del estudiante seleccionado
                if (_selectedEstudiante != null) ...[
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: _buildStudentInfoPanel()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assessment,
            size: 32,
            color: AppColors.primaryTurquoise,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportes de Estudiantes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Gestiona y descarga reportes de estudiantes',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary.withAlpha(70),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndActionsBar() {
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
  }) {
    final isEnabled = onPressed != null && !_isLoading;
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon:
          _isLoading && onPressed != null
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryDarkBlue,
                  ),
                ),
              )
              : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled ? AppColors.primaryTurquoise : AppColors.darkGray,
        foregroundColor:
            isEnabled
                ? AppColors.primaryDarkBlue
                : AppColors.textPrimary.withAlpha(50),
        elevation: isEnabled ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDataTable() {
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
              size: 64,
              color: AppColors.textPrimary.withAlpha(30),
            ),
            const SizedBox(height: 16),
            Text(
              _allEstudiantes.isEmpty
                  ? 'No hay estudiantes registrados'
                  : 'No se encontraron estudiantes',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary.withAlpha(70),
              ),
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
          // Table Header
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
                        color: AppColors.primaryTurquoise,
                        width: 0.5,
                      ),
                      left:
                          !_isMultiSelectMode &&
                                  _selectedEstudiante?.id == estudiante.id
                              ? BorderSide(
                                color: AppColors.primaryTurquoise,
                                width: 4,
                              )
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Checkbox (solo en modo selección múltiple)
                            if (_isMultiSelectMode) ...[
                              Checkbox(
                                value: isSelected,
                                onChanged:
                                    (_) =>
                                        _toggleStudentSelection(estudiante.id),
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
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _getBarName(estudiante.idBar),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
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
                  Text(
                    '${_selectedEstudiantes.length} estudiante(s) seleccionado(s) de ${_filteredEstudiantes.length}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoPanel() {
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTurquoise.withAlpha(10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.primaryTurquoise, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Información del Estudiante',
                    style: TextStyle(
                      fontSize: 18,
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
                  ),
                ),
              ],
            ),
          ),

          // Contenido del panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de resumen con información general integrada
                  StudentSummaryWidget(
                    key: ValueKey(_selectedEstudiante!.id),
                    estudiante: _selectedEstudiante!,
                    onDownloadReport: _downloadIndividualReport,
                    getBarName: _getBarName,
                    isDownloadLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog method to show responses
  void _showResponseDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    if (!mounted || _isDisposed) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? AppColors.primaryTurquoise : AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              message,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTurquoise,
              ),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
