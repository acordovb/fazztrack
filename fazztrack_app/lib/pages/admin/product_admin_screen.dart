import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/producto_model.dart';
import 'package:fazztrack_app/services/productos/productos_api_service.dart';
import 'package:fazztrack_app/widgets/producto_card.dart';
import 'package:flutter/material.dart';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final ProductosApiService _productosService = ProductosApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ProductoModel> _allProductos = [];
  List<ProductoModel> _filteredProductos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productos = await _productosService.getAllProductos();
      setState(() {
        _allProductos = productos;
        _filteredProductos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar productos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProductos = _allProductos;
      } else {
        _filteredProductos =
            _allProductos
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

  void _showProductoDetails(ProductoModel producto) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              producto.nombre,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      color: AppColors.primaryTurquoise,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Categoría: ${producto.categoria}',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppColors.primaryTurquoise,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Precio: \$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.store,
                      color: AppColors.primaryTurquoise,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID Bar: ${producto.idBar}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${producto.id}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
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
      _loadProductos(); // Recargar la lista
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
            onPressed: _loadProductos,
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
                              onPressed: _loadProductos,
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
                            onTap: () => _showProductoDetails(producto),
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
          // TODO: Implementar agregar nuevo producto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función de agregar producto próximamente'),
              backgroundColor: AppColors.warning,
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
