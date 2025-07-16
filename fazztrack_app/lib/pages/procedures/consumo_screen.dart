import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/producto_seleccionado_model.dart';
import 'package:fazztrack_app/providers/consumo_provider.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:fazztrack_app/widgets/selector_productos_widget.dart';
import 'package:fazztrack_app/widgets/transaction_alert_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsumoScreen extends StatefulWidget {
  const ConsumoScreen({super.key});

  @override
  State<ConsumoScreen> createState() => _ConsumoScreenState();
}

class _ConsumoScreenState extends State<ConsumoScreen> {
  Key _saldoClienteKey = UniqueKey();
  Key _selectorProductosKey = UniqueKey();

  List<ProductoSeleccionadoModel> _productosSeleccionados = [];
  double _total = 0.0;
  EstudianteModel? _estudianteSeleccionado;
  ControlHistoricoModel? _controlHistorico;

  void _actualizarProductosSeleccionados(
    List<ProductoSeleccionadoModel> productos,
  ) {
    setState(() {
      _productosSeleccionados = productos;
      _total = productos.fold(0, (sum, producto) => sum + producto.subtotal);
    });
  }

  void _reiniciarValores() {
    setState(() {
      _saldoClienteKey = UniqueKey();
      _selectorProductosKey = UniqueKey();

      _productosSeleccionados = [];
      _total = 0.0;
      _estudianteSeleccionado = null;
      _controlHistorico = null;
    });
  }

  Widget _buildRightColumn(NumberFormat formatCurrency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SelectorProductosWidget(
          key: _selectorProductosKey,
          onProductosChanged: _actualizarProductosSeleccionados,
          barId: _estudianteSeleccionado?.idBar,
        ),
        if (_productosSeleccionados.isNotEmpty &&
            _controlHistorico != null) ...[
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
                  formatCurrency.format(
                    _controlHistorico!.totalPendienteUltMesAbono -
                        _controlHistorico!.totalPendienteUltMesVenta +
                        _controlHistorico!.totalAbono -
                        _controlHistorico!.totalVenta -
                        _total,
                  ),
                  style: TextStyle(
                    color:
                        (_controlHistorico!.totalPendienteUltMesAbono -
                                    _controlHistorico!
                                        .totalPendienteUltMesVenta +
                                    _controlHistorico!.totalAbono -
                                    _controlHistorico!.totalVenta -
                                    _total) <
                                0
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determinar si usar layout de una o dos columnas
              final isWideScreen = constraints.maxWidth > 800;

              if (isWideScreen) {
                // Layout de dos columnas para pantallas grandes
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna izquierda - SaldoClienteWidget
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SaldoClienteWidget(
                          key: _saldoClienteKey,
                          onUserChange: (estudiante, controlHistorico) {
                            setState(() {
                              _estudianteSeleccionado = estudiante;
                              _controlHistorico = controlHistorico;
                            });
                          },
                        ),
                      ),
                    ),
                    // Columna derecha - Resto del contenido
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _buildRightColumn(formatCurrency),
                      ),
                    ),
                  ],
                );
              } else {
                // Layout de una columna para pantallas pequeñas
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SaldoClienteWidget(
                      key: _saldoClienteKey,
                      onUserChange: (estudiante, controlHistorico) {
                        setState(() {
                          _estudianteSeleccionado = estudiante;
                          _controlHistorico = controlHistorico;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildRightColumn(formatCurrency),
                  ],
                );
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          _productosSeleccionados.isNotEmpty && _estudianteSeleccionado != null
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await ConsumoProvider().registrarConsumo(
                    _estudianteSeleccionado!,
                    _productosSeleccionados,
                  );
                  if (result == 'OK') {
                    await TransactionAlertWidget.show(
                      context: context,
                      title: 'Registro Exitoso',
                      message: 'El consumo ha sido registrado correctamente.',
                      isError: false,
                    );
                    _reiniciarValores();
                  } else {
                    await TransactionAlertWidget.show(
                      context: context,
                      title: 'Error',
                      message: result,
                      isError: true,
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
