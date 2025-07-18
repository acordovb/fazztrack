import 'dart:convert';

import '../api/api_routes.dart';
import '../api/api_service.dart';
import '../../models/control_historico_model.dart';

class ControlHistoricoApiService {
  final ApiService _apiService = ApiService();

  Future<ControlHistoricoModel> createControlHistorico(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(API.controlHistorico, data);
    return ControlHistoricoModel.fromJson(jsonDecode(response.body));
  }

  Future<ControlHistoricoModel?> getControlHistoricoByEstudianteId(
    String estudianteId, {
    int? month,
    int? year,
  }) async {
    try {
      String url = '${API.controlHistorico}/estudiante/$estudianteId';

      if (month != null) {
        url += '?month=$month';
      }
      if (year != null) {
        url += '${url.contains('?') ? '&' : '?'}year=$year';
      }

      final response = await _apiService.get(url);
      return ControlHistoricoModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (e.toString().contains('HTTP error: 404')) {
        return null;
      }
      rethrow;
    }
  }

  Future<ControlHistoricoModel> updateControlHistorico(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '${API.controlHistorico}/$id',
      data,
    );
    return ControlHistoricoModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteControlHistorico(String id) async {
    await _apiService.delete('${API.controlHistorico}/$id');
  }
}
