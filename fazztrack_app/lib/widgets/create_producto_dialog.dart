import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/models/producto_model.dart';
import 'package:fazztrack_app/services/productos/productos_api_service.dart';
import 'package:flutter/material.dart';

class CreateProductoDialog extends StatefulWidget {
  final VoidCallback? onProductoCreated;
  final BarModel selectedBar;

  const CreateProductoDialog({
    super.key,
    this.onProductoCreated,
    required this.selectedBar,
  });

  @override
  State<CreateProductoDialog> createState() => _CreateProductoDialogState();
}

class _CreateProductoDialogState extends State<CreateProductoDialog> {
  final ProductosApiService _productosService = ProductosApiService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _createProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isCreating) {
      return; // Prevenir múltiples envíos
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Usar el bar seleccionado que se pasó como parámetro
      final barId = widget.selectedBar.id;

      final nuevoProducto = ProductoModel(
        id: '',
        nombre: _nombreController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        categoria:
            _categoriaController.text.trim().isEmpty
                ? 'General'
                : _categoriaController.text.trim(),
        idBar: barId,
      );

      await _productosService.createProducto(nuevoProducto);

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Ejecutar callback para recargar la lista
        widget.onProductoCreated?.call();
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear producto: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primaryTurquoise,
          size: 32,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de solo lectura para mostrar el bar seleccionado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textPrimary, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bar Seleccionado',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                            widget.selectedBar.nombre,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre del Producto *',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del producto es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Precio *',
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: AppColors.primaryTurquoise,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryTurquoise,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  final precio = double.tryParse(value.trim());
                  if (precio == null) {
                    return 'Ingrese un precio válido';
                  }
                  if (precio <= 0) {
                    return 'El precio debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'Ej: Bebidas, Snacks, etc.',
                  hintStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.textPrimary,
                      width: 1,
                    ),
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createProducto,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTurquoise,
            foregroundColor: AppColors.primaryDarkBlue,
          ),
          child:
              _isCreating
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryDarkBlue,
                      ),
                    ),
                  )
                  : const Text('Crear'),
        ),
      ],
    );
  }
}
