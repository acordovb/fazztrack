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

  protected mapToDto(model: any): AbonoDto {
    return {
      id: encodeId(model.id),
      id_estudiante: encodeId(model.id_estudiante),
      total: model.total,
      tipo_abono: model.tipo_abono,
      fecha_abono: model.fecha_abono,
    };
  }

  async newAbono(
    createAbonoDto: CreateAbonoDto,
    controlHistorico: UpdateControlHistoricoDto,
  ): Promise<AbonoDto> {
    const idEstudiante = createAbonoDto.id_estudiante;

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

  async findAllByStudent(
    idStudent: string,
    month: number,
  ): Promise<AbonoDto[]> {
    const currentYear = new Date().getFullYear();

    const startDate = new Date(currentYear, month - 1, 1);
    const endDate = new Date(currentYear, month, 0, 23, 59, 59, 999);

    const abonos = await this.database.abonos.findMany({
      orderBy: { fecha_abono: 'desc' },
      where: {
        id_estudiante: decodeId(idStudent),
        fecha_abono: {
          gte: startDate,
          lte: endDate,
        },
      },
    });
    return abonos.map((abono) => this.mapToDto(abono));
  }
}
