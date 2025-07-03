import { Injectable } from '@nestjs/common';
import { EstudiantesService } from '../../estudiantes/estudiantes.service';
import { AbonosService } from '../../abonos/abonos.service';
import { VentasService } from '../../ventas/ventas.service';
import { ControlHistoricoService } from '../../control-historico/control-historico.service';
import { ReportData } from '../interfaces/report-data.interface';

@Injectable()
export class ReportDataService {
  constructor(
    private readonly estudiantesService: EstudiantesService,
    private readonly abonosService: AbonosService,
    private readonly ventasService: VentasService,
    private readonly controlHistoricoService: ControlHistoricoService,
  ) {}

  /**
   * Obtiene todos los datos necesarios para generar el reporte de un estudiante
   */
  async getReportData(studentId: string): Promise<ReportData | null> {
    const currentMonth = new Date().getMonth() + 1;

    const student = await this.estudiantesService.findOne(studentId);
    if (!student) {
      return null;
    }

    // Obtener transacciones del mes actual
    const abonos = await this.abonosService.findAllByStudent(
      studentId,
      currentMonth,
    );
    const ventas = await this.ventasService.findAllByStudent(
      studentId,
      currentMonth,
    );

    // Obtener control histórico
    const controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(studentId);

    // Verificar si hay datos para generar el reporte
    if (!this.hasReportableData(abonos, ventas, controlHistorico)) {
      return null;
    }

    // Calcular totales
    const totalAbonos = this.calculateTotal(abonos);
    const totalVentas = this.calculateTotal(ventas);
    const saldoPendienteMesAnterior =
      this.calculatePreviousMonthBalance(controlHistorico);
    const saldoActual = totalAbonos - totalVentas + saldoPendienteMesAnterior;

    return {
      student,
      abonos,
      ventas,
      totalAbonos,
      totalVentas,
      saldoActual,
      saldoPendienteMesAnterior,
      currentMonth,
    };
  }

  /**
   * Obtiene los datos de reporte para todos los estudiantes
   */
  async getAllStudentsReportData(): Promise<ReportData[]> {
    const allStudents = await this.estudiantesService.findAll();
    const reportDataPromises = allStudents.map((student) =>
      this.getReportData(student.id),
    );

    const reportDataResults = await Promise.all(reportDataPromises);

    return reportDataResults.filter(
      (data): data is ReportData => data !== null,
    );
  }

  /**
   * Verifica si hay datos suficientes para generar un reporte
   */
  private hasReportableData(
    abonos: any[],
    ventas: any[],
    controlHistorico: any,
  ): boolean {
    return (
      abonos.length > 0 ||
      ventas.length > 0 ||
      (controlHistorico?.total_pendiente_ult_mes_abono || 0) > 0 ||
      (controlHistorico?.total_pendiente_ult_mes_venta || 0) > 0
    );
  }

  /**
   * Calcula el total de una lista de transacciones
   */
  private calculateTotal(transactions: Array<{ total: number }>): number {
    return transactions.reduce(
      (sum, transaction) => sum + Number(transaction.total),
      0,
    );
  }

  /**
   * Calcula el saldo pendiente del mes anterior
   */
  private calculatePreviousMonthBalance(controlHistorico: any): number {
    if (!controlHistorico) {
      return 0;
    }
    return (
      (controlHistorico.total_pendiente_ult_mes_abono || 0) -
      (controlHistorico.total_pendiente_ult_mes_venta || 0)
    );
  }
}
