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
      total_pendiente_ult_mes_abono:
        model.total_pendiente_ult_mes_abono.toNumber(),
      total_pendiente_ult_mes_venta:
        model.total_pendiente_ult_mes_venta.toNumber(),
      n_mes: model.n_mes,
    };
  }

  async findByEstudianteId(
    idEstudiante: string,
    month: number,
  ): Promise<ControlHistoricoDto> {
    const idNumberEstudiante = decodeId(idEstudiante);
    let monthNumber = month - 1;
    if (monthNumber < 0) {
      monthNumber = 12;
    }
    let controlHistorico = await this.database.control_historico.findFirst({
      where: { id_estudiante: idNumberEstudiante, n_mes: monthNumber },
    });

    if (!controlHistorico) {
      const controlHistoricoNew = new ControlHistoricoDto();
      controlHistoricoNew.id = encodeId(1);
      controlHistoricoNew.id_estudiante = idEstudiante;
      controlHistoricoNew.total_pendiente_ult_mes_abono = 0;
      controlHistoricoNew.total_pendiente_ult_mes_venta = 0;
      controlHistoricoNew.n_mes = month;

      return controlHistoricoNew;
    }

    return this.mapToDto(controlHistorico);
  }

  async findByEstudianteIdAndMonth(
    idEstudiante: number,
    month: number,
  ): Promise<any> {
    return await this.database.control_historico.findFirst({
      where: { id_estudiante: idEstudiante, n_mes: month },
    });
  }
}
