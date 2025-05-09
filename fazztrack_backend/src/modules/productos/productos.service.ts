import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateProductoDto, UpdateProductoDto, ProductoDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { encodeId } from 'src/shared/hashid/hashid.utils';

@Injectable()
export class ProductosService extends BaseCrudService<
  ProductoDto,
  CreateProductoDto,
  UpdateProductoDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'productos');
  }

  protected mapToDto(model: any): ProductoDto {
    return {
      id: encodeId(model.id),
      nombre: model.nombre,
      id_bar: model.id_bar,
      precio: model.precio.toNumber(),
      categoria: model.categoria,
    };
  }
}
