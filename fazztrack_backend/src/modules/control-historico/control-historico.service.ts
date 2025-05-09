import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import {
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
} from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { encodeId } from 'src/shared/hashid/hashid.utils';

@Injectable()
export class ControlHistoricoService extends BaseCrudService<
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'control_historico');
  }

  protected mapToDto(model: any): ControlHistoricoDto {
    return {
      id: encodeId(model.id),
      id_estudiante: model.id_estudiante,
      total_abono: model.total_abono.toNumber(),
      total_venta: model.total_venta.toNumber(),
      total_pendiente_ult_mes_abono:
        model.total_pendiente_ult_mes_abono.toNumber(),
      total_pendiente_ult_mes_venta:
        model.total_pendiente_ult_mes_venta.toNumber(),
    };
  }

  async findByEstudianteId(
    id_estudiante: number,
  ): Promise<ControlHistoricoDto | null> {
    const controlHistorico = await this.database.control_historico.findFirst({
      where: { id_estudiante },
    });

    if (!controlHistorico) {
      return null;
    }

    return this.mapToDto(controlHistorico);
  }
}
