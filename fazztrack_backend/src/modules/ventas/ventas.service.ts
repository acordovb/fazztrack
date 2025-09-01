import { Injectable } from '@nestjs/common';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { DatabaseService } from '../../database/database.service';
import { CreateVentaDto, UpdateVentaDto, VentaDto } from './dto';

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
      id: encodeId(model.id),
      id_estudiante: encodeId(model.id_estudiante),
      id_producto: encodeId(model.id_producto),
      fecha_transaccion: model.fecha_transaccion,
      id_bar: encodeId(model.id_bar),
      n_productos: model.n_productos,
      total: model.total,
      comentario: model.comentario,
      producto: model.productos
        ? {
            id: encodeId(model.productos.id),
            nombre: model.productos.nombre,
            precio: model.productos.precio,
            idBar: encodeId(model.productos.id_bar),
            categoria: model.productos.categoria,
          }
        : undefined,
    };
  }

  async createBulk(ventas: CreateVentaDto[]): Promise<void> {
    await this.database.ventas.createMany({
      data: ventas,
    });
  }

  async findAllByStudent(
    idStudent: string,
    month: number,
    year: number,
  ): Promise<VentaDto[]> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59, 999);

    const ventas = await this.database.ventas.findMany({
      orderBy: { fecha_transaccion: 'desc' },
      where: {
        id_estudiante: decodeId(idStudent),
        fecha_transaccion: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: {
        productos: true,
      },
    });
    return ventas.map((venta) => this.mapToDto(venta));
  }

  async calculateTotalVentas(
    idEstudiante: number,
    month: number,
    year: number,
  ): Promise<number> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59, 999);
    console.log('Fechas de ventas:', { startDate, endDate });

    const result = await this.database.ventas.aggregate({
      where: {
        id_estudiante: idEstudiante,
        fecha_transaccion: {
          gte: startDate,
          lte: endDate,
        },
      },
      _sum: {
        total: true,
      },
    });

    return result._sum.total?.toNumber() || 0;
  }

  async update(id: string, updateDto: UpdateVentaDto): Promise<VentaDto> {
    const numericId = decodeId(id);

    if (updateDto.fecha_transaccion) {
      const dateString = updateDto.fecha_transaccion.toString();
      updateDto.fecha_transaccion = new Date(
        dateString.endsWith('Z') ? dateString : dateString + 'Z',
      );
    }

    const model = await this.database.ventas.update({
      where: { id: numericId },
      data: updateDto,
      include: {
        productos: true,
      },
    });

    return this.mapToDto(model);
  }
}
