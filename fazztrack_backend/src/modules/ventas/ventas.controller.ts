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
  Query,
} from '@nestjs/common';
import { CreateVentaDto, VentaDto } from './dto';
import { VentasService } from './ventas.service';

@Controller('ventas')
export class VentasController {
  constructor(private readonly ventasService: VentasService) {}

  @Post('bulk')
  @HttpCode(HttpStatus.NO_CONTENT)
  async createBulk(@Body() ventas: CreateVentaDto[]): Promise<void> {
    return this.ventasService.createBulk(ventas);
  }

  @Get(':idStudent')
  findAllByStudent(
    @Param('idStudent') idStudent: string,
    @Query('mes') mes?: string,
  ): Promise<VentaDto[]> {
    const month = mes ? parseInt(mes) : new Date().getMonth() + 1;
    return this.ventasService.findAllByStudent(idStudent, month);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateVentaDto: CreateVentaDto,
  ): Promise<VentaDto> {
    return this.ventasService.update(id, updateVentaDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.ventasService.remove(id);
  }
}
