import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/models/producto_model.dart';
import 'package:fazztrack_app/services/bar/bar_api_service.dart';
import 'package:fazztrack_app/services/productos/productos_api_service.dart';
import 'package:fazztrack_app/widgets/create_producto_dialog.dart';
import 'package:fazztrack_app/widgets/producto_card.dart';
import 'package:flutter/material.dart';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final ProductosApiService _productosService = ProductosApiService();
  final BarApiService _barService = BarApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ProductoModel> _allProductos = [];
  List<ProductoModel> _filteredProductos = [];
  List<BarModel> _allBars = [];
  String? _selectedBarId;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProductos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Cargar bares y productos en paralelo
      final results = await Future.wait([
        _barService.getAllBars(),
        _productosService.getAllProductos(),
      ]);

      final bars = results[0] as List<BarModel>;
      final productos = results[1] as List<ProductoModel>;

      setState(() {
        _allBars = bars;
        _allProductos = productos;

        if (_selectedBarId == null && bars.isNotEmpty) {
          _selectedBarId = bars.first.id;
        }

        _filterProductos();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      List<ProductoModel> productosFiltradosPorBar = _allProductos;

      // Filtrar por bar seleccionado
      if (_selectedBarId != null) {
        productosFiltradosPorBar =
            _allProductos
                .where((producto) => producto.idBar == _selectedBarId)
                .toList();
      }

      // Filtrar por búsqueda de texto
      if (query.isEmpty) {
        _filteredProductos = productosFiltradosPorBar;
      } else {
        _filteredProductos =
            productosFiltradosPorBar
                .where(
                  (producto) =>
                      producto.nombre.toLowerCase().contains(query) ||
                      producto.categoria.toLowerCase().contains(query) ||
                      producto.precio.toString().contains(query),
                )
                .toList();
      }
    });
  }

  void _selectBar(String barId) {
    setState(() {
      _selectedBarId = barId;
    });
    _filterProductos();
  }

  void _showDeleteConfirmation(ProductoModel producto) {
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
              '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
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
                  _deleteProducto(producto.id);
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

  Future<void> _deleteProducto(String id) async {
    try {
      await _productosService.deleteProducto(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData(); // Recargar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar producto: ${e.toString()}'),
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
          'Administración de Productos',
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
            onPressed: _loadData,
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
                  hintText:
                      'Buscar productos por nombre, categoría o precio...',
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

            // Filtro de bares
            if (_allBars.isNotEmpty)
              Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allBars.length,
                    itemBuilder: (context, index) {
                      final bar = _allBars[index];
                      final isSelected = _selectedBarId == bar.id;

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            bar.nombre,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? AppColors.primaryDarkBlue
                                      : AppColors.textPrimary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _selectBar(bar.id);
                            }
                          },
                          backgroundColor: AppColors.card,
                          selectedColor: AppColors.primaryTurquoise,
                          checkmarkColor: AppColors.primaryDarkBlue,
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.primaryTurquoise
                                    : AppColors.card,
                            width: 1,
                          ),
                        ),
                      );
                    },
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
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTurquoise,
                                foregroundColor: AppColors.primaryDarkBlue,
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                      : _filteredProductos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.inventory_outlined,
                              size: 64,
                              color: AppColors.primaryTurquoise,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No se encontraron productos con "${_searchController.text}"'
                                  : 'No hay productos registrados',
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
                        itemCount: _filteredProductos.length,
                        itemBuilder: (context, index) {
                          final producto = _filteredProductos[index];
                          return ProductoCard(
                            producto: producto,
                            onEdit: () {
                              // TODO: Implementar edición
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Función de editar próximamente',
                                  ),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            },
                            onDelete: () => _showDeleteConfirmation(producto),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedBarId == null || _allBars.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Debe seleccionar un bar antes de crear un producto',
                ),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          final selectedBar = _allBars.firstWhere(
            (bar) => bar.id == _selectedBarId,
          );

          showDialog(
            context: context,
            builder:
                (context) => CreateProductoDialog(
                  onProductoCreated: _loadData,
                  selectedBar: selectedBar,
                ),
          );
        },
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: AppColors.primaryDarkBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
