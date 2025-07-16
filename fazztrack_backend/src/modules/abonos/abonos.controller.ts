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
import { AbonosService } from './abonos.service';
import { AbonoDto, CreateAbonoDto, UpdateAbonoDto } from './dto';

@Controller('abonos')
export class AbonosController {
  constructor(private readonly abonosService: AbonosService) {}

  @Post()
  create(@Body() abono: CreateAbonoDto): Promise<AbonoDto> {
    return this.abonosService.create(abono);
  }

  @Get(':idStudent')
  findAllByStudent(
    @Param('idStudent') idStudent: string,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ): Promise<AbonoDto[]> {
    const monthNumber = month ? parseInt(month) : new Date().getMonth() + 1;
    const yearNumber = year ? parseInt(year) : new Date().getFullYear();
    return this.abonosService.findAllByStudent(
      idStudent,
      monthNumber,
      yearNumber,
    );
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
