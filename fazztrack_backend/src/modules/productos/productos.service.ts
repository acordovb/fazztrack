import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateProductoDto, UpdateProductoDto, ProductoDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { encodeId, decodeId } from 'src/shared/hashid/hashid.utils';

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

  async searchByNombre(nombre: string, idBar?: string): Promise<ProductoDto[]> {
    try {
      const whereClause: any = {
        nombre: {
          contains: nombre,
          mode: 'insensitive',
        },
      };

      if (idBar) {
        const numericBarId = decodeId(idBar);
        whereClause.id_bar = numericBarId;
      }

      const productos = await this.database.productos.findMany({
        where: whereClause,
      });

      return productos.map((producto) => this.mapToDto(producto));
    } catch (error) {
      throw error;
    }
  }
}
