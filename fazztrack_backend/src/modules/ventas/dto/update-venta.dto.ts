import { IsOptional, IsNumber, IsPositive, IsDate } from 'class-validator';

export class UpdateVentaDto {
  @IsOptional()
  @IsNumber({}, { message: 'El ID del estudiante debe ser un número' })
  id_estudiante?: number;

  @IsOptional()
  @IsNumber({}, { message: 'El ID del producto debe ser un número' })
  id_producto?: number;

  @IsOptional()
  @IsDate({ message: 'La fecha de transacción debe ser una fecha válida' })
  fecha_transaccion?: Date;

  @IsOptional()
  @IsNumber({}, { message: 'El ID del bar debe ser un número' })
  id_bar?: number;

  @IsOptional()
  @IsNumber({}, { message: 'El número de productos debe ser un número' })
  @IsPositive({ message: 'El número de productos debe ser un valor positivo' })
  n_productos?: number;
}
