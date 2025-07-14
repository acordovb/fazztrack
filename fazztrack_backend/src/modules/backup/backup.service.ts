import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { DatabaseService } from '../../database/database.service';
import { MailService } from '../../shared/mail/mail.service';

@Injectable()
export class BackupService {
  private readonly logger = new Logger(BackupService.name);

  constructor(
    private readonly database: DatabaseService,
    private readonly mailService: MailService,
  ) {}

  /**
   * Cron job que se ejecuta el primer día del mes a la 1:00 AM
   * Hace backup de abonos, ventas y control_historico del mes anterior
   */
  @Cron('0 1 1 * *') // 1:00 AM del primer día de cada mes
  async runMonthlyBackup(): Promise<void> {
    this.logger.log('Starting monthly backup process...');

    try {
      const previousMonth = this.getPreviousMonth();
      const { year, month } = previousMonth;

      this.logger.log(`Creating backup for ${month}/${year}`);

      // Ejecutar backups uno por uno para evitar cancelaciones
      await this.backupAbonos(year, month);
      await this.delay(5000); // Esperar 5 segundos entre operaciones

      await this.backupVentas(year, month);
      await this.delay(5000); // Esperar 5 segundos entre operaciones

      await this.backupControlHistorico(year, month);

      this.logger.log('Monthly backup process completed successfully');
    } catch (error) {
      this.logger.error('Monthly backup process failed:', error);
      throw error;
    }
  }

