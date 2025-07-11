import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fazztrack_app/models/estudiante_model.dart';
import 'package:fazztrack_app/models/venta_model.dart';
import 'package:fazztrack_app/models/abono_model.dart';
import 'package:fazztrack_app/models/control_historico_model.dart';

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

      // Primera página - Solo resumen
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                _buildHeader(estudiante, barName, monthName, year, month),
                pw.SizedBox(height: 30),
                _buildStudentInfo(estudiante, barName),
                pw.SizedBox(height: 30),
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
                  _buildVentasSection(ventas),
                  pw.SizedBox(height: 20),
                ],
                if (abonos.isNotEmpty) ...[
                  _buildAbonosSection(abonos),
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
                  'Del 1/$month/$year al ${DateTime(year, month + 1, 0).day}/$month/$year',
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
                balance >= 0 ? 'SALDO A FAVOR' : 'SALDO PENDIENTE',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '\$${balance.toStringAsFixed(2)}',
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

  /// Builds sales section
  pw.Widget _buildVentasSection(List<VentaModel> ventas) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ventas del Mes',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF374151),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5), // Fecha
              1: const pw.FlexColumnWidth(2.5), // Producto
              2: const pw.FlexColumnWidth(1), // Cantidad
              3: const pw.FlexColumnWidth(1), // Total
            },
            children: [
              // Header con fondo azul oscuro
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0a2647), // Azul oscuro
                ),
                children: [
                  _buildTableHeaderCell('Fecha'),
                  _buildTableHeaderCell('Producto'),
                  _buildTableHeaderCell('Cantidad'),
                  _buildTableHeaderCell('Total'),
                ],
              ),
              // Data rows
              ...ventas.map((venta) {
                final total = venta.nProductos * (venta.producto?.precio ?? 0);
                return pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC), // Fondo gris muy claro
                  ),
                  children: [
                    _buildTableDataCell(
                      DateFormat('d/M/yyyy').format(venta.fechaTransaccion),
                    ),
                    _buildTableDataCell(
                      venta.producto?.nombre ?? 'Producto ${venta.idProducto}',
                    ),
                    _buildTableDataCell(venta.nProductos.toString()),
                    _buildTableDataCell('\$${total.toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds payments section
  pw.Widget _buildAbonosSection(List<AbonoModel> abonos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Abonos del Mes',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF374151),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5), // Fecha
              1: const pw.FlexColumnWidth(2), // Tipo de Abono
              2: const pw.FlexColumnWidth(2), // Comentario
              3: const pw.FlexColumnWidth(1), // Monto
            },
            children: [
              // Header con fondo azul oscuro
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0a2647), // Azul oscuro
                ),
                children: [
                  _buildTableHeaderCell('Fecha'),
                  _buildTableHeaderCell('Tipo de Abono'),
                  _buildTableHeaderCell('Comentario'),
                  _buildTableHeaderCell('Monto'),
                ],
              ),
              // Data rows
              ...abonos.map((abono) {
                return pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC), // Fondo gris muy claro
                  ),
                  children: [
                    _buildTableDataCell(
                      DateFormat('d/M/yyyy').format(abono.fechaAbono),
                    ),
                    _buildTableDataCell(abono.tipoAbono),
                    _buildTableDataCell('-'), // Placeholder para comentario
                    _buildTableDataCell('\$${abono.total.toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds footer
  pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 40),
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

  /// Helper method to build table header cells
  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      color: PdfColor.fromInt(0xFF0a2647),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Helper method to build table data cells
  pw.Widget _buildTableDataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
        textAlign: pw.TextAlign.center,
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

  /// Saves the PDF to device storage
  Future<String> _savePdfToDevice(
    pw.Document pdf,
    String studentName,
    String monthName,
    int year,
  ) async {
    try {
      // Get the appropriate directory based on platform
      Directory? directory;
      String platformInfo = '';

      if (Platform.isAndroid) {
        // For Android, use external storage directory
        directory = await getExternalStorageDirectory();
        directory ??= await getApplicationDocumentsDirectory();
        platformInfo = 'Android - External Storage';
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
        platformInfo = 'iOS - Documents';
      } else if (Platform.isMacOS) {
        // For macOS, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
          platformInfo = 'macOS - Downloads';
        } catch (e) {
          print('Could not access Downloads directory on macOS: $e');
          directory = await getApplicationDocumentsDirectory();
          platformInfo = 'macOS - Documents (fallback)';
        }
      } else if (Platform.isWindows) {
        // For Windows, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
          platformInfo = 'Windows - Downloads';
        } catch (e) {
          print('Could not access Downloads directory on Windows: $e');
          directory = await getApplicationDocumentsDirectory();
          platformInfo = 'Windows - Documents (fallback)';
        }
      } else if (Platform.isLinux) {
        // For Linux, try Downloads directory first
        try {
          directory = await getDownloadsDirectory();
          platformInfo = 'Linux - Downloads';
        } catch (e) {
          print('Could not access Downloads directory on Linux: $e');
          directory = await getApplicationDocumentsDirectory();
          platformInfo = 'Linux - Documents (fallback)';
        }
      } else {
        // Fallback to documents directory
        directory = await getApplicationDocumentsDirectory();
        platformInfo = 'Unknown Platform - Documents';
      }

      print('Saving PDF to: $platformInfo');
      print('Directory path: ${directory?.path ?? 'null'}');

      // Ensure we have a valid directory
      if (directory == null) {
        throw Exception('Could not determine save directory for platform');
      }

      // Create FazzTrack subdirectory if it doesn't exist
      final fazztrackDir = Directory('${directory.path}/FazzTrack');
      if (!await fazztrackDir.exists()) {
        await fazztrackDir.create(recursive: true);
        print('Created FazzTrack directory: ${fazztrackDir.path}');
      }

      // Generate filename
      final sanitizedName = studentName.replaceAll(
        RegExp(r'[<>:"/\\|?*]'),
        '_',
      );
      final fileName = 'Reporte_${sanitizedName}_${monthName}_$year.pdf';
      final filePath = '${fazztrackDir.path}/$fileName';

      print('Full file path: $filePath');

      // Save the PDF
      final file = File(filePath);
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        print('PDF saved successfully. Size: $fileSize bytes');
      } else {
        throw Exception('File was not created successfully');
      }

      return filePath;
    } catch (e) {
      print('Error saving PDF to device: $e');
      throw Exception('Error saving PDF to device: $e');
    }
  }
}
