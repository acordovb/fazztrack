import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { EstudiantesService } from '../estudiantes/estudiantes.service';
import { ControlHistoricoService } from '../control-historico/control-historico.service';
import { AbonosService } from '../abonos/abonos.service';
import { VentasService } from '../ventas/ventas.service';
import { DatabaseService } from '../../database/database.service';
import { CreateControlHistoricoDto, UpdateControlHistoricoDto } from './dto';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';

@Injectable()
export class ControlHistoricoCronService {
  private readonly logger = new Logger(ControlHistoricoCronService.name);

  constructor(
    private readonly estudiantesService: EstudiantesService,
    private readonly controlHistoricoService: ControlHistoricoService,
    private readonly abonosService: AbonosService,
    private readonly ventasService: VentasService,
    private readonly database: DatabaseService,
  ) {}

  /**
   * Cron job que se ejecuta el primer día de cada mes a las 2:00 AM
   * Genera el control histórico del mes anterior
   */
  @Cron('0 0 2 1 * *', {
    name: 'generate-monthly-control-historico',
    timeZone: 'America/Guayaquil',
  })
  async generateMonthlyControlHistoricoCron() {
    this.logger.log(
      'Ejecutando generación de control histórico del mes anterior...',
    );
    await this.generateMonthlyControlHistorico();
  }

  async generateMonthlyControlHistorico() {
    this.logger.log('Iniciando generación de control histórico mensual...');

    try {
      const now = new Date();
      // Calcular el mes anterior
      let targetMonth = now.getMonth(); // getMonth() devuelve 0-11, así que esto es el mes anterior
      let targetYear = now.getFullYear();

      // Si estamos en enero, el mes anterior es diciembre del año anterior
      if (targetMonth === 0) {
        targetMonth = 12;
        targetYear -= 1;
      }

      this.logger.log(
        `Procesando control histórico para ${targetMonth}/${targetYear} (mes anterior)`,
      );

      // Obtener todos los estudiantes
      const estudiantes = await this.estudiantesService.findAll();
      this.logger.log(`Encontrados ${estudiantes.length} estudiantes`);

      let processedStudents = 0;
      let studentsWithTransactions = 0;

      for (const estudiante of estudiantes) {
        try {
          const estudianteId = decodeId(estudiante.id);

          // Verificar si el estudiante tiene ventas o abonos en el mes objetivo (mes anterior)
          const [totalVentas, totalAbonos] = await Promise.all([
            this.ventasService.calculateTotalVentas(estudiante.id, targetMonth),
            this.abonosService.calculateTotalAbonos(estudianteId, targetMonth),
          ]);

          // Solo procesar estudiantes que tengan transacciones
          if (totalVentas > 0 || totalAbonos > 0) {
            studentsWithTransactions++;

            // Obtener control histórico del mes anterior al que estamos procesando
            const previousMonth = targetMonth === 1 ? 12 : targetMonth - 1;

            const previousControlHistorico =
              await this.controlHistoricoService.findByEstudianteIdAndMonth(
                estudianteId,
                previousMonth,
              );

            let totalPendienteUltMesAbono = 0;
            let totalPendienteUltMesVenta = 0;

            if (previousControlHistorico) {
              totalPendienteUltMesAbono =
                previousControlHistorico.total_pendiente_ult_mes_abono?.toNumber() ||
                0;
              totalPendienteUltMesVenta =
                previousControlHistorico.total_pendiente_ult_mes_venta?.toNumber() ||
                0;
            }

            // Calcular: abonos - ventas + total_pendiente_ult_mes_abono - total_pendiente_ult_mes_venta
            const balance =
              totalAbonos -
              totalVentas +
              totalPendienteUltMesAbono -
              totalPendienteUltMesVenta;

            let newTotalPendienteAbono = 0;
            let newTotalPendienteVenta = 0;

            if (balance > 0) {
              // Excedente positivo -> a favor del estudiante
              newTotalPendienteAbono = balance;
            } else if (balance < 0) {
              // Excedente negativo -> deuda del estudiante
              newTotalPendienteVenta = Math.abs(balance);
            }

            // Verificar si ya existe un control histórico para el mes objetivo
            const existingControlHistorico =
              await this.controlHistoricoService.findByEstudianteIdAndMonth(
                estudianteId,
                targetMonth,
              );

            if (existingControlHistorico) {
              // Actualizar el existente usando el CRUD estándar
              const updateDto: UpdateControlHistoricoDto = {
                total_pendiente_ult_mes_abono: newTotalPendienteAbono,
                total_pendiente_ult_mes_venta: newTotalPendienteVenta,
              };

              await this.controlHistoricoService.update(
                encodeId(existingControlHistorico.id),
                updateDto,
              );
              this.logger.log(
                `Actualizado control histórico para estudiante ${estudiante.nombre} (mes ${targetMonth})`,
              );
            } else {
              // Crear uno nuevo usando el CRUD estándar
              const createDto: CreateControlHistoricoDto = {
                id_estudiante: estudianteId,
                n_mes: targetMonth,
                total_pendiente_ult_mes_abono: newTotalPendienteAbono,
                total_pendiente_ult_mes_venta: newTotalPendienteVenta,
              };

              await this.controlHistoricoService.create(createDto);
              this.logger.log(
                `Creado control histórico para estudiante ${estudiante.nombre} (mes ${targetMonth})`,
              );
            }

            processedStudents++;
          }
        } catch (error) {
          this.logger.error(
            `Error procesando estudiante ${estudiante.nombre}: ${error.message}`,
            error.stack,
          );
        }
      }

      this.logger.log(
        `Control histórico mensual completado. ` +
          `Estudiantes procesados: ${processedStudents}/${studentsWithTransactions} ` +
          `(${studentsWithTransactions} con transacciones de ${estudiantes.length} total)`,
      );
    } catch (error) {
      this.logger.error(
        `Error en la generación de control histórico mensual: ${error.message}`,
        error.stack,
      );
    }
  }

