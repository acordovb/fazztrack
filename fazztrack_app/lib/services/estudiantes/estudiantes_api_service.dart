import 'dart:convert';
import 'package:fazztrack_app/model/estudiante_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class EstudiantesApiService {
  final ApiService _apiService;

  EstudiantesApiService() : _apiService = ApiService();

  Future<List<EstudianteModel>> getAllEstudiantes() async {
    final response = await _apiService.get(API.estudiantes);
    final data = jsonDecode(response.body) as List;
    return EstudianteModel.fromJsonList(data);
  }

  Future<List<EstudianteModel>> searchEstudiantesByName(String nombre) async {
    final response = await _apiService.get(
      '${API.estudiantes}/search?nombre=$nombre',
    );
    final data = jsonDecode(response.body) as List;
    return EstudianteModel.fromJsonList(data);
  }

  Future<EstudianteModel> getEstudianteById(String id) async {
    final response = await _apiService.get('${API.estudiantes}/$id');
    final data = jsonDecode(response.body);
    return EstudianteModel.fromJson(data);
  }

  Future<EstudianteModel> createEstudiante(EstudianteModel estudiante) async {
    final response = await _apiService.post(
      API.estudiantes,
      estudiante.toJson(),
    );
    final data = jsonDecode(response.body);
    return EstudianteModel.fromJson(data);
  }

  Future<EstudianteModel> updateEstudiante(
    String id,
    EstudianteModel estudiante,
  ) async {
    final response = await _apiService.patch(
      '${API.estudiantes}/$id',
      estudiante.toJson(),
    );
    final data = jsonDecode(response.body);
    return EstudianteModel.fromJson(data);
  }

  Future<void> deleteEstudiante(String id) async {
    await _apiService.delete('${API.estudiantes}/$id');
  }
}
