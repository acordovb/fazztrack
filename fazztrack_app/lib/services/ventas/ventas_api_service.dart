import 'dart:convert';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class VentasApiService {
  final ApiService _apiService;

  VentasApiService() : _apiService = ApiService();

  Future<void> createBulk({
    required List<VentaModel> ventas,
    required ControlHistoricoModel controlHistorico,
    required int idEstudiante,
  }) async {
    try {
      final body = {
        'ventas': ventas.map((venta) => venta.toJson()).toList(),
        'controlHistorico': {
          ...controlHistorico.toJson(),
          'id_estudiante': idEstudiante,
        },
      };

      await _apiService.post('${API.ventas}/bulk', body);
    } catch (e) {
      throw Exception('Error creating ventas in bulk: $e');
    }
  }

  Future<List<VentaModel>> findAllByStudent(
    String idStudent, {
    int? mes,
  }) async {
    try {
      String url = '${API.ventas}/$idStudent';
      if (mes != null) {
        url += '?mes=$mes';
      }

      final response = await _apiService.get(url);
      final data = jsonDecode(response.body) as List;
      return data.map((json) => VentaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting ventas for student: $e');
    }
  }

  Future<VentaModel> updateVenta(String id, VentaModel venta) async {
    try {
      final ventaData = venta.toJson();
      final response = await _apiService.patch('${API.ventas}/$id', ventaData);
      final data = jsonDecode(response.body);
      return VentaModel.fromJson(data);
    } catch (e) {
      throw Exception('Error updating venta: $e');
    }
  }

  Future<void> deleteVenta(String id) async {
    try {
      await _apiService.delete('${API.ventas}/$id');
    } catch (e) {
      throw Exception('Error deleting venta: $e');
    }
  }
}
