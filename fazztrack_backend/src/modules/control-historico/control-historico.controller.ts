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
      controlHistorico = await this.controlHistoricoService.create({
        id_estudiante: decodeId(idEstudiante),
      });
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
