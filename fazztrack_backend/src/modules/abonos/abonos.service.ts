import { Injectable } from '@nestjs/common';
import { decodeId, encodeId } from 'src/shared/hashid/hashid.utils';
import { BaseCrudService } from '../../common/crud/base-crud.service';
import { DatabaseService } from '../../database/database.service';
import { AbonoDto, CreateAbonoDto, UpdateAbonoDto } from './dto';

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
      comentario: model.comentario || '',
    };
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

  async calculateTotalAbonos(
    idEstudiante: number,
    month: number,
  ): Promise<number> {
    const currentYear = new Date().getFullYear();
    const startDate = new Date(currentYear, month - 1, 1);
    const endDate = new Date(currentYear, month, 0, 23, 59, 59, 999);
    const result = await this.database.abonos.aggregate({
      where: {
        id_estudiante: idEstudiante,
        fecha_abono: {
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
}
