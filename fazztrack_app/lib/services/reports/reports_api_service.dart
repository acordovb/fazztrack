import 'dart:convert';
import 'package:fazztrack_app/models/report_response_model.dart';
import 'package:fazztrack_app/services/api/api_routes.dart';
import 'package:fazztrack_app/services/api/api_service.dart';

class ReportsApiService {
  final ApiService _apiService;

  ReportsApiService() : _apiService = ApiService();

  /// Generates reports for specific students
  /// [studentIds] List of student IDs to generate reports for
  Future<ReportResponseModel> generateReportsForStudents(
    List<String> studentIds,
  ) async {
    final requestBody = {'studentIds': studentIds};

    final response = await _apiService.post(
      '${API.pdfReports}/generate',
      requestBody,
    );

    final data = jsonDecode(response.body);
    return ReportResponseModel.fromJson(data);
  }

  /// Generates reports for a single student
  /// [studentId] The ID of the student to generate report for
  Future<ReportResponseModel> generateReportForStudent(String studentId) async {
    return generateReportsForStudents([studentId]);
  }

  /// Generates reports for all students
  Future<ReportResponseModel> generateAllReports() async {
    final response = await _apiService.post(
      '${API.pdfReports}/generate-all',
      {},
    );

    final data = jsonDecode(response.body);
    return ReportResponseModel.fromJson(data);
  }
}
