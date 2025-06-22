import { Injectable } from '@nestjs/common';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { DatabaseService } from '../../database/database.service';
import { UpdateControlHistoricoDto } from '../control-historico/dto';
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
    };
  }

  async createBulk(
    ventas: CreateVentaDto[],
    controlHistorico: UpdateControlHistoricoDto & { id_estudiante: number },
  ): Promise<void> {
    const ventasData = ventas.map((venta) => ({
      id_estudiante: venta.id_estudiante,
      id_producto: venta.id_producto,
      fecha_transaccion: venta.fecha_transaccion
        ? new Date(venta.fecha_transaccion)
        : new Date(),
      id_bar: venta.id_bar,
      n_productos: venta.n_productos,
    }));

    const estudianteId = controlHistorico.id_estudiante;

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
