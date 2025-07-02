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
    console.log('Creating abono:', abono);
    return this.abonosService.create(abono);
  }

  @Get(':idStudent')
  findAllByStudent(
    @Param('idStudent') idStudent: string,
    @Query('mes') mes?: string,
  ): Promise<AbonoDto[]> {
    const month = mes ? parseInt(mes) : new Date().getMonth() + 1;
    return this.abonosService.findAllByStudent(idStudent, month);
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
