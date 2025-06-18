import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/widgets/saldo_cliente_widget.dart';
import 'package:fazztrack_app/widgets/transaction_alert_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AbonoScreen extends StatefulWidget {
  const AbonoScreen({super.key});

  @override
  State<AbonoScreen> createState() => _AbonoScreenState();
}

class _AbonoScreenState extends State<AbonoScreen> {
  EstudianteModel? _estudianteSeleccionado;
  String _selectedPaymentMethod = 'Transferencia';
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  ControlHistoricoModel? _controlHistorico;
  double _nuevoSaldo = 0.0;

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_calcularNuevoSaldo);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  void _calcularNuevoSaldo() {
    setState(() {
      final monto =
          _montoController.text.isEmpty
              ? 0.0
              : double.tryParse(_montoController.text.replaceAll(',', '.')) ??
                  0.0;

      if (_controlHistorico != null) {
        _nuevoSaldo =
            _controlHistorico!.totalAbono -
            _controlHistorico!.totalVenta +
            monto;
      } else {
        _nuevoSaldo = 0.0;
      }
    });
  }

  // Simular registro de abono
  Future<bool> _registrarAbono() async {
    // Aquí iría la lógica real para guardar el abono en la base de datos
    // Simulamos un tiempo de procesamiento
    await Future.delayed(const Duration(seconds: 1));

    // Simulamos un éxito o fracaso aleatorio para demostración
    // En una implementación real, esto dependería del resultado de la operación de guardado
    return true; // Cambiar a false para probar el caso de error
  }

  @override
  Widget build(BuildContext context) {
    final bool mostrarBoton =
        _estudianteSeleccionado != null &&
        (_montoController.text.isNotEmpty &&
            double.tryParse(_montoController.text.replaceAll(',', '.')) !=
                null &&
            double.tryParse(_montoController.text.replaceAll(',', '.'))! > 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton:
          mostrarBoton
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final bool resultado = await _registrarAbono();

                  if (!mounted) return;

                  if (resultado) {
                    // Mostrar alerta de éxito
                    await TransactionAlertWidget.show(
                      context: context,
                      title: 'Abono Registrado',
                      message:
                          'El abono de \$${_montoController.text} ha sido registrado exitosamente para ${_estudianteSeleccionado!.nombre}.',
                      isError: false,
                    );

                    // Limpiar campos después del éxito
                    _montoController.clear();
                    _comentarioController.clear();
                  } else {
                    // Mostrar alerta de error
                    await TransactionAlertWidget.show(
                      context: context,
                      title: 'Error al Registrar',
                      message:
                          'No se pudo procesar el abono. Por favor intente nuevamente.',
                      isError: true,
                    );
                  }
                },
                backgroundColor: AppColors.primaryTurquoise,
                label: Text(
                  'Registrar Abono',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: Icon(Icons.save),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SaldoClienteWidget(
                onUserChange: (estudiante, controlHistorico) {
                  setState(() {
                    _estudianteSeleccionado = estudiante;
                    _controlHistorico = controlHistorico;
                    _calcularNuevoSaldo();
                  });
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de pago',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = 'Transferencia';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _selectedPaymentMethod == 'Transferencia'
                                        ? AppColors.primary
                                        : AppColors.secondaryBlue,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Transferencia',
                                style: TextStyle(
                                  color:
                                      _selectedPaymentMethod == 'Transferencia'
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = 'Efectivo';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _selectedPaymentMethod == 'Efectivo'
                                        ? AppColors.primary
                                        : AppColors.secondaryBlue,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Efectivo',
                                style: TextStyle(
                                  color:
                                      _selectedPaymentMethod == 'Efectivo'
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto a abonar',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cantidad (USD):',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: _montoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                filled: true,
                                fillColor: AppColors.secondaryBlue,
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 25,
                                  minHeight: 25,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                  splashRadius: 20,
                                  onPressed: () {
                                    _montoController.clear();
                                    _calcularNuevoSaldo();
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color: AppColors.textPrimary.withAlpha(50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nuevo Saldo:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${_nuevoSaldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comentario',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        maxLines: 3,
                        controller: _comentarioController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: AppColors.secondaryBlue,
                          hintText: 'Añade un comentario sobre este abono...',
                          hintStyle: TextStyle(
                            color: AppColors.textPrimary.withAlpha(80),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