  /**
   * Backup manual de abonos del mes anterior
   */
  async backupAbonos(year?: number, month?: number): Promise<void> {
    const { year: targetYear, month: targetMonth } =
      year && month ? { year, month } : this.getPreviousMonth();

    this.logger.log(`Starting abonos backup for ${targetMonth}/${targetYear}`);

    try {
      const data = await this.getAbonosData(targetYear, targetMonth);
      const csvContent = this.convertAbonosToCSV(data);
      const backupDate = `${targetYear}-${targetMonth.toString().padStart(2, '0')}`;

      await this.mailService.sendCsvBackupEmail(
        csvContent,
        'abonos',
        backupDate,
      );

      this.logger.log(
        `Abonos backup completed for ${targetMonth}/${targetYear}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to backup abonos for ${targetMonth}/${targetYear}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Backup manual de ventas del mes anterior
   */
  async backupVentas(year?: number, month?: number): Promise<void> {
    const { year: targetYear, month: targetMonth } =
      year && month ? { year, month } : this.getPreviousMonth();

    this.logger.log(`Starting ventas backup for ${targetMonth}/${targetYear}`);

    try {
      const data = await this.getVentasData(targetYear, targetMonth);
      const csvContent = this.convertVentasToCSV(data);
      const backupDate = `${targetYear}-${targetMonth.toString().padStart(2, '0')}`;

      await this.mailService.sendCsvBackupEmail(
        csvContent,
        'ventas',
        backupDate,
      );

      this.logger.log(
        `Ventas backup completed for ${targetMonth}/${targetYear}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to backup ventas for ${targetMonth}/${targetYear}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Backup manual de control_historico del mes anterior
   */
  async backupControlHistorico(year?: number, month?: number): Promise<void> {
    const { year: targetYear, month: targetMonth } =
      year && month ? { year, month } : this.getPreviousMonth();

    this.logger.log(
      `Starting control_historico backup for ${targetMonth}/${targetYear}`,
    );

    try {
      const data = await this.getControlHistoricoData(targetYear, targetMonth);
      const csvContent = this.convertControlHistoricoToCSV(data);
      const backupDate = `${targetYear}-${targetMonth.toString().padStart(2, '0')}`;

      await this.mailService.sendCsvBackupEmail(
        csvContent,
        'control_historico',
        backupDate,
      );

      this.logger.log(
        `Control historico backup completed for ${targetMonth}/${targetYear}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to backup control_historico for ${targetMonth}/${targetYear}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Obtener datos de abonos del mes especificado
   */
  private async getAbonosData(year: number, month: number): Promise<any[]> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59, 999);

    return await this.database.abonos.findMany({
      where: {
        fecha_abono: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: {
        estudiantes: {
          select: {
            nombre: true,
            celular: true,
            curso: true,
          },
        },
      },
      orderBy: {
        fecha_abono: 'desc',
      },
    });
  }

  /**
   * Obtener datos de ventas del mes especificado
   */
  private async getVentasData(year: number, month: number): Promise<any[]> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59, 999);

    return await this.database.ventas.findMany({
      where: {
        fecha_transaccion: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: {
        estudiantes: {
          select: {
            nombre: true,
            celular: true,
            curso: true,
          },
        },
        productos: {
          select: {
            nombre: true,
            precio: true,
            categoria: true,
          },
        },
        bares: {
          select: {
            nombre: true,
          },
        },
      },
      orderBy: {
        fecha_transaccion: 'desc',
      },
    });
  }

  /**
   * Obtener datos de control_historico del mes especificado
   */
  private async getControlHistoricoData(
    year: number,
    month: number,
  ): Promise<any[]> {
    return await this.database.control_historico.findMany({
      where: {
        n_mes: month,
      },
      include: {
        estudiantes: {
          select: {
            nombre: true,
            celular: true,
            curso: true,
          },
        },
      },
      orderBy: {
        id_estudiante: 'asc',
      },
    });
  }

  /**
   * Convertir datos de abonos a CSV
   */
  private convertAbonosToCSV(data: any[]): string {
    if (!data || data.length === 0) {
      return 'ID,ID_Estudiante,Estudiante,Celular,Curso,Total,Tipo_Abono,Fecha_Abono,Comentario\n';
    }

    const headers =
      'ID,ID_Estudiante,Estudiante,Celular,Curso,Total,Tipo_Abono,Fecha_Abono,Comentario\n';

    const rows = data
      .map((abono) => {
        return [
          abono.id,
          abono.id_estudiante,
          `"${abono.estudiantes?.nombre || ''}"`,
          `"${abono.estudiantes?.celular || ''}"`,
          `"${abono.estudiantes?.curso || ''}"`,
          abono.total,
          `"${abono.tipo_abono}"`,
          abono.fecha_abono.toISOString(),
          `"${abono.comentario || ''}"`,
        ].join(',');
      })
      .join('\n');

    return headers + rows;
  }

  /**
   * Convertir datos de ventas a CSV
   */
  private convertVentasToCSV(data: any[]): string {
    if (!data || data.length === 0) {
      return 'ID,ID_Estudiante,Estudiante,Celular,Curso,ID_Producto,Producto,Precio_Producto,Categoria,Fecha_Transaccion,ID_Bar,Bar,N_Productos,Total\n';
    }

    const headers =
      'ID,ID_Estudiante,Estudiante,Celular,Curso,ID_Producto,Producto,Precio_Producto,Categoria,Fecha_Transaccion,ID_Bar,Bar,N_Productos,Total\n';

    const rows = data
      .map((venta) => {
        return [
          venta.id,
          venta.id_estudiante,
          `"${venta.estudiantes?.nombre || ''}"`,
          `"${venta.estudiantes?.celular || ''}"`,
          `"${venta.estudiantes?.curso || ''}"`,
          venta.id_producto,
          `"${venta.productos?.nombre || ''}"`,
          venta.productos?.precio || '',
          `"${venta.productos?.categoria || ''}"`,
          venta.fecha_transaccion.toISOString(),
          venta.id_bar,
          `"${venta.bares?.nombre || ''}"`,
          venta.n_productos,
          venta.total,
        ].join(',');
      })
      .join('\n');

    return headers + rows;
  }

  /**
   * Convertir datos de control_historico a CSV
   */
  private convertControlHistoricoToCSV(data: any[]): string {
    if (!data || data.length === 0) {
      return 'ID,ID_Estudiante,Estudiante,Celular,Curso,Total_Pendiente_Ult_Mes_Abono,Total_Pendiente_Ult_Mes_Venta,N_Mes\n';
    }

    const headers =
      'ID,ID_Estudiante,Estudiante,Celular,Curso,Total_Pendiente_Ult_Mes_Abono,Total_Pendiente_Ult_Mes_Venta,N_Mes\n';

    const rows = data
      .map((control) => {
        return [
          control.id,
          control.id_estudiante,
          `"${control.estudiantes?.nombre || ''}"`,
          `"${control.estudiantes?.celular || ''}"`,
          `"${control.estudiantes?.curso || ''}"`,
          control.total_pendiente_ult_mes_abono,
          control.total_pendiente_ult_mes_venta,
          control.n_mes,
        ].join(',');
      })
      .join('\n');

    return headers + rows;
  }

  /**
   * Obtener mes anterior
   */
  private getPreviousMonth(): { year: number; month: number } {
    const now = new Date();
    const year =
      now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
    const month = now.getMonth() === 0 ? 12 : now.getMonth();

    return { year, month };
  }

  /**
   * Función auxiliar para crear delays entre operaciones
   */
  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
