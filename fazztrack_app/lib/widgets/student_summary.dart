import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/services/ventas/ventas_api_service.dart';
import 'package:fazztrack_app/services/abonos/abono_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/control_historico_api_service.dart';
import 'package:flutter/material.dart';

class StudentSummaryWidget extends StatefulWidget {
  final EstudianteModel estudiante;
  final void Function(int selectedMonth)? onMonthChanged;

  const StudentSummaryWidget({
    super.key,
    required this.estudiante,
    this.onMonthChanged,
  });

  @override
  State<StudentSummaryWidget> createState() => _StudentSummaryWidgetState();
}

class _StudentSummaryWidgetState extends State<StudentSummaryWidget> {
  late String selectedMonth;
  final VentasApiService _ventasApiService = VentasApiService();
  final AbonoApiService _abonoApiService = AbonoApiService();
  final ControlHistoricoApiService _controlHistoricoApiService =
      ControlHistoricoApiService();

  List<VentaModel> ventas = [];
  List<AbonoModel> abonos = [];
  ControlHistoricoModel? controlHistorico;
  bool isLoading = true;
  String? error;

  // Variable para rastrear el estudiante actual y cancelar operaciones obsoletas
  String? _currentStudentId;

  final List<Map<String, String>> months = [
    {'value': '1', 'name': 'Enero'},
    {'value': '2', 'name': 'Febrero'},
    {'value': '3', 'name': 'Marzo'},
    {'value': '4', 'name': 'Abril'},
    {'value': '5', 'name': 'Mayo'},
    {'value': '6', 'name': 'Junio'},
    {'value': '7', 'name': 'Julio'},
    {'value': '8', 'name': 'Agosto'},
    {'value': '9', 'name': 'Septiembre'},
    {'value': '10', 'name': 'Octubre'},
    {'value': '11', 'name': 'Noviembre'},
    {'value': '12', 'name': 'Diciembre'},
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month.toString();
    _currentStudentId = widget.estudiante.id;
    _loadData();
  }

  @override
  void didUpdateWidget(StudentSummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el estudiante cambió, actualizar el ID y recargar datos
    if (widget.estudiante.id != oldWidget.estudiante.id) {
      _currentStudentId = widget.estudiante.id;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final month = int.parse(selectedMonth);
      final currentStudentId = widget.estudiante.id;

      final ventasData = await _ventasApiService.findAllByStudent(
        widget.estudiante.id,
        mes: month,
      );

      // Verificar si el widget sigue montado y si el estudiante no ha cambiado
      if (!mounted || _currentStudentId != currentStudentId) {
        return;
      }

      final abonosData = await _abonoApiService.findAllByStudent(
        widget.estudiante.id,
        mes: month,
      );

      // Verificar nuevamente
      if (!mounted || _currentStudentId != currentStudentId) {
        return;
      }

      final controlHistoricoData = await _controlHistoricoApiService
          .getControlHistoricoByEstudianteId(
            widget.estudiante.id,
            month: month,
          );

      // Verificación final antes de actualizar el estado
      if (!mounted || _currentStudentId != currentStudentId) {
        return;
      }

      setState(() {
        ventas = ventasData;
        abonos = abonosData;
        controlHistorico = controlHistoricoData;
        isLoading = false;
      });
    } catch (e) {
      // Verificar si el widget sigue montado antes de actualizar el estado del error
      if (!mounted) {
        return;
      }

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  double get totalVentas {
    return ventas.fold(0.0, (sum, venta) {
      if (venta.producto != null) {
        return sum + (venta.nProductos * venta.producto!.precio);
      }
      return sum;
    });
  }

  double get totalAbonos {
    return abonos.fold(0.0, (sum, abono) => sum + abono.total);
  }

  double get balance {
    return totalAbonos -
        totalVentas +
        (controlHistorico?.totalPendienteUltMesAbono ?? 0) -
        (controlHistorico?.totalPendienteUltMesVenta ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return _buildInfoCard(
      title: 'Resumen',
      icon: Icons.summarize,
      children: [
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar datos',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Resumen de ${months.firstWhere((month) => month['value'] == selectedMonth)['name']}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (controlHistorico != null) ...[
                  if (controlHistorico!.totalPendienteUltMesAbono > 0) ...[
                    _buildSummaryRow(
                      'Saldo a favor del mes anterior',
                      '\$${controlHistorico!.totalPendienteUltMesAbono.toStringAsFixed(2)}',
                      Icons.schedule,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (controlHistorico!.totalPendienteUltMesVenta > 0) ...[
                    _buildSummaryRow(
                      'Saldo pendiente del mes anterior',
                      '\$${controlHistorico!.totalPendienteUltMesVenta.toStringAsFixed(2)}',
                      Icons.schedule,
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                _buildSummaryRow(
                  'Ventas',
                  '\$${totalVentas.toStringAsFixed(2)}',
                  Icons.shopping_cart,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Abonos',
                  '\$${totalAbonos.toStringAsFixed(2)}',
                  Icons.payment,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Saldo Actual',
                  '\$${balance.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  balance >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                if (ventas.isNotEmpty || abonos.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildTransactionsList(),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    // Crear lista combinada de transacciones
    List<Map<String, dynamic>> transacciones = [];

    // Agregar abonos
    for (var abono in abonos) {
      transacciones.add({
        'tipo': 'abono',
        'titulo': 'Abono - ${abono.tipoAbono}',
        'subtitulo': '\$${abono.total.toStringAsFixed(2)}',
        'fecha': abono.fechaAbono,
        'color': Colors.green,
        'icono': Icons.add,
      });
    }

    // Agregar ventas
    for (var venta in ventas) {
      final totalVenta =
          venta.producto != null
              ? venta.nProductos * venta.producto!.precio
              : 0.0;
      final nombreProducto =
          venta.producto?.nombre ?? 'Producto ${venta.idProducto}';

      transacciones.add({
        'tipo': 'venta',
        'titulo': 'Venta - $nombreProducto',
        'subtitulo':
            '${venta.nProductos} unidades - \$${totalVenta.toStringAsFixed(2)}',
        'fecha': venta.fechaTransaccion,
        'color': Colors.orange,
        'icono': Icons.shopping_cart,
      });
    }

    // Ordenar por fecha descendente (más reciente primero)
    transacciones.sort((a, b) {
      final fechaA = a['fecha'] as DateTime?;
      final fechaB = b['fecha'] as DateTime?;

      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;

      return fechaB.compareTo(fechaA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transacciones Recientes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...transacciones.map(
          (transaccion) => _buildTransactionItem(
            transaccion['titulo'],
            transaccion['subtitulo'],
            transaccion['fecha'],
            transaccion['color'],
            transaccion['icono'],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    DateTime? date,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textPrimary.withAlpha(150),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (date != null)
            Text(
              '${date.day}/${date.month}',
              style: TextStyle(
                color: AppColors.textPrimary.withAlpha(100),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryTurquoise),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTurquoise.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryTurquoise.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isDense: true,
                      style: TextStyle(
                        color: AppColors.primaryTurquoise,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: AppColors.background,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryTurquoise,
                        size: 18,
                      ),
                      items:
                          months.map((month) {
                            return DropdownMenuItem<String>(
                              value: month['value'],
                              child: Text(
                                month['name']!,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMonth = newValue;
                          });
                          _loadData();

                          // Notificar al widget padre sobre el cambio de mes
                          if (widget.onMonthChanged != null) {
                            widget.onMonthChanged!(int.parse(newValue));
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
