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
    const controlHistorico =
      await this.controlHistoricoService.findByEstudianteId(idEstudiante);

    if (!controlHistorico) {
      throw new NotFoundException(
        `No se encontró historial para el estudiante con ID ${idEstudiante}`,
      );
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
