import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEstudianteDto, UpdateEstudianteDto, EstudianteDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class EstudiantesService extends BaseCrudService<
  EstudianteDto,
  CreateEstudianteDto,
  UpdateEstudianteDto,
  any
> {
  constructor(prisma: PrismaService) {
    super(prisma, 'estudiantes');
  }

  protected mapToDto(model: any): EstudianteDto {
    return {
      id: model.id,
      nombre: model.nombre,
      celular: model.celular,
      curso: model.curso,
      nombre_representante: model.nombre_representante,
    };
  }
}
