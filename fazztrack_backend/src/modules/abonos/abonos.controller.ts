import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AbonosService } from './abonos.service';
import { CreateAbonoDto, UpdateAbonoDto, AbonoDto } from './dto';
import { UpdateControlHistoricoDto } from '../control-historico/dto';

@Controller('abonos')
export class AbonosController {
  constructor(private readonly abonosService: AbonosService) {}

  @Post()
  create(
    @Body() createAbonoDto: CreateAbonoDto,
    control_historico: UpdateControlHistoricoDto & { id_estudiante: string },
  ): Promise<AbonoDto> {
    return this.abonosService.newAbono(createAbonoDto, control_historico);
  }

  @Get()
  findAll(): Promise<AbonoDto[]> {
    return this.abonosService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<AbonoDto> {
    return this.abonosService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateAbonoDto: UpdateAbonoDto,
  ): Promise<AbonoDto> {
    return this.abonosService.update(id, updateAbonoDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.abonosService.remove(id);
  }
}
