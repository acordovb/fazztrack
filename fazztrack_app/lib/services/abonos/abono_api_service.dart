import 'dart:convert';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class AbonoApiService {
  final ApiService _apiService;

  AbonoApiService() : _apiService = ApiService();

  Future<AbonoModel> createAbono(AbonoModel abono) async {
    try {
      final response = await _apiService.post(API.abonos, abono.toJson());
      final data = jsonDecode(response.body);
      return AbonoModel.fromJson(data);
    } catch (e) {
      throw Exception('Error creating abono: $e');
    }
  }

  Future<List<AbonoModel>> findAllByStudent(
    String idStudent, {
    int? mes,
  }) async {
    try {
      String url = '${API.abonos}/$idStudent';
      if (mes != null) {
        url += '?mes=$mes';
      }

      final response = await _apiService.get(url);
      final data = jsonDecode(response.body) as List;
      return data.map((json) => AbonoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting abonos for student: $e');
    }
  }

  Future<AbonoModel> updateAbono(String id, AbonoModel abono) async {
    try {
      final abonoData = abono.toJson();
      final response = await _apiService.patch('${API.abonos}/$id', abonoData);
      final data = jsonDecode(response.body);
      return AbonoModel.fromJson(data);
    } catch (e) {
      throw Exception('Error updating abono: $e');
    }
  }

  Future<void> deleteAbono(String id) async {
    try {
      await _apiService.delete('${API.abonos}/$id');
    } catch (e) {
      throw Exception('Error deleting abono: $e');
    }
  }
}
