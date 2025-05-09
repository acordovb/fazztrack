import 'dart:convert';

import '../api/api_routes.dart';
import '../api/api_service.dart';
import '../../model/control_historico.dart';

class ControlHistoricoApiService {
  final ApiService _apiService = ApiService();

  Future<ControlHistorico> createControlHistorico(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(API.controlHistorico, data);
    return ControlHistorico.fromJson(jsonDecode(response.body));
  }

  Future<ControlHistorico?> getControlHistoricoByEstudianteId(
    String estudianteId,
  ) async {
    try {
      final response = await _apiService.get(
        '${API.controlHistorico}/estudiante/$estudianteId',
      );
      return ControlHistorico.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (e.toString().contains('HTTP error: 404')) {
        return null;
      }
      rethrow;
    }
  }

  Future<ControlHistorico> updateControlHistorico(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '${API.controlHistorico}/$id',
      data,
    );
    return ControlHistorico.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteControlHistorico(String id) async {
    await _apiService.delete('${API.controlHistorico}/$id');
  }
}
