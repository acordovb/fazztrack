import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateEstudianteDto, UpdateEstudianteDto, EstudianteDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { encodeId } from 'src/shared/hashid/hashid.utils';

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
      nombre: model.nombre,
      celular: model.celular,
      curso: model.curso,
      nombre_representante: model.nombre_representante,
    };
  }
}
