import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateEstudianteDto, UpdateEstudianteDto, EstudianteDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';

@Injectable()
export class EstudiantesService extends BaseCrudService<
  EstudianteDto,
  CreateEstudianteDto,
  UpdateEstudianteDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'estudiantes');
  }

  protected mapToDto(model: any): EstudianteDto {
    return {
      id: encodeId(model.id),
      id_bar: encodeId(model.id_bar),
      nombre: model.nombre,
      celular: model.celular,
      curso: model.curso,
      nombre_representante: model.nombre_representante,
      bar: model.bares
        ? {
            id: encodeId(model.bares.id),
            nombre: model.bares.nombre,
          }
        : undefined,
    };
  }

  async findAll(): Promise<EstudianteDto[]> {
    const estudiantes = await this.database.estudiantes.findMany({
      include: {
        bares: true,
      },
    });

    return estudiantes.map((estudiante) => this.mapToDto(estudiante));
  }

  async search(nombre: string, idbar?: string): Promise<EstudianteDto[]> {
    const whereCondition: any = {
      nombre: {
        contains: nombre,
        mode: 'insensitive',
      },
    };

    if (idbar) {
      whereCondition.id_bar = decodeId(idbar);
    }

    const estudiantes = await this.database.estudiantes.findMany({
      where: whereCondition,
      include: {
        bares: true,
      },
    });

    return estudiantes.map((estudiante) => this.mapToDto(estudiante));
  }
}
