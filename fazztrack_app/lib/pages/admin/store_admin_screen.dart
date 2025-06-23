import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/services/bar/bar_api_service.dart';
import 'package:fazztrack_app/widgets/bar_card.dart';
import 'package:flutter/material.dart';

class StoreAdminScreen extends StatefulWidget {
  const StoreAdminScreen({super.key});

  @override
  State<StoreAdminScreen> createState() => _StoreAdminScreenState();
}

class _StoreAdminScreenState extends State<StoreAdminScreen> {
  final BarApiService _barService = BarApiService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<BarModel> _allBars = [];
  List<BarModel> _filteredBars = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBars();
    _searchController.addListener(_filterBars);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadBars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bars = await _barService.getAllBars();
      setState(() {
        _allBars = bars;
        _filteredBars = bars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar locales: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterBars() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBars = _allBars;
      } else {
        _filteredBars =
            _allBars
                .where(
                  (bar) =>
                      bar.nombre.toLowerCase().contains(query) ||
                      bar.id.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  void _showBarDetails(BarModel bar) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Row(
              children: [
                const Icon(Icons.store, color: AppColors.primaryTurquoise),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bar.nombre,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tag,
                            color: AppColors.primaryTurquoise,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Identificador:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bar.id,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      color: AppColors.primaryTurquoise,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tipo:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Local Comercial',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Estado:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Activo',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: AppColors.primaryTurquoise),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BarModel bar) {
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
              '¿Estás seguro de que deseas eliminar el local "${bar.nombre}"?\n\nEsta acción no se puede deshacer.',
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
                  _deleteBar(bar.id);
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

  void _showAddBarDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Agregar Local',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre del local',
                    labelStyle: const TextStyle(color: AppColors.textPrimary),
                    hintText: 'Ingresa el nombre del local',
                    hintStyle: const TextStyle(color: AppColors.textPrimary),
                    filled: true,
                    fillColor: AppColors.primaryDarkBlue.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryTurquoise,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
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
                  if (_nameController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _createBar(_nameController.text.trim());
                  }
                },
                child: const Text(
                  'Crear',
                  style: TextStyle(color: AppColors.primaryTurquoise),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditBarDialog(BarModel bar) {
    _nameController.text = bar.nombre;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Editar Local',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre del local',
                    labelStyle: const TextStyle(color: AppColors.textPrimary),
                    hintText: 'Ingresa el nombre del local',
                    hintStyle: const TextStyle(color: AppColors.textPrimary),
                    filled: true,
                    fillColor: AppColors.primaryDarkBlue.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryTurquoise,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
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
                  if (_nameController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _updateBar(bar.id, _nameController.text.trim());
                  }
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: AppColors.primaryTurquoise),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _createBar(String name) async {
    try {
      await _barService.createBar(name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadBars(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear local: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateBar(String id, String name) async {
    try {
      await _barService.updateBar(id, name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local actualizado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadBars(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar local: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteBar(String id) async {
    try {
      await _barService.deleteBar(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local eliminado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadBars(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar local: ${e.toString()}'),
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
          'Administración de Locales',
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
            onPressed: _loadBars,
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
                  hintText: 'Buscar locales por nombre o ID...',
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
                              onPressed: _loadBars,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTurquoise,
                                foregroundColor: AppColors.primaryDarkBlue,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                      : _filteredBars.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.store_outlined,
                              size: 64,
                              color: AppColors.primaryTurquoise,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No se encontraron locales con "${_searchController.text}"'
                                  : 'No hay locales registrados',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _showAddBarDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryTurquoise,
                                  foregroundColor: AppColors.primaryDarkBlue,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar primer local'),
                              ),
                            ],
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredBars.length,
                        itemBuilder: (context, index) {
                          final bar = _filteredBars[index];
                          return BarCard(
                            bar: bar,
                            onTap: () => _showBarDetails(bar),
                            onEdit: () => _showEditBarDialog(bar),
                            onDelete: () => _showDeleteConfirmation(bar),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBarDialog,
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: AppColors.primaryDarkBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
