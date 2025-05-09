import { NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database/database.service';
import { BaseDto, CreateDto, UpdateDto, PrismaModel } from './base.interface';

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

  async findOne(id: number): Promise<T> {
    const model = await this.database[this.modelName].findUnique({
      where: { id },
    });

    if (!model) {
      throw new NotFoundException(`${this.modelName} with ID ${id} not found`);
    }

    return this.mapToDto(model as M);
  }

  async update(id: number, updateDto: U): Promise<T> {
    try {
      const model = await this.database[this.modelName].update({
        where: { id },
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

  async remove(id: number): Promise<void> {
    try {
      await this.database[this.modelName].delete({
        where: { id },
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
