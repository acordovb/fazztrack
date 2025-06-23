import 'dart:convert';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class BarApiService {
  final ApiService _apiService;

  BarApiService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<BarModel>> getAllBars() async {
    final response = await _apiService.get(API.bares);
    final List<dynamic> barsList = jsonDecode(response.body);
    return BarModel.fromJsonList(barsList);
  }

  Future<BarModel> getBarById(String id) async {
    final response = await _apiService.get('${API.bares}/$id');
    final Map<String, dynamic> barJson = jsonDecode(response.body);
    return BarModel.fromJson(barJson);
  }

  Future<BarModel> createBar(String name) async {
    final Map<String, dynamic> data = {'nombre': name};

    final response = await _apiService.post(API.bares, data);
    final Map<String, dynamic> barJson = jsonDecode(response.body);
    return BarModel.fromJson(barJson);
  }

  Future<BarModel> updateBar(String id, String name) async {
    final Map<String, dynamic> data = {'nombre': name};

    final response = await _apiService.patch('${API.bares}/$id', data);
    final Map<String, dynamic> barJson = jsonDecode(response.body);
    return BarModel.fromJson(barJson);
  }

  Future<void> deleteBar(String id) async {
    await _apiService.delete('${API.bares}/$id');
  }
}
