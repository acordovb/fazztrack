import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/producto_model.dart';
import 'package:fazztrack_app/models/producto_seleccionado_model.dart';
import 'package:fazztrack_app/services/productos/productos_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SelectorProductosWidget extends StatefulWidget {
  final void Function(List<ProductoSeleccionadoModel> productos)?
  onProductosChanged;
  final String? barId;

  const SelectorProductosWidget({
    super.key,
    this.onProductosChanged,
    this.barId,
  });

  @override
  State<SelectorProductosWidget> createState() =>
      _SelectorProductosWidgetState();
}

class _SelectorProductosWidgetState extends State<SelectorProductosWidget> {
  final List<ProductoSeleccionadoModel> _productosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _productosSeleccionados.addAll([
      ProductoSeleccionadoModel(),
      ProductoSeleccionadoModel(),
      ProductoSeleccionadoModel(),
    ]);
  }

  void _agregarNuevaFila() {
    setState(() {
      _productosSeleccionados.add(ProductoSeleccionadoModel());
    });
    _notificarCambios();
  }

  void _eliminarFila(int index) {
    if (index >= 0 && index < _productosSeleccionados.length) {
      setState(() {
        _productosSeleccionados.removeAt(index);
      });
      _notificarCambios();
    }
  }

  void _actualizarProducto(int index, ProductoSeleccionadoModel nuevoProducto) {
    if (index >= 0 && index < _productosSeleccionados.length) {
      setState(() {
        _productosSeleccionados[index] = nuevoProducto;
      });
      _notificarCambios();
    }
  }

  void _notificarCambios() {
    if (widget.onProductosChanged != null) {
      final productosValidos =
          _productosSeleccionados.where((p) => p.producto != null).toList();
      widget.onProductosChanged!(productosValidos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.barId != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(
                  'Productos',
                  style: TextStyle(
                    color:
                        isEnabled ? AppColors.textPrimary : AppColors.lightGray,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isEnabled) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '(Seleccione un estudiante primero)',
                    style: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _productosSeleccionados.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _FilaProductoWidget(
                        productoSeleccionado: _productosSeleccionados[index],
                        onProductoActualizado:
                            isEnabled
                                ? (producto) =>
                                    _actualizarProducto(index, producto)
                                : null,
                        barId: widget.barId,
                        isEnabled: isEnabled,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: isEnabled ? () => _eliminarFila(index) : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isEnabled
                                  ? Colors.red.withAlpha(10)
                                  : Colors.grey.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: isEnabled ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: isEnabled ? _agregarNuevaFila : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isEnabled
                          ? AppColors.secondaryBlue
                          : AppColors.secondaryBlue.withAlpha(100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.add,
                  color:
                      isEnabled
                          ? AppColors.primaryTurquoise
                          : AppColors.lightGray,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaProductoWidget extends StatelessWidget {
  final ProductoSeleccionadoModel productoSeleccionado;
  final Function(ProductoSeleccionadoModel)? onProductoActualizado;
  final String? barId;
  final bool isEnabled;

  const _FilaProductoWidget({
    required this.productoSeleccionado,
    required this.onProductoActualizado,
    this.barId,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return InkWell(
      onTap: isEnabled ? () => _mostrarDialogoSeleccion(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isEnabled
                  ? AppColors.secondaryBlue
                  : AppColors.secondaryBlue.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                productoSeleccionado.producto?.nombre ??
                    (isEnabled
                        ? 'Seleccionar producto'
                        : 'Seleccione un estudiante primero'),
                style: TextStyle(
                  color:
                      !isEnabled
                          ? AppColors.lightGray
                          : productoSeleccionado.producto != null
                          ? AppColors.textPrimary
                          : AppColors.lightGray,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (productoSeleccionado.producto != null) ...[
              const SizedBox(width: 10),
              Text(
                formatCurrency.format(productoSeleccionado.producto!.precio),
                style: TextStyle(
                  color:
                      isEnabled
                          ? AppColors.primaryTurquoise
                          : AppColors.lightGray,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isEnabled
                        ? AppColors.primaryDarkBlue
                        : AppColors.primaryDarkBlue.withAlpha(100),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      isEnabled
                          ? AppColors.primaryTurquoise.withAlpha(30)
                          : AppColors.lightGray.withAlpha(30),
                  width: 1,
                ),
              ),
              child: Text(
                productoSeleccionado.producto != null
                    ? '${productoSeleccionado.cantidad}'
                    : '0',
                style: TextStyle(
                  color:
                      isEnabled ? AppColors.textPrimary : AppColors.lightGray,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoSeleccion(BuildContext context) async {
    if (!isEnabled || onProductoActualizado == null) return;

    final ProductosApiService productosService = ProductosApiService();
    await showDialog(
      context: context,
      builder:
          (context) => _DialogoSeleccionProducto(
            productoSeleccionado: productoSeleccionado,
            productosService: productosService,
            onProductoActualizado: onProductoActualizado!,
            barId: barId,
          ),
    );
  }
}

class _DialogoSeleccionProducto extends StatefulWidget {
  final ProductoSeleccionadoModel productoSeleccionado;
  final ProductosApiService productosService;
  final Function(ProductoSeleccionadoModel) onProductoActualizado;
  final String? barId;

  const _DialogoSeleccionProducto({
    required this.productoSeleccionado,
    required this.productosService,
    required this.onProductoActualizado,
    this.barId,
  });

  @override
  State<_DialogoSeleccionProducto> createState() =>
      _DialogoSeleccionProductoState();
}

class _DialogoSeleccionProductoState extends State<_DialogoSeleccionProducto> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isLoading = false;
  List<ProductoModel> _productosEncontrados = [];
  ProductoModel? _productoSeleccionado;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _productoSeleccionado = widget.productoSeleccionado.producto;
    _cantidad = widget.productoSeleccionado.cantidad;
    _cantidadController.text = _cantidad.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _buscarProductos(String query) async {
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _productosEncontrados = [];
        _isLoading = false;
      });
      return;
    }

    try {
      if (widget.barId != null) {
        final productos = await widget.productosService.searchProductosByName(
          query,
          widget.barId!,
        );
        setState(() {
          _productosEncontrados = productos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _productosEncontrados = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _productosEncontrados = [];
        _isLoading = false;
      });
    }
  }

  void _seleccionarProducto(ProductoModel producto) {
    setState(() {
      _productoSeleccionado = producto;
      _searchController.text = producto.nombre;
      _productosEncontrados = [];
    });
  }

  void _actualizarCantidad(String value) {
    if (value.isEmpty) {
      setState(() {
        _cantidad = 0;
      });
      return;
    }

    final int? nuevaCantidad = int.tryParse(value);
    if (nuevaCantidad != null && nuevaCantidad >= 0) {
      setState(() {
        _cantidad = nuevaCantidad;
      });
    }
  }

  void _guardarSeleccion() {
    final nuevoProductoSeleccionado = ProductoSeleccionadoModel(
      producto: _productoSeleccionado,
      cantidad: _cantidad,
    );
    widget.onProductoActualizado(nuevoProductoSeleccionado);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seleccionar Producto',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDarkBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryTurquoise.withAlpha(30),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar producto...',
                  hintStyle: TextStyle(color: AppColors.lightGray),
                  border: InputBorder.none,
                  isDense: true,
                  prefixIcon: Icon(Icons.search, color: AppColors.lightGray),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: _buscarProductos,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryTurquoise,
                ),
              )
            else if (_productosEncontrados.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _productosEncontrados.length,
                  itemBuilder: (context, index) {
                    final producto = _productosEncontrados[index];
                    final formatCurrency = NumberFormat.currency(
                      locale: 'en_US',
                      symbol: '\$',
                    );

                    return ListTile(
                      title: Text(
                        producto.nombre,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        producto.categoria,
                        style: const TextStyle(
                          color: AppColors.lightGray,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        formatCurrency.format(producto.precio),
                        style: const TextStyle(
                          color: AppColors.primaryTurquoise,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _seleccionarProducto(producto),
                    );
                  },
                ),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 16),
            if (_productoSeleccionado != null) ...[
              const Divider(color: AppColors.lightGray),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _productoSeleccionado!.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_US',
                      symbol: '\$',
                    ).format(_productoSeleccionado!.precio),
                    style: const TextStyle(
                      color: AppColors.primaryTurquoise,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Cantidad:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkBlue,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryTurquoise.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (_cantidad > 1) {
                              setState(() {
                                _cantidad--;
                                _cantidadController.text = _cantidad.toString();
                              });
                            }
                          },
                          child: const Icon(
                            Icons.remove,
                            color: AppColors.lightGray,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _cantidadController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: _actualizarCantidad,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _cantidad++;
                              _cantidadController.text = _cantidad.toString();
                            });
                          },
                          child: const Icon(
                            Icons.add,
                            color: AppColors.lightGray,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lightGray,
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _productoSeleccionado != null ? _guardarSeleccion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTurquoise,
                    foregroundColor: AppColors.textSecondary,
                    disabledBackgroundColor: AppColors.primaryTurquoise
                        .withAlpha(30),
                    disabledForegroundColor: AppColors.textPrimary.withAlpha(
                      50,
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
