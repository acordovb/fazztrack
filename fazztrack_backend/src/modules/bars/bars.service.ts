import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateBarDto, UpdateBarDto, BarDto } from './dto';
import { BaseCrudService } from '../../common/crud/base-crud.service';

@Injectable()
export class BarsService extends BaseCrudService<
  BarDto,
  CreateBarDto,
  UpdateBarDto,
  any
> {
  constructor(prisma: PrismaService) {
    super(prisma, 'bares');
  }

  protected mapToDto(model: any): BarDto {
    return {
      id: model.id,
      nombre: model.nombre,
    };
  }
}
