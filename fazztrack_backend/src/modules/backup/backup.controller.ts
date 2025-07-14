import { Controller, Post, Get, Query, ParseIntPipe } from '@nestjs/common';
import { BackupService } from './backup.service';

@Controller('backup')
export class BackupController {
  constructor(private readonly backupService: BackupService) {}

  /**
   * Ejecutar backup completo manual (abonos, ventas y control_historico del mes anterior)
   */
  @Post('run-monthly')
  async runMonthlyBackup() {
    await this.backupService.runMonthlyBackup();
    return {
      message: 'Backup mensual ejecutado exitosamente',
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Ejecutar backup manual solo de abonos
   * @param year - Año (opcional, por defecto mes anterior)
   * @param month - Mes (opcional, por defecto mes anterior)
   */
  @Post('abonos')
  async backupAbonos(
    @Query('year', ParseIntPipe) year?: number,
    @Query('month', ParseIntPipe) month?: number,
  ) {
    await this.backupService.backupAbonos(year, month);
    return {
      message: `Backup de abonos ejecutado exitosamente${year && month ? ` para ${month}/${year}` : ' para el mes anterior'}`,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Ejecutar backup manual solo de ventas
   * @param year - Año (opcional, por defecto mes anterior)
   * @param month - Mes (opcional, por defecto mes anterior)
   */
  @Post('ventas')
  async backupVentas(
    @Query('year', ParseIntPipe) year?: number,
    @Query('month', ParseIntPipe) month?: number,
  ) {
    await this.backupService.backupVentas(year, month);
    return {
      message: `Backup de ventas ejecutado exitosamente${year && month ? ` para ${month}/${year}` : ' para el mes anterior'}`,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Ejecutar backup manual solo de control_historico
   * @param year - Año (opcional, por defecto mes anterior)
   * @param month - Mes (opcional, por defecto mes anterior)
   */
  @Post('control-historico')
  async backupControlHistorico(
    @Query('year', ParseIntPipe) year?: number,
    @Query('month', ParseIntPipe) month?: number,
  ) {
    await this.backupService.backupControlHistorico(year, month);
    return {
      message: `Backup de control histórico ejecutado exitosamente${year && month ? ` para ${month}/${year}` : ' para el mes anterior'}`,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Obtener información del próximo backup programado
   */
  @Get('status')
  async getBackupStatus() {
    const now = new Date();
    const nextMonth = new Date(
      now.getFullYear(),
      now.getMonth() + 1,
      1,
      1,
      0,
      0,
    );

    return {
      message: 'Estado del sistema de backup',
      next_scheduled_backup: nextMonth.toISOString(),
      cron_expression: '0 1 1 * *', // 1:00 AM del primer día de cada mes
      description:
        'Backup automático ejecutado el primer día de cada mes a la 1:00 AM',
      manual_endpoints: {
        monthly: '/backup/run-monthly',
        abonos: '/backup/abonos?year=2024&month=12',
        ventas: '/backup/ventas?year=2024&month=12',
        control_historico: '/backup/control-historico?year=2024&month=12',
      },
    };
  }
}
