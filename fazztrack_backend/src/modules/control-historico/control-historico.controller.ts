import { Controller, Get, Param, Query } from '@nestjs/common';
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
      month !== undefined ? month : new Date().getMonth() + 1;

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
}
