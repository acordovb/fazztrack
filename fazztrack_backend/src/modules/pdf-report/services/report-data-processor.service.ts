import { Injectable } from '@nestjs/common';
import {
  ReportData,
  ProcessedReportData,
} from '../interfaces/report-data.interface';

@Injectable()
export class ReportDataProcessorService {
  /**
   * Procesa los datos del reporte agregando información adicional para la generación del PDF
   */
  processReportData(reportData: ReportData): ProcessedReportData {
    const monthNames = [
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

    const now = new Date();
    const currentMonthName = monthNames[reportData.currentMonth - 1];
    const currentYear = now.getFullYear();
    const currentDate = now.toLocaleDateString('es-ES');
    const currentTime = now.toLocaleTimeString('es-ES');

    return {
      ...reportData,
      currentMonthName,
      currentYear,
      currentDate,
      currentTime,
    };
  }
}
