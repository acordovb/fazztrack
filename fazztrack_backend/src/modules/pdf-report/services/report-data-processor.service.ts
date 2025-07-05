import { Injectable } from '@nestjs/common';
import {
  ReportData,
  ProcessedReportData,
} from '../interfaces/report-data.interface';
import { BarsService } from '../../bars/bars.service';

@Injectable()
export class ReportDataProcessorService {
  constructor(private readonly barsService: BarsService) {}

  /**
   * Procesa los datos del reporte agregando información adicional para la generación del PDF
   */
  async processReportData(
    reportData: ReportData,
  ): Promise<ProcessedReportData> {
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

    // Generar el rango de fechas: del 1ro al día actual del mes
    const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const reportDateRange = `Del ${firstDayOfMonth.toLocaleDateString('es-ES')} al ${currentDate}`;

    // Obtener información del bar si hay ID disponible
    let barName: string | undefined = undefined;
    try {
      if (reportData.student.id_bar) {
        const bar = await this.barsService.findOne(reportData.student.id_bar);
        if (bar) {
          barName = bar.nombre;
        }
      }
    } catch (error) {
      console.error('Error al obtener información del bar:', error);
    }

    return {
      ...reportData,
      currentMonthName,
      currentYear,
      currentDate,
      currentTime,
      reportDateRange,
      barName,
    };
  }
}
