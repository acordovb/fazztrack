import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateProductoDto, UpdateProductoDto, ProductoDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class ProductosService extends BaseCrudService<
  ProductoDto,
  CreateProductoDto,
  UpdateProductoDto,
  any
> {
  constructor(prisma: PrismaService) {
    super(prisma, 'productos');
  }

  protected mapToDto(model: any): ProductoDto {
    return {
      id: model.id,
      nombre: model.nombre,
      id_bar: model.id_bar,
      precio: model.precio.toNumber(),
      categoria: model.categoria,
    };
  }
}
