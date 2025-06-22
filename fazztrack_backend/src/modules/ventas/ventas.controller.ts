import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
} from '@nestjs/common';
import { UpdateControlHistoricoDto } from '../control-historico/dto';
import { CreateVentaDto, VentaDto } from './dto';
import { VentasService } from './ventas.service';

@Controller('ventas')
export class VentasController {
  constructor(private readonly ventasService: VentasService) {}

  @Post('bulk')
  @HttpCode(HttpStatus.NO_CONTENT)
  async createBulk(
    @Body()
    body: {
      ventas: CreateVentaDto[];
      control_historico: UpdateControlHistoricoDto & { id_estudiante: number };
    },
  ): Promise<void> {
    const { ventas, control_historico } = body;
    return this.ventasService.createBulk(ventas, control_historico);
  }

  @Get()
  findAll(): Promise<VentaDto[]> {
    return this.ventasService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<VentaDto> {
    return this.ventasService.findOne(id);
  }
}
