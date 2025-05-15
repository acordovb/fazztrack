import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/producto_seleccionado_model.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class ConsumoProvider {
  final ApiService _apiService = ApiService();

  Future<void> registrarConsumo(
    EstudianteModel estudiante,
    List<ProductoSeleccionadoModel> productos,
    ControlHistoricoModel controlHistorico,
    double total,
  ) async {
    final List<Map<String, dynamic>> ventasJson =
        productos.map((producto) {
          return {
            'id_estudiante': estudiante.id,
            'id_producto': producto.producto!.id,
            'fecha_transaccion': DateTime.now().toUtc().toIso8601String(),
            'id_bar': producto.producto!.idBar,
            'n_productos': producto.cantidad,
          };
        }).toList();

    final newControlHistorico = controlHistorico.copyWith(
      totalVenta: controlHistorico.totalVenta + total,
    );

    final body = {
      'ventas': ventasJson,
      'control_historico': newControlHistorico.toJson(),
    };
    try {
      await _apiService.post('/ventas/bulk', body);
    } catch (e) {
      print('Error al registrar el consumo: $e');
    }
  }
}
