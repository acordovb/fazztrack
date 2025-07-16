import { Controller, Get, Param, Query, Post } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoDto } from './dto';
import { decodeId } from 'src/shared/hashid/hashid.utils';
import { VentasService } from '../ventas/ventas.service';
import { AbonosService } from '../abonos/abonos.service';

@Controller('control-historico')
export class ControlHistoricoController {
  constructor(
    private readonly controlHistoricoService: ControlHistoricoService,
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
    const idNumberEstudiante = decodeId(idEstudiante);
    let controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(
        idNumberEstudiante,
        currentMonth,
      );

    const [totalVentas, totalAbonos] = await Promise.all([
      this.ventasService.calculateTotalVentas(idNumberEstudiante, currentMonth),
      this.abonosService.calculateTotalAbonos(idNumberEstudiante, currentMonth),
    ]);

    controlHistorico.total_venta = totalVentas;
    controlHistorico.total_abono = totalAbonos;

    return controlHistorico;
  }
}
