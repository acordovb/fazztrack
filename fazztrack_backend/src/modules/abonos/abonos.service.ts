import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateAbonoDto, UpdateAbonoDto, AbonoDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class AbonosService extends BaseCrudService<
  AbonoDto,
  CreateAbonoDto,
  UpdateAbonoDto,
  any
> {
  constructor(prisma: PrismaService) {
    super(prisma, 'abonos');
  }

  protected mapToDto(model: any): AbonoDto {
    return {
      id: model.id,
      id_estudiante: model.id_estudiante,
      total: model.total.toNumber(),
      tipo_abono: model.tipo_abono,
      fecha_abono: model.fecha_abono,
    };
  }
}
