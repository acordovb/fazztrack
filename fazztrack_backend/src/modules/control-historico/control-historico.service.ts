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
      n_year: model.n_year,
    };
  }

  async findByEstudianteId(
    idEstudiante: number,
    month: number,
    year: number,
  ): Promise<ControlHistoricoDto> {
    // Aqui ya se resta para el mes que se busca, es decir
    // si se busca el control historico de Julio quiere decir que es el de Junio
    // porque el control historico se calcula al final del mes y depende del anterior.
    const monthNumber = month > 1 ? month - 1 : 12;

    let controlHistorico = await this.database.control_historico.findFirst({
      where: { id_estudiante: idEstudiante, n_mes: monthNumber, n_year: year },
    });

    if (!controlHistorico) {
      const controlHistoricoCheck = await this.calculateControlHistorico(
        idEstudiante,
        monthNumber,
        year,
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
      controlHistoricoNew.n_year = year;

      return controlHistoricoNew;
    }

    return this.mapToDto(controlHistorico);
  }

  async calculateControlHistorico(
    idEstudiante: number,
    month: number,
    year: number,
  ): Promise<ControlHistoricoDto | undefined> {
    const now = new Date();
    const currentMonth = now.getMonth() + 1;
    const currentYear = now.getFullYear();

    if (year > currentYear || (year === currentYear && month >= currentMonth)) {
      return;
    }

    const [totalVentas, totalAbonos] = await Promise.all([
      this.ventasService.calculateTotalVentas(idEstudiante, month, year),
      this.abonosService.calculateTotalAbonos(idEstudiante, month, year),
    ]);
    const totalPendiente = totalAbonos - totalVentas;
    const objCreated = await this.create({
      id_estudiante: idEstudiante,
      total_pendiente_ult_mes_abono: totalPendiente > 0 ? totalPendiente : 0,
      total_pendiente_ult_mes_venta: totalPendiente < 0 ? totalPendiente : 0,
      n_mes: month,
      n_year: year,
    });
    return this.mapToDto(objCreated);
  }
}
