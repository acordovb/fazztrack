import { Injectable } from '@nestjs/common';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { DatabaseService } from '../../database/database.service';
import { AbonoDto, CreateAbonoDto, UpdateAbonoDto } from './dto';
import { UpdateControlHistoricoDto } from '../control-historico/dto';

@Injectable()
export class AbonosService extends BaseCrudService<
  AbonoDto,
  CreateAbonoDto,
  UpdateAbonoDto,
  any
> {
  constructor(database: DatabaseService) {
    super(database, 'abonos');
  }

  async newAbono(
    createAbonoDto: CreateAbonoDto,
    controlHistorico: UpdateControlHistoricoDto,
  ): Promise<AbonoDto> {
    const idEstudiante = createAbonoDto.id_estudiante;

    // Convertir fecha_abono a Date si viene como string, o usar la fecha actual
    const fechaAbono = createAbonoDto.fecha_abono
      ? new Date(createAbonoDto.fecha_abono)
      : new Date();

    await this.database.$transaction([
      this.database.abonos.create({
        data: {
          id_estudiante: idEstudiante,
          total: createAbonoDto.total,
          tipo_abono: createAbonoDto.tipo_abono,
          fecha_abono: fechaAbono,
        },
      }),
      this.database.control_historico.updateMany({
        where: { id_estudiante: idEstudiante },
        data: {
          total_abono: controlHistorico.total_abono,
        },
      }),
    ]);
    return this.mapToDto({
      id: createAbonoDto.id_estudiante,
      id_estudiante: createAbonoDto.id_estudiante,
      total: createAbonoDto.total,
      tipo_abono: createAbonoDto.tipo_abono,
      fecha_abono: fechaAbono,
    });
  }

  protected mapToDto(model: any): AbonoDto {
    return {
      id: encodeId(model.id),
      id_estudiante: model.id_estudiante,
      total: model.total,
      tipo_abono: model.tipo_abono,
      fecha_abono: model.fecha_abono,
    };
  }
}
