import { Controller, Get, Param, Query, Post } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoCronService } from './control-historico-cron.service';
import { ControlHistoricoDto } from './dto';
import { decodeId } from 'src/shared/hashid/hashid.utils';
import { VentasService } from '../ventas/ventas.service';
import { AbonosService } from '../abonos/abonos.service';

@Controller('control-historico')
export class ControlHistoricoController {
  constructor(
    private readonly controlHistoricoService: ControlHistoricoService,
    private readonly controlHistoricoCronService: ControlHistoricoCronService,
    private readonly ventasService: VentasService,
    private readonly abonosService: AbonosService,
  ) {}

  @Get('estudiante/:idEstudiante')
  async findByEstudianteId(
    @Param('idEstudiante') idEstudiante: string,
    @Query('month') month?: number,
  ): Promise<ControlHistoricoDto> {
    const currentMonth =
      month !== undefined ? Number(month) : new Date().getMonth() + 1;

    let controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(
        idEstudiante,
        currentMonth,
      );

    const [totalVentas, totalAbonos] = await Promise.all([
      this.ventasService.calculateTotalVentas(idEstudiante, currentMonth),
      this.abonosService.calculateTotalAbonos(
        decodeId(idEstudiante),
        currentMonth,
      ),
    ]);

    controlHistorico.total_venta = totalVentas;
    controlHistorico.total_abono = totalAbonos;

    return controlHistorico;
  }

  @Post('generate-monthly')
  async generateMonthlyControlHistorico(
    @Query('month') month?: number,
    @Query('year') year?: number,
  ): Promise<{ message: string }> {
    if (month && year) {
      await this.controlHistoricoCronService.executeManually(
        Number(month),
        Number(year),
      );
      return {
        message: `Control histórico generado manualmente para ${month}/${year}`,
      };
    } else {
      await this.controlHistoricoCronService.executeManually();
      return {
        message: 'Control histórico generado manualmente para el mes actual',
      };
    }
  }

  @Post('cleanup-old-data')
  async cleanupOldData(
    @Query('month') month?: number,
    @Query('year') year?: number,
  ): Promise<{ message: string }> {
    if (month && year) {
      await this.controlHistoricoCronService.executeCleanupManually(
        Number(month),
        Number(year),
      );
      return {
        message: `Limpieza de datos ejecutada manualmente para ${month}/${year} (eliminará datos de hace dos meses)`,
      };
    } else {
      await this.controlHistoricoCronService.executeCleanupManually();
      return {
        message:
          'Limpieza de datos ejecutada manualmente (eliminará datos de hace dos meses)',
      };
    }
  }
}
