import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import {
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
} from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';

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
      id_estudiante: encodeId(model.id_estudiante),
      total_abono: model.total_abono.toNumber(),
      total_venta: model.total_venta.toNumber(),
      total_pendiente_ult_mes_abono:
        model.total_pendiente_ult_mes_abono.toNumber(),
      total_pendiente_ult_mes_venta:
        model.total_pendiente_ult_mes_venta.toNumber(),
    };
  }

  async findByEstudianteId(
    idEstudiante: string,
  ): Promise<ControlHistoricoDto | null> {
    const idNumberEstudiante = decodeId(idEstudiante);
    const controlHistorico = await this.database.control_historico.findFirst({
      where: { id_estudiante: idNumberEstudiante },
    });

    if (!controlHistorico) {
      return null;
    }

    return this.mapToDto(controlHistorico);
  }
}
