import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { UpdateControlHistoricoDto } from '../control-historico/dto';
import { AbonosService } from './abonos.service';
import { AbonoDto, CreateAbonoDto, UpdateAbonoDto } from './dto';

@Controller('abonos')
export class AbonosController {
  constructor(private readonly abonosService: AbonosService) {}

  @Post()
  create(
    @Body()
    body: {
      abono: CreateAbonoDto;
      controlHistorico: UpdateControlHistoricoDto & { id_estudiante: number };
    },
  ): Promise<AbonoDto> {
    console.log('Creating new abono with body:', body);
    const { abono, controlHistorico } = body;
    return this.abonosService.newAbono(abono, controlHistorico);
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
