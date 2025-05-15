import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  NotFoundException,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import {
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
} from './dto';
import { decodeId } from 'src/shared/hashid/hashid.utils';

@Controller('control-historico')
export class ControlHistoricoController {
  constructor(
    private readonly controlHistoricoService: ControlHistoricoService,
  ) {}

  @Post()
  create(
    @Body() createControlHistoricoDto: CreateControlHistoricoDto,
  ): Promise<ControlHistoricoDto> {
    return this.controlHistoricoService.create(createControlHistoricoDto);
  }

  @Get('estudiante/:idEstudiante')
  async findByEstudianteId(
    @Param('idEstudiante') idEstudiante: string,
  ): Promise<ControlHistoricoDto> {
    let controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(idEstudiante);

    if (!controlHistorico) {
      const newControlHistoricoDto = new CreateControlHistoricoDto();
      newControlHistoricoDto.id_estudiante = decodeId(idEstudiante);
      newControlHistoricoDto.total_abono = 0;
      newControlHistoricoDto.total_venta = 0;
      newControlHistoricoDto.total_pendiente_ult_mes_abono = 0;
      newControlHistoricoDto.total_pendiente_ult_mes_venta = 0;
      controlHistorico = await this.controlHistoricoService.create(
        newControlHistoricoDto,
      );
      if (!controlHistorico) {
        throw new NotFoundException('Control historico not found');
      }
    }
    return controlHistorico;
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateControlHistoricoDto: UpdateControlHistoricoDto,
  ): Promise<ControlHistoricoDto> {
    return this.controlHistoricoService.update(id, updateControlHistoricoDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.controlHistoricoService.remove(id);
  }
}
