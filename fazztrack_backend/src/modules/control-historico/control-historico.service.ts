import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import {
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
} from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { encodeId } from 'src/shared/hashid/hashid.utils';
import { VentasService } from '../ventas/ventas.service';
import { AbonosService } from '../abonos/abonos.service';

@Injectable()
export class ControlHistoricoService extends BaseCrudService<
  ControlHistoricoDto,
  CreateControlHistoricoDto,
  UpdateControlHistoricoDto,
  any
> {
  constructor(
    database: DatabaseService,
    private readonly ventasService: VentasService,
    private readonly abonosService: AbonosService,
  ) {
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
    idEstudiante: number,
    month: number,
  ): Promise<ControlHistoricoDto> {
    let monthNumber = month - 1;
    if (monthNumber < 0) {
      monthNumber = 12;
    }
    let controlHistorico = await this.database.control_historico.findFirst({
      where: { id_estudiante: idEstudiante, n_mes: monthNumber },
    });

    if (!controlHistorico) {
      const controlHistoricoCheck = await this.calculateControlHistorico(
        idEstudiante,
        monthNumber,
      );
      if (controlHistoricoCheck) {
        return controlHistoricoCheck;
      }
      const controlHistoricoNew = new ControlHistoricoDto();
      controlHistoricoNew.id = encodeId(1);
      controlHistoricoNew.id_estudiante = encodeId(idEstudiante);
      controlHistoricoNew.total_pendiente_ult_mes_abono = 0;
      controlHistoricoNew.total_pendiente_ult_mes_venta = 0;
      controlHistoricoNew.n_mes = month;

      return controlHistoricoNew;
    }

    return this.mapToDto(controlHistorico);
  }

  async calculateControlHistorico(
    idEstudiante: number,
    month: number,
  ): Promise<ControlHistoricoDto | undefined> {
    const currentDate = new Date();
    const currentMonth = currentDate.getMonth() + 1;

    if (month >= currentMonth) {
      return;
    }

    const [totalVentas, totalAbonos] = await Promise.all([
      this.ventasService.calculateTotalVentas(idEstudiante, month - 1),
      this.abonosService.calculateTotalAbonos(idEstudiante, month - 1),
    ]);
    const totalPendiente = totalAbonos - totalVentas;
    const objCreated = await this.create({
      id_estudiante: idEstudiante,
      total_pendiente_ult_mes_abono: totalPendiente > 0 ? totalPendiente : 0,
      total_pendiente_ult_mes_venta: totalPendiente < 0 ? totalPendiente : 0,
      n_mes: month - 1,
    });
    return this.mapToDto(objCreated);
  }
}
