import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateBarDto, UpdateBarDto, BarDto } from './dto';

@Injectable()
export class BarsService {
  constructor(private prisma: PrismaService) {}

  async create(createBarDto: CreateBarDto): Promise<BarDto> {
    const bar = await this.prisma.bares.create({
      data: createBarDto,
    });

    return {
      id: bar.id,
      nombre: bar.nombre,
    };
  }

  async findAll(): Promise<BarDto[]> {
    const bars = await this.prisma.bares.findMany();

    return bars.map((bar) => ({
      id: bar.id,
      nombre: bar.nombre,
    }));
  }

  async findOne(id: number): Promise<BarDto> {
    const bar = await this.prisma.bares.findUnique({
      where: { id },
    });

    if (!bar) {
      throw new NotFoundException(`Bar with ID ${id} not found`);
    }

    return {
      id: bar.id,
      nombre: bar.nombre,
    };
  }

  async update(id: number, updateBarDto: UpdateBarDto): Promise<BarDto> {
    try {
      const bar = await this.prisma.bares.update({
        where: { id },
        data: updateBarDto,
      });

      return {
        id: bar.id,
        nombre: bar.nombre,
      };
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Bar with ID ${id} not found`);
      }
      throw error;
    }
  }

  async remove(id: number): Promise<void> {
    try {
      await this.prisma.bares.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Bar with ID ${id} not found`);
      }
      throw error;
    }
  }
}
