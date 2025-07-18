import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:fazztrack_app/services/pdf/pdf_generator_service.dart';
import 'package:fazztrack_app/services/ventas/ventas_api_service.dart';
import 'package:fazztrack_app/services/abonos/abono_api_service.dart';
import 'package:fazztrack_app/services/estudiantes/control_historico_api_service.dart';

/// Modelo para el resultado de generación de reportes en lote
class BulkReportResult {
  final int totalReports;
  final int successfulReports;
  final int failedReports;
  final List<String> generatedPaths;
  final List<String> errors;

  BulkReportResult({
    required this.totalReports,
    required this.successfulReports,
    required this.failedReports,
    required this.generatedPaths,
    required this.errors,
  });
}

typedef ProgressCallback =
    void Function(int current, int total, String studentName);

class LocalReportsService {
  final PdfGeneratorService _pdfGeneratorService = PdfGeneratorService();
  final VentasApiService _ventasApiService = VentasApiService();
  final AbonoApiService _abonoApiService = AbonoApiService();
  final ControlHistoricoApiService _controlHistoricoApiService =
      ControlHistoricoApiService();

  /// FUNCIÓN PRINCIPAL 1: Genera reportes PDF para múltiples estudiantes
  /// Consulta todos los datos necesarios y muestra progreso con popup
  Future<BulkReportResult?> generateBulkStudentReportsWithProgress({
    required BuildContext context,
    required List<EstudianteModel> estudiantes,
    int? month,
    int? year,
  }) async {
    return showDialog<BulkReportResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _BulkReportProgressDialog(
          estudiantes: estudiantes,
          month: month,
          year: year,
          reportsService: this,
        );
      },
    );
  }

  /// FUNCIÓN PRINCIPAL 2: Genera un reporte PDF con datos ya preparados
  /// No consulta APIs, solo usa los datos proporcionados
  Future<String> generateReportWithData({
    required BuildContext context,
    required EstudianteModel estudiante,
    required List<VentaModel> ventas,
    required List<AbonoModel> abonos,
    required ControlHistoricoModel? controlHistorico,
    required int month,
    required int year,
  }) async {
    try {
      // Generar PDF directamente con los datos proporcionados
      final filePath = await _pdfGeneratorService.generateStudentReport(
        estudiante: estudiante,
        ventas: ventas,
        abonos: abonos,
        controlHistorico: controlHistorico,
        barName: estudiante.bar?.nombre ?? '',
        month: month,
        year: year,
      );

      // Mostrar diálogo de éxito
      _showReportGeneratedDialog(context, filePath);

      return filePath;
    } catch (e) {
      throw Exception('Error generating report with provided data: $e');
    }
  }

  /// Método interno para la generación en lote (usado por el diálogo de progreso)
  Future<BulkReportResult> _generateBulkStudentReports({
    required List<EstudianteModel> estudiantes,
    int? month,
    int? year,
    ProgressCallback? onProgress,
  }) async {
    final currentDate = DateTime.now();
    final reportMonth = month ?? currentDate.month;
    final reportYear = year ?? currentDate.year;

    final generatedPaths = <String>[];
    final errors = <String>[];
    int successfulReports = 0;
    int failedReports = 0;

    for (int i = 0; i < estudiantes.length; i++) {
      final estudiante = estudiantes[i];

      try {
        // Notificar progreso
        onProgress?.call(i + 1, estudiantes.length, estudiante.nombre);

        // Consultar datos del estudiante
        final ventas = await _ventasApiService.findAllByStudent(
          estudiante.id,
          reportMonth,
          reportYear,
        );

        final abonos = await _abonoApiService.findAllByStudent(
          estudiante.id,
          reportMonth,
          reportYear,
        );

        final controlHistorico = await _controlHistoricoApiService
            .getControlHistoricoByEstudianteId(
              estudiante.id,
              month: reportMonth,
              year: reportYear,
            );

        // Generar PDF
        final filePath = await _pdfGeneratorService.generateStudentReport(
          estudiante: estudiante,
          ventas: ventas,
          abonos: abonos,
          controlHistorico: controlHistorico,
          barName: estudiante.bar?.nombre ?? '',
          month: reportMonth,
          year: reportYear,
        );

        generatedPaths.add(filePath);
        successfulReports++;
      } catch (e) {
        final error = 'Error generando reporte para ${estudiante.nombre}: $e';
        errors.add(error);
        failedReports++;
      }

      // Pequeña pausa para no sobrecargar el sistema
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return BulkReportResult(
      totalReports: estudiantes.length,
      successfulReports: successfulReports,
      failedReports: failedReports,
      generatedPaths: generatedPaths,
      errors: errors,
    );
  }

  /// Muestra un diálogo de confirmación cuando se genera un reporte
  void _showReportGeneratedDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            'Reporte Generado',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'El reporte PDF ha sido generado y guardado exitosamente. Verifique en la carpeta de documentos de su dispositivo.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: TextStyle(color: AppColors.primaryTurquoise),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget para mostrar el progreso de generación de reportes en lote
class _BulkReportProgressDialog extends StatefulWidget {
  final List<EstudianteModel> estudiantes;
  final int? month;
  final int? year;
  final LocalReportsService reportsService;

  const _BulkReportProgressDialog({
    required this.estudiantes,
    this.month,
    this.year,
    required this.reportsService,
  });

  @override
  State<_BulkReportProgressDialog> createState() =>
      _BulkReportProgressDialogState();
}

class _BulkReportProgressDialogState extends State<_BulkReportProgressDialog> {
  int _currentProgress = 0;
  String _currentStudentName = '';
  bool _isCompleted = false;
  BulkReportResult? _result;

  @override
  void initState() {
    super.initState();
    _startGeneratingReports();
  }

  Future<void> _startGeneratingReports() async {
    try {
      final result = await widget.reportsService._generateBulkStudentReports(
        estudiantes: widget.estudiantes,
        month: widget.month,
        year: widget.year,
        onProgress: (current, total, studentName) {
          if (mounted) {
            setState(() {
              _currentProgress = current;
              _currentStudentName = studentName;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isCompleted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = BulkReportResult(
            totalReports: widget.estudiantes.length,
            successfulReports: 0,
            failedReports: widget.estudiantes.length,
            generatedPaths: [],
            errors: ['Error general: $e'],
          );
          _isCompleted = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.estudiantes.length;
    final progress = total > 0 ? _currentProgress / total : 0.0;

    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        _isCompleted ? 'Generación Completada' : 'Generando Reportes',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isCompleted) ...[
              Text(
                'Generando reporte $_currentProgress de $total',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Estudiante: $_currentStudentName',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.darkGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryTurquoise,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ] else if (_result != null) ...[
              _buildResultSummary(),
              if (_result!.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildErrorList(),
              ],
            ],
          ],
        ),
      ),
      actions: [
        if (_isCompleted)
          TextButton(
            onPressed: () => Navigator.of(context).pop(_result),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryTurquoise,
            ),
            child: const Text('Cerrar'),
          ),
      ],
    );
  }

  Widget _buildResultSummary() {
    final result = _result!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryTurquoise.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Generación',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Total de reportes:', '${result.totalReports}'),
          _buildSummaryRow(
            'Exitosos:',
            '${result.successfulReports}',
            color: AppColors.success,
          ),
          if (result.failedReports > 0)
            _buildSummaryRow(
              'Fallidos:',
              '${result.failedReports}',
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Errores:',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: BoxDecoration(
            color: AppColors.secondaryBlue,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  _result!.errors.map((error) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• $error',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
