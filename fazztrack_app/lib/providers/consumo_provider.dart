import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/producto_seleccionado_model.dart';
import 'package:fazztrack_app/services/ventas/ventas_api_service.dart';

class ConsumoProvider {
  Future<String> registrarConsumo(
    EstudianteModel estudiante,
    List<ProductoSeleccionadoModel> productos, [
    String? comentario,
  ]) async {
    final List<Map<String, dynamic>> ventasJson =
        productos.map((producto) {
          return {
            'id_estudiante': estudiante.id,
            'id_producto': producto.producto!.id,
            'fecha_transaccion':
                DateTime.now()
                    .toUtc()
                    .subtract(Duration(hours: 5))
                    .toIso8601String(),
            'id_bar': producto.producto!.idBar,
            'n_productos': producto.cantidad,
            'total': producto.subtotal,
            'comentario': comentario?.isNotEmpty == true ? comentario : null,
          };
        }).toList();

    try {
      await VentasApiService().createBulk(ventasJson);
      return 'OK';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
