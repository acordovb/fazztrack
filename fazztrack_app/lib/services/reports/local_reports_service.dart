import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/services/pdf/pdf_generator_service.dart';
import 'package:fazztrack_app/services/ventas/ventas_api_service.dart';
import 'package:fazztrack_app/services/abonos/abono_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/control_historico_api_service.dart';

class LocalReportsService {
  final PdfGeneratorService _pdfGeneratorService = PdfGeneratorService();
  final VentasApiService _ventasApiService = VentasApiService();
  final AbonoApiService _abonoApiService = AbonoApiService();
  final ControlHistoricoApiService _controlHistoricoApiService =
      ControlHistoricoApiService();

  /// Generates a local PDF report for a student
  Future<String> generateLocalStudentReport({
    required EstudianteModel estudiante,
    required String barName,
    int? month,
    int? year,
  }) async {
    try {
      final currentDate = DateTime.now();
      final reportMonth = month ?? currentDate.month;
      final reportYear = year ?? currentDate.year;

      // Fetch student data
      final ventas = await _ventasApiService.findAllByStudent(
        estudiante.id,
        mes: reportMonth,
      );

      final abonos = await _abonoApiService.findAllByStudent(
        estudiante.id,
        mes: reportMonth,
      );

      final controlHistorico = await _controlHistoricoApiService
          .getControlHistoricoByEstudianteId(estudiante.id, month: reportMonth);

      // Generate PDF
      final filePath = await _pdfGeneratorService.generateStudentReport(
        estudiante: estudiante,
        ventas: ventas,
        abonos: abonos,
        controlHistorico: controlHistorico,
        barName: barName,
        month: reportMonth,
        year: reportYear,
      );

      return filePath;
    } catch (e) {
      throw Exception('Error generating local student report: $e');
    }
  }

  /// Gets the storage information for different platforms
  Future<Map<String, String>> getStorageInfo() async {
    final info = <String, String>{};

    try {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        try {
          final downloadsDir = await getDownloadsDirectory();
          info['downloads'] = downloadsDir?.path ?? 'No disponible';
        } catch (e) {
          info['downloads'] = 'Error: $e';
        }
      }

      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        info['documents'] = documentsDir.path;
      } catch (e) {
        info['documents'] = 'Error: $e';
      }

      info['platform'] = Platform.operatingSystem;
      info['fazztrack_folder'] =
          Platform.isMacOS || Platform.isWindows || Platform.isLinux
              ? '${info['downloads']}/FazzTrack'
              : '${info['documents']}/FazzTrack';
    } catch (e) {
      info['error'] = e.toString();
    }

    return info;
  }
}
