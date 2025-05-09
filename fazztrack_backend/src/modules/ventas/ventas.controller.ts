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
import { VentasService } from './ventas.service';
import { CreateVentaDto, UpdateVentaDto, VentaDto } from './dto';

@Controller('ventas')
export class VentasController {
  constructor(private readonly ventasService: VentasService) {}

  @Post()
  create(@Body() createVentaDto: CreateVentaDto): Promise<VentaDto> {
    return this.ventasService.create(createVentaDto);
  }

  @Get()
  findAll(): Promise<VentaDto[]> {
    return this.ventasService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<VentaDto> {
    return this.ventasService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateVentaDto: UpdateVentaDto,
  ): Promise<VentaDto> {
    return this.ventasService.update(id, updateVentaDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.ventasService.remove(id);
  }
}
