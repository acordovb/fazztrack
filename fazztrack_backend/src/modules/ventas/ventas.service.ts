import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateVentaDto, UpdateVentaDto, VentaDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class VentasService extends BaseCrudService<
  VentaDto,
  CreateVentaDto,
  UpdateVentaDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'ventas');
  }

  protected mapToDto(model: any): VentaDto {
    return {
      id: model.id,
      id_estudiante: model.id_estudiante,
      id_producto: model.id_producto,
      fecha_transaccion: model.fecha_transaccion,
      id_bar: model.id_bar,
      n_productos: model.n_productos,
    };
  }
}
