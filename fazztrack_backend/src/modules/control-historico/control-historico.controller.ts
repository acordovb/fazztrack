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
    @Query('month') month?: string,
    @Query('year') year?: string,
  ): Promise<ControlHistoricoDto> {
    const monthNumber = month ? parseInt(month) : new Date().getMonth() + 1;
    const yearNumber = year ? parseInt(year) : new Date().getFullYear();

    const idNumberEstudiante = decodeId(idEstudiante);
    let controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(
        idNumberEstudiante,
        monthNumber,
        yearNumber,
      );

    const [totalVentas, totalAbonos] = await Promise.all([
      this.ventasService.calculateTotalVentas(
        idNumberEstudiante,
        monthNumber,
        yearNumber,
      ),
      this.abonosService.calculateTotalAbonos(
        idNumberEstudiante,
        monthNumber,
        yearNumber,
      ),
    ]);

    controlHistorico.total_venta = totalVentas;
    controlHistorico.total_abono = totalAbonos;

    return controlHistorico;
  }
}
