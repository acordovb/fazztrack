import { Controller, Get, Param } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoDto } from './dto';
import { decodeId } from 'src/shared/hashid/hashid.utils';

@Controller('control-historico')
export class ControlHistoricoController {
  constructor(
    private readonly controlHistoricoService: ControlHistoricoService,
  ) {}

  @Get('estudiante/:idEstudiante')
  async findByEstudianteId(
    @Param('idEstudiante') idEstudiante: string,
  ): Promise<ControlHistoricoDto> {
    let controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(idEstudiante);

    if (!controlHistorico) {
      controlHistorico = await this.controlHistoricoService.create({
        id_estudiante: decodeId(idEstudiante),
      });
    }
    return controlHistorico;
  }
}
