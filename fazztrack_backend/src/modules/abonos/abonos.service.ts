import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateAbonoDto, UpdateAbonoDto, AbonoDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class AbonosService extends BaseCrudService<
  AbonoDto,
  CreateAbonoDto,
  UpdateAbonoDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'abonos');
  }

  protected mapToDto(model: any): AbonoDto {
    return {
      id: model.id,
      id_estudiante: model.id_estudiante,
      total: model.total.toNumber(),
      tipo_abono: model.tipo_abono,
      fecha_abono: model.fecha_abono,
    };
  }
}
