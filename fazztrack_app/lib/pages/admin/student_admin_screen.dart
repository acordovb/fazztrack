import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/estudiantes/estudiantes_api_service.dart';
import 'package:fazztrack_app/widgets/create_estudiante_dialog.dart';
import 'package:fazztrack_app/widgets/edit_estudiante_dialog.dart';
import 'package:fazztrack_app/widgets/estudiante_card.dart';
import 'package:flutter/material.dart';

class StudentAdminScreen extends StatefulWidget {
  const StudentAdminScreen({super.key});

  @override
  State<StudentAdminScreen> createState() => _StudentAdminScreenState();
}

class _StudentAdminScreenState extends State<StudentAdminScreen> {
  final EstudiantesApiService _estudiantesService = EstudiantesApiService();
  final TextEditingController _searchController = TextEditingController();

  List<EstudianteModel> _allEstudiantes = [];
  List<EstudianteModel> _filteredEstudiantes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEstudiantes();
    _searchController.addListener(_filterEstudiantes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEstudiantes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final estudiantes = await _estudiantesService.getAllEstudiantes();
      setState(() {
        _allEstudiantes = estudiantes;
        _filteredEstudiantes = estudiantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estudiantes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterEstudiantes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEstudiantes = _allEstudiantes;
      } else {
        _filteredEstudiantes =
            _allEstudiantes
                .where(
                  (estudiante) =>
                      estudiante.nombre.toLowerCase().contains(query) ||
                      (estudiante.curso?.toLowerCase().contains(query) ??
                          false) ||
                      (estudiante.nombreRepresentante?.toLowerCase().contains(
                            query,
                          ) ??
                          false),
                )
                .toList();
      }
    });
  }

  void _showCreateEstudianteDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              CreateEstudianteDialog(onEstudianteCreated: _loadEstudiantes),
    );
  }

  void _showEditEstudianteDialog(EstudianteModel estudiante) {
    showDialog(
      context: context,
      builder:
          (context) => EditEstudianteDialog(
            estudiante: estudiante,
            onEstudianteUpdated: _loadEstudiantes,
          ),
    );
  }

  void _showDeleteConfirmation(EstudianteModel estudiante) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Confirmar eliminación',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar al estudiante "${estudiante.nombre}"?\n\nEsta acción no se puede deshacer.',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteEstudiante(estudiante.id);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteEstudiante(String id) async {
    try {
      await _estudiantesService.deleteEstudiante(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estudiante eliminado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadEstudiantes(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar estudiante: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Estudiantes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundSecondary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadEstudiantes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar estudiantes...',
                  hintStyle: const TextStyle(color: AppColors.textPrimary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryTurquoise,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textPrimary,
                            ),
                          )
                          : null,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Contenido principal
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTurquoise,
                        ),
                      )
                      : _errorMessage.isNotEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadEstudiantes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTurquoise,
                                foregroundColor: AppColors.primaryDarkBlue,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                      : _filteredEstudiantes.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.school_outlined,
                              size: 64,
                              color: AppColors.primaryTurquoise,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No se encontraron estudiantes con "${_searchController.text}"'
                                  : 'No hay estudiantes registrados',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredEstudiantes.length,
                        itemBuilder: (context, index) {
                          final estudiante = _filteredEstudiantes[index];
                          return EstudianteCard(
                            estudiante: estudiante,
                            onEdit: () {
                              _showEditEstudianteDialog(estudiante);
                            },
                            onDelete: () => _showDeleteConfirmation(estudiante),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEstudianteDialog,
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: AppColors.primaryDarkBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
