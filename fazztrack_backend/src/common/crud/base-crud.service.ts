import { NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { BaseDto, CreateDto, UpdateDto, PrismaModel } from './base.interface';
import { decodeId } from 'src/shared/hashid/hashid.utils';

export abstract class BaseCrudService<
  T extends BaseDto,
  C extends CreateDto,
  U extends UpdateDto,
  M extends PrismaModel,
> {
  protected constructor(
    protected readonly database: DatabaseService,
    private readonly modelName: string,
  ) {}

  protected abstract mapToDto(model: M): T;

  async create(createDto: C): Promise<T> {
    const model = await this.database[this.modelName].create({
      data: createDto,
    });

    return this.mapToDto(model as M);
  }

  async findAll(): Promise<T[]> {
    const models = await this.database[this.modelName].findMany();

    return models.map((model) => this.mapToDto(model as M));
  }

  async findOne(id: string): Promise<T> {
    const numericId = decodeId(id);

    const model = await this.database[this.modelName].findUnique({
      where: { id: numericId },
    });

    if (!model) {
      throw new NotFoundException(`${this.modelName} with ID ${id} not found`);
    }

    return this.mapToDto(model as M);
  }

  async update(id: string, updateDto: U): Promise<T> {
    try {
      const numericId = decodeId(id);

      const model = await this.database[this.modelName].update({
        where: { id: numericId },
        data: updateDto,
      });

      return this.mapToDto(model as M);
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(
          `${this.modelName} with ID ${id} not found`,
        );
      }
      throw error;
    }
  }

  async remove(id: string): Promise<void> {
    try {
      const numericId = decodeId(id);

      await this.database[this.modelName].delete({
        where: { id: numericId },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(
          `${this.modelName} with ID ${id} not found`,
        );
      }
      throw error;
    }
  }
}
