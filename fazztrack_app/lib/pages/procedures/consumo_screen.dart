import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/model/estudiante_model.dart';
import 'package:fazztrack_app/model/producto_seleccionado_model.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:fazztrack_app/widgets/selector_productos_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsumoScreen extends StatefulWidget {
  const ConsumoScreen({super.key});

  @override
  State<ConsumoScreen> createState() => _ConsumoScreenState();
}

class _ConsumoScreenState extends State<ConsumoScreen> {
  List<ProductoSeleccionadoModel> _productosSeleccionados = [];
  double _total = 0.0;
  EstudianteModel? _estudianteSeleccionado;
  double _balance = 0.0;

  void _actualizarProductosSeleccionados(
    List<ProductoSeleccionadoModel> productos,
  ) {
    setState(() {
      _productosSeleccionados = productos;
      _total = productos.fold(0, (sum, producto) => sum + producto.subtotal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SaldoClienteWidget(
                onUserChange: (estudiante, balance) {
                  setState(() {
                    _estudianteSeleccionado = estudiante;
                    _balance = balance;
                  });
                },
              ),
              const SizedBox(height: 20),
              SelectorProductosWidget(
                onProductosChanged: _actualizarProductosSeleccionados,
              ),
              if (_productosSeleccionados.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency.format(_total),
                        style: const TextStyle(
                          color: AppColors.primaryTurquoise,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nuevo Saldo:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency.format(_balance - _total),
                        style: TextStyle(
                          color:
                              (_balance - _total) < 0
                                  ? Colors.red
                                  : AppColors.primaryTurquoise,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          _productosSeleccionados.isNotEmpty && _estudianteSeleccionado != null
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Por ahora, solo imprime los datos seleccionados
                  print('Estudiante: ${_estudianteSeleccionado!.nombre}');
                  print('Balance actual: $_balance');
                  print('Total compra: $_total');
                  print('Nuevo saldo: ${_balance - _total}');
                  print('Productos:');
                  for (var producto in _productosSeleccionados) {
                    print(
                      '- ${producto.producto?.nombre ?? "Sin nombre"} x ${producto.cantidad} = \$${producto.subtotal}',
                    );
                  }
                },
                label: const Text('Registrar Consumo'),
                icon: const Icon(Icons.check_circle),
                backgroundColor: AppColors.primaryTurquoise,
              )
              : null,
    );
  }
}
