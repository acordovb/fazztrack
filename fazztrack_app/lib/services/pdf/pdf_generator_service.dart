import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class PdfGeneratorService {
  static const List<String> _monthNames = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  Future<String> generateStudentReport({
    required EstudianteModel estudiante,
    required List<VentaModel> ventas,
    required List<AbonoModel> abonos,
    required ControlHistoricoModel? controlHistorico,
    required String barName,
    required int month,
    required int year,
  }) async {
    try {
      final pdf = pw.Document();

      final totalVentas = ventas.fold<double>(
        0.0,
        (sum, venta) =>
            sum + (venta.nProductos * (venta.producto?.precio ?? 0)),
      );

      final totalAbonos = abonos.fold<double>(
        0.0,
        (sum, abono) => sum + abono.total,
      );

      final pendienteAnteriorAbono =
          controlHistorico?.totalPendienteUltMesAbono ?? 0;
      final pendienteAnteriorVenta =
          controlHistorico?.totalPendienteUltMesVenta ?? 0;

      final balance =
          totalAbonos -
          totalVentas +
          pendienteAnteriorAbono -
          pendienteAnteriorVenta;

      final monthName = _monthNames[month];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                _buildHeader(estudiante, barName, monthName, year, month),
                pw.SizedBox(height: 20),
                _buildStudentInfo(estudiante, barName),
                pw.SizedBox(height: 20),
                _buildFinancialSummary(
                  totalVentas,
                  totalAbonos,
                  balance,
                  pendienteAnteriorAbono,
                  pendienteAnteriorVenta,
                ),
                pw.Spacer(), // Empuja el footer hacia abajo
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Segunda página - Detalle de transacciones
      if (ventas.isNotEmpty || abonos.isNotEmpty) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return [
                _buildTransactionHeader(estudiante, monthName, year),
                pw.SizedBox(height: 30),
                if (ventas.isNotEmpty) ...[
                  ..._buildVentasSection(ventas),
                  pw.SizedBox(height: 20),
                ],
                if (abonos.isNotEmpty) ...[
                  ..._buildAbonosSection(abonos),
                  pw.SizedBox(height: 20),
                ],
                _buildFooter(),
              ];
            },
          ),
        );
      }

      final filePath = await _savePdfToDevice(
        pdf,
        estudiante.nombre,
        monthName,
        year,
      );
      return filePath;
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  /// Generates, saves and optionally shares the PDF report
  Future<Map<String, dynamic>> generateAndSaveStudentReport({
    required EstudianteModel estudiante,
    required List<VentaModel> ventas,
    required List<AbonoModel> abonos,
    required ControlHistoricoModel? controlHistorico,
    required String barName,
    required int month,
    required int year,
    bool showShareOption = true,
  }) async {
    try {
      // Check and request permissions for mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          throw Exception(
            'No se otorgaron los permisos necesarios para guardar el archivo',
          );
        }
      }

      // Generate PDF
      final pdf = await _generatePdfDocument(
        estudiante: estudiante,
        ventas: ventas,
        abonos: abonos,
        controlHistorico: controlHistorico,
        barName: barName,
        month: month,
        year: year,
      );

      // Save PDF
      final filePath = await _savePdfWithUserChoice(
        pdf,
        estudiante.nombre,
        _monthNames[month],
        year,
      );

      final result = {
        'filePath': filePath,
        'success': true,
        'message': 'PDF guardado exitosamente',
      };

      // Add share option for mobile platforms
      if ((Platform.isAndroid || Platform.isIOS) && showShareOption) {
        result['canShare'] = true;
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al generar el PDF: $e',
        'filePath': null,
      };
    }
  }

  /// Shares the PDF file (mobile only)
  Future<bool> sharePdf(String filePath) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        throw Exception(
          'La función de compartir solo está disponible en dispositivos móviles',
        );
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Reporte de estudiante generado por FazzTrack',
        subject: 'Reporte FazzTrack',
      );

      return true;
    } catch (e) {
      throw Exception('Error al compartir el archivo: $e');
    }
  }

  /// Requests storage permission for Android
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33+), we don't need storage permissions for app-specific directories
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return true; // No storage permission needed for scoped storage
      }

      // For older Android versions
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't require explicit storage permissions for app documents
      return true;
    }
    return true;
  }

  /// Gets Android SDK version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simplified check. In a real app, you might want to use
      // device_info_plus package for more accurate version detection
      return 33; // Assume modern Android for now
    }
    return 0;
  }

  /// Generates the PDF document
  Future<pw.Document> _generatePdfDocument({
    required EstudianteModel estudiante,
    required List<VentaModel> ventas,
    required List<AbonoModel> abonos,
    required ControlHistoricoModel? controlHistorico,
    required String barName,
    required int month,
    required int year,
  }) async {
    final pdf = pw.Document();

    final totalVentas = ventas.fold<double>(
      0.0,
      (sum, venta) => sum + (venta.nProductos * (venta.producto?.precio ?? 0)),
    );

    final totalAbonos = abonos.fold<double>(
      0.0,
      (sum, abono) => sum + abono.total,
    );

    final pendienteAnteriorAbono =
        controlHistorico?.totalPendienteUltMesAbono ?? 0;
    final pendienteAnteriorVenta =
        controlHistorico?.totalPendienteUltMesVenta ?? 0;

    final balance =
        totalAbonos -
        totalVentas +
        pendienteAnteriorAbono -
        pendienteAnteriorVenta;

    final monthName = _monthNames[month];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(estudiante, barName, monthName, year, month),
              pw.SizedBox(height: 20),
              _buildStudentInfo(estudiante, barName),
              pw.SizedBox(height: 20),
              _buildFinancialSummary(
                totalVentas,
                totalAbonos,
                balance,
                pendienteAnteriorAbono,
                pendienteAnteriorVenta,
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Segunda página - Detalle de transacciones
    if (ventas.isNotEmpty || abonos.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              _buildTransactionHeader(estudiante, monthName, year),
              pw.SizedBox(height: 30),
              if (ventas.isNotEmpty) ...[
                ..._buildVentasSection(ventas),
                pw.SizedBox(height: 20),
              ],
              if (abonos.isNotEmpty) ...[
                ..._buildAbonosSection(abonos),
                pw.SizedBox(height: 20),
              ],
              _buildFooter(),
            ];
          },
        ),
      );
    }

    return pdf;
  }

  /// Saves PDF with user directory choice (mobile) or default location (desktop)
  Future<String> _savePdfWithUserChoice(
    pw.Document pdf,
    String studentName,
    String monthName,
    int year,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms, let user choose where to save
      return await _savePdfWithFilePicker(pdf, studentName, monthName, year);
    } else {
      // For desktop platforms, use the existing method
      return await _savePdfToDevice(pdf, studentName, monthName, year);
    }
  }

  /// Saves PDF using file picker for user to choose location
  Future<String> _savePdfWithFilePicker(
    pw.Document pdf,
    String studentName,
    String monthName,
    int year,
  ) async {
    try {
      // Generate filename
      final sanitizedName = studentName.replaceAll(
        RegExp(r'[<>:"/\\|?*]'),
        '_',
      );
      final fileName = 'Reporte_${sanitizedName}_${monthName}_$year.pdf';

      // Let user choose where to save the file
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar reporte PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        throw Exception('El usuario canceló la operación');
      }

      // Save the PDF
      final pdfBytes = await pdf.save();
      final file = File(result);
      await file.writeAsBytes(pdfBytes);

      if (await file.exists()) {
        return result;
      } else {
        throw Exception('El archivo no se pudo crear');
      }
    } catch (e) {
      // Fallback to app directory if file picker fails
      return await _savePdfToDevice(pdf, studentName, monthName, year);
    }
  }

  pw.Widget _buildHeader(
    EstudianteModel estudiante,
    String barName,
    String monthName,
    int year,
    int month,
  ) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          // Header azul oscuro
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF0a2647), // Azul oscuro
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Estado de Cuenta',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Reporte del mes de $monthName $year',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.white),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _buildDateRangeText(month, year),
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds student information section
  pw.Widget _buildStudentInfo(EstudianteModel estudiante, String barName) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC), // Fondo gris claro
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: pw.Row(
        children: [
          // Borde azul a la izquierda
          pw.Container(
            width: 4,
            height: 120,
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF0a2647),
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 20),
          // Contenido de la información
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Información del Estudiante',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF0a2647),
                  ),
                ),
                pw.SizedBox(height: 15),
                _buildInfoRow('Nombre:', estudiante.nombre),
                _buildInfoRow('Bar:', barName),
                _buildInfoRow('Curso:', estudiante.curso ?? 'No especificado'),
                _buildInfoRow(
                  'Celular:',
                  estudiante.celular ?? 'No especificado',
                ),
                _buildInfoRow(
                  'Representante:',
                  estudiante.nombreRepresentante ?? 'No especificado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds financial summary section
  pw.Widget _buildFinancialSummary(
    double totalVentas,
    double totalAbonos,
    double balance,
    double pendienteAnteriorAbono,
    double pendienteAnteriorVenta,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título del desglose
        pw.Text(
          'Desglose Financiero',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF374151),
          ),
        ),
        pw.SizedBox(height: 15),

        // Tabla de desglose con fondo gris claro
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF1F5F9), // Gris claro
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              if (pendienteAnteriorAbono > 0)
                _buildFinancialRow(
                  'Saldo a favor del mes anterior',
                  '+\$${pendienteAnteriorAbono.toStringAsFixed(2)}',
                  isPositive: true,
                ),
              if (pendienteAnteriorVenta > 0)
                _buildFinancialRow(
                  'Saldo pendiente del mes anterior',
                  '-\$${pendienteAnteriorVenta.toStringAsFixed(2)}',
                  isPositive: false,
                ),
              _buildFinancialRow(
                'Total Abonos del Mes',
                '+\$${totalAbonos.toStringAsFixed(2)}',
                isPositive: true,
              ),
              _buildFinancialRow(
                'Total Ventas del Mes',
                '-\$${totalVentas.toStringAsFixed(2)}',
                isPositive: false,
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: double.infinity,
                height: 1,
                color: const PdfColor.fromInt(0xFFD1D5DB),
              ),
              pw.SizedBox(height: 10),
              _buildFinancialRow(
                'Saldo Actual',
                '\$${balance.toStringAsFixed(2)}',
                isTotal: true,
                isPositive: balance >= 0,
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // Destacado del saldo - caja azul con texto verde
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFF0a2647), // Azul oscuro
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                balance >= 0 ? 'SALDO A FAVOR' : 'SALDO PENDIENTE DE PAGO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '\$${balance.abs().toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color:
                      balance >= 0
                          ? const PdfColor.fromInt(0xFF90ee90)
                          : const PdfColor.fromInt(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds transaction page header
  pw.Widget _buildTransactionHeader(
    EstudianteModel estudiante,
    String monthName,
    int year,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFF0a2647), // Azul oscuro
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Detalle de Transacciones',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Estudiante: ${estudiante.nombre} - $monthName $year',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  /// Builds the date range text based on whether it's current month or not
  String _buildDateRangeText(int month, int year) {
    final now = DateTime.now();
    final isCurrentMonth = now.month == month && now.year == year;

    if (isCurrentMonth) {
      // Si es el mes actual, mostrar desde el 1 hasta hoy
      return 'Del 1/$month/$year al ${now.day}/$month/$year';
    } else {
      // Si es un mes anterior, mostrar el mes completo
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      return 'Del 1/$month/$year al $lastDayOfMonth/$month/$year';
    }
  }

  /// Safely formats product name for display in PDF
  String _formatProductName(String? productName, String productId) {
    // Debugging line
    if (productName == null || productName.isEmpty) {
      return 'Producto $productId';
    }

    return productName.replaceAll('/', '').trim();
  }

  /// Builds sales section - Fixed for pagination
  List<pw.Widget> _buildVentasSection(List<VentaModel> ventas) {
    final List<pw.Widget> widgets = [];

    // Título de la sección
    widgets.add(
      pw.Text(
        'Ventas del Mes',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF374151),
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 15));

    // Crear tabla usando TableHelper para paginación automática
    final tableData = <List<String>>[
      ['Fecha', 'Producto', 'Cantidad', 'Comentario', 'Total'], // Header
    ];

    // Agregar datos de ventas
    for (final venta in ventas) {
      final total = venta.nProductos * (venta.producto?.precio ?? 0);
      tableData.add([
        DateFormat('d/M/yyyy').format(venta.fechaTransaccion),
        _formatProductName(venta.producto?.nombre, venta.idProducto),
        venta.nProductos.toString(),
        venta.comentario ?? '-',
        '\$${total.toStringAsFixed(2)}',
      ]);
    }

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: tableData,
        border: pw.TableBorder.all(
          color: const PdfColor.fromInt(0xFFE5E7EB),
          width: 1,
        ),
        headerDecoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF0a2647), // Azul oscuro
        ),
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
        cellDecoration:
            (int index, dynamic data, int rowNum) => const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF8FAFC), // Fondo gris muy claro
            ),
        cellAlignment: pw.Alignment.center,
        headerAlignment: pw.Alignment.center,
        columnWidths: {
          0: const pw.FlexColumnWidth(1.5), // Fecha
          1: const pw.FlexColumnWidth(2), // Producto
          2: const pw.FlexColumnWidth(1), // Cantidad
          3: const pw.FlexColumnWidth(2), // Comentario
          4: const pw.FlexColumnWidth(1), // Total
        },
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        headerPadding: const pw.EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
      ),
    );

    return widgets;
  }

  /// Builds payments section - Fixed for pagination
  List<pw.Widget> _buildAbonosSection(List<AbonoModel> abonos) {
    final List<pw.Widget> widgets = [];

    // Título de la sección
    widgets.add(
      pw.Text(
        'Abonos del Mes',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF374151),
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 15));

    // Crear tabla usando TableHelper para paginación automática
    final tableData = <List<String>>[
      ['Fecha', 'Tipo de Abono', 'Comentario', 'Monto'], // Header
    ];

    // Agregar datos de abonos
    for (final abono in abonos) {
      tableData.add([
        DateFormat('d/M/yyyy').format(abono.fechaAbono),
        abono.tipoAbono,
        abono.comentario ?? '-',
        '\$${abono.total.toStringAsFixed(2)}',
      ]);
    }

    widgets.add(
      pw.TableHelper.fromTextArray(
        context: null,
        data: tableData,
        border: pw.TableBorder.all(
          color: const PdfColor.fromInt(0xFFE5E7EB),
          width: 1,
        ),
        headerDecoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF0a2647), // Azul oscuro
        ),
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
        cellDecoration:
            (int index, dynamic data, int rowNum) => const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF8FAFC), // Fondo gris muy claro
            ),
        cellAlignment: pw.Alignment.center,
        headerAlignment: pw.Alignment.center,
        columnWidths: {
          0: const pw.FlexColumnWidth(1.5), // Fecha
          1: const pw.FlexColumnWidth(2), // Tipo de Abono
          2: const pw.FlexColumnWidth(2), // Comentario
          3: const pw.FlexColumnWidth(1), // Monto
        },
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        headerPadding: const pw.EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
      ),
    );

    return widgets;
  }

  /// Builds footer
  pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 0),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF1F5F9), // Fondo gris claro
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Reporte generado el ${DateFormat('d/M/yyyy').format(DateTime.now())} a las ${DateFormat('HH:mm:ss').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: const PdfColor.fromInt(0xFF374151),
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'FazzTrack - Sistema de Gestión de Pagos y Cuotas',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF0a2647),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper method to build info rows
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build financial summary rows
  pw.Widget _buildFinancialRow(
    String label,
    String value, {
    bool isPositive = true,
    bool isTotal = false,
    bool isHighlight = false,
  }) {
    // Use isTotal for highlighting if it's set, otherwise use isHighlight
    final shouldHighlight = isTotal || isHighlight;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          shouldHighlight
              ? pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0a2647),
                borderRadius: pw.BorderRadius.circular(8),
              )
              : null,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.bold,
              color: shouldHighlight ? PdfColors.white : PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
              color:
                  shouldHighlight
                      ? PdfColors.white
                      : (isTotal
                          ? PdfColors.black
                          : (isPositive
                              ? const PdfColor.fromInt(
                                0xFF059669,
                              ) // Verde para positivos
                              : const PdfColor.fromInt(
                                0xFFDC2626,
                              ))), // Rojo para negativos
            ),
          ),
        ],
      ),
    );
  }

  /// Saves the PDF to device storage (fallback method)
  Future<String> _savePdfToDevice(
    pw.Document pdf,
    String studentName,
    String monthName,
    int year,
  ) async {
    try {
      // Get the appropriate directory based on platform
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, use app-specific directory (no permissions needed for Android 13+)
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isMacOS) {
        // For macOS, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isWindows) {
        // For Windows, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isLinux) {
        // For Linux, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
        } catch (e) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure we have a valid directory
      if (directory == null) {
        throw Exception('Could not determine save directory for platform');
      }

      // Create FazzTrack subdirectory if it doesn't exist
      final fazztrackDir = Directory('${directory.path}/FazzTrack');
      if (!await fazztrackDir.exists()) {
        await fazztrackDir.create(recursive: true);
      }

      // Generate filename
      final sanitizedName = studentName.replaceAll(
        RegExp(r'[<>:"/\\|?*]'),
        '_',
      );
      final fileName = 'Reporte_${sanitizedName}_${monthName}_$year.pdf';
      final filePath = '${fazztrackDir.path}/$fileName';

      // Save the PDF
      final file = File(filePath);
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      if (await file.exists()) {
        return filePath;
      } else {
        throw Exception('File was not created successfully');
      }
    } catch (e) {
      throw Exception('Error saving PDF to device: $e');
    }
  }
}