  /**
   * Cron job que se ejecuta el primer día de cada mes a las 3:00 AM
   * Elimina datos de ventas, abonos y control histórico de hace dos meses
   */
  @Cron('0 0 4 1 * *', {
    name: 'cleanup-old-data',
    timeZone: 'America/Guayaquil',
  })
  async cleanupOldData() {
    this.logger.log('Iniciando limpieza de datos antiguos...');

    try {
      const now = new Date();
      const currentMonth = now.getMonth() + 1;
      const currentYear = now.getFullYear();

      // Calcular el mes de hace dos meses
      let targetMonth = currentMonth - 2;
      let targetYear = currentYear;

      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      this.logger.log(
        `Eliminando datos del mes ${targetMonth}/${targetYear} (hace dos meses desde ${currentMonth}/${currentYear})`,
      );

      // Calcular fechas de inicio y fin del mes objetivo
      const startDate = new Date(targetYear, targetMonth - 1, 1);
      const endDate = new Date(targetYear, targetMonth, 0, 23, 59, 59, 999);

      this.logger.log(
        `Período a eliminar: desde ${startDate.toISOString()} hasta ${endDate.toISOString()}`,
      );

      // Eliminar ventas del mes objetivo
      const deletedVentas = await this.database.ventas.deleteMany({
        where: {
          fecha_transaccion: {
            gte: startDate,
            lte: endDate,
          },
        },
      });

      this.logger.log(
        `Eliminadas ${deletedVentas.count} ventas del mes ${targetMonth}/${targetYear}`,
      );

      // Eliminar abonos del mes objetivo
      const deletedAbonos = await this.database.abonos.deleteMany({
        where: {
          fecha_abono: {
            gte: startDate,
            lte: endDate,
          },
        },
      });

      this.logger.log(
        `Eliminados ${deletedAbonos.count} abonos del mes ${targetMonth}/${targetYear}`,
      );

      // Eliminar control histórico del mes objetivo
      const deletedControlHistorico =
        await this.database.control_historico.deleteMany({
          where: {
            n_mes: targetMonth,
          },
        });

      this.logger.log(
        `Eliminados ${deletedControlHistorico.count} registros de control histórico del mes ${targetMonth}/${targetYear}`,
      );

      this.logger.log(
        `Limpieza completada. Total eliminado: ${deletedVentas.count} ventas, ${deletedAbonos.count} abonos, ${deletedControlHistorico.count} controles históricos`,
      );
    } catch (error) {
      this.logger.error(
        `Error en la limpieza de datos antiguos: ${error.message}`,
        error.stack,
      );
    }
  }

  /**
   * Método manual para ejecutar la generación de control histórico
   * (útil para testing o ejecución manual)
   */
  async executeManually(month?: number, year?: number) {
    this.logger.log(
      'Ejecutando generación de control histórico manualmente...',
    );

    if (month && year) {
      const originalDate = new Date();
      // Simular la fecha para el mes/año especificado
      Date.prototype.getMonth = () => month - 1;
      Date.prototype.getFullYear = () => year;

      await this.generateMonthlyControlHistorico();

      // Restaurar Date
      Date.prototype.getMonth = originalDate.getMonth.bind(originalDate);
      Date.prototype.getFullYear = originalDate.getFullYear.bind(originalDate);
    } else {
      await this.generateMonthlyControlHistorico();
    }
  }

  /**
   * Método manual para ejecutar la limpieza de datos antiguos
   * (útil para testing o ejecución manual)
   */
  async executeCleanupManually(month?: number, year?: number) {
    this.logger.log('Ejecutando limpieza de datos manualmente...');

    if (month && year) {
      // Simular la fecha para el mes/año especificado
      const originalDate = new Date();
      Date.prototype.getMonth = () => month - 1;
      Date.prototype.getFullYear = () => year;

      await this.cleanupOldData();

      // Restaurar Date
      Date.prototype.getMonth = originalDate.getMonth.bind(originalDate);
      Date.prototype.getFullYear = originalDate.getFullYear.bind(originalDate);
    } else {
      await this.cleanupOldData();
    }
  }
}
