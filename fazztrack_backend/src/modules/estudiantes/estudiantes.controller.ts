import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { EstudiantesService } from './estudiantes.service';
import { CreateEstudianteDto, UpdateEstudianteDto, EstudianteDto } from './dto';

@Controller('estudiantes')
export class EstudiantesController {
  constructor(private readonly estudiantesService: EstudiantesService) {}

  @Post()
  create(
    @Body() createEstudianteDto: CreateEstudianteDto,
  ): Promise<EstudianteDto> {
    return this.estudiantesService.create(createEstudianteDto);
  }

  @Get()
  findAll(): Promise<EstudianteDto[]> {
    return this.estudiantesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number): Promise<EstudianteDto> {
    return this.estudiantesService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateEstudianteDto: UpdateEstudianteDto,
  ): Promise<EstudianteDto> {
    return this.estudiantesService.update(id, updateEstudianteDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.estudiantesService.remove(id);
  }
}
