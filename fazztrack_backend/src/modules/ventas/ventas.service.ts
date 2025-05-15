import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { CreateVentaDto, UpdateVentaDto, VentaDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';
import { UpdateControlHistoricoDto } from '../control-historico/dto';

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
    };
  }

  async createBulk(
    ventas: CreateVentaDto[],
    controlHistorico: UpdateControlHistoricoDto & { id_estudiante: string },
  ): Promise<void> {
    const ventasData = ventas.map((venta) => ({
      id_estudiante: decodeId(venta.id_estudiante!),
      id_producto: decodeId(venta.id_producto!),
      fecha_transaccion: venta.fecha_transaccion
        ? new Date(venta.fecha_transaccion)
        : new Date(),
      id_bar: decodeId(venta.id_bar!),
      n_productos: venta.n_productos,
    }));

    // Decodificar el ID del estudiante en el control histórico
    const estudianteId = decodeId(controlHistorico.id_estudiante);

    await this.database.$transaction([
      this.database.ventas.createMany({
        data: ventasData,
      }),
      this.database.control_historico.updateMany({
        where: { id_estudiante: estudianteId },
        data: {
          total_venta: controlHistorico.total_venta,
        },
      }),
    ]);
  }
}
