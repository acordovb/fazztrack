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
import { CreateVentaDto, UpdateVentaDto, VentaDto } from './dto';
import { VentasService } from './ventas.service';

@Controller('ventas')
export class VentasController {
  constructor(private readonly ventasService: VentasService) {}

  @Post('bulk')
  @HttpCode(HttpStatus.NO_CONTENT)
  async createBulk(@Body() body: { ventas: CreateVentaDto[] }): Promise<void> {
    return this.ventasService.createBulk(body.ventas);
  }

  @Get(':idStudent')
  findAllByStudent(
    @Param('idStudent') idStudent: string,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ): Promise<VentaDto[]> {
    const monthNumber = month ? parseInt(month) : new Date().getMonth() + 1;
    const yearNumber = year ? parseInt(year) : new Date().getFullYear();
    return this.ventasService.findAllByStudent(
      idStudent,
      monthNumber,
      yearNumber,
    );
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
