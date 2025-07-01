import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsDate,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateVentaDto {
  @IsNotEmpty({ message: 'El ID del estudiante es requerido' })
  @IsNumber(
    {},
    { message: 'El ID del estudiante debe ser un string (hasheado)' },
  )
  id_estudiante: number;

  @IsNotEmpty({ message: 'El ID del producto es requerido' })
  @IsNumber({}, { message: 'El ID del producto debe ser un string (hasheado)' })
  id_producto: number;

  @IsOptional()
  @IsDate({ message: 'La fecha de transacción debe ser una fecha válida' })
  @Transform(({ value }) => (value ? new Date(value) : new Date()))
  fecha_transaccion?: Date;

  @IsNotEmpty({ message: 'El ID del bar es requerido' })
  @IsNumber({}, { message: 'El ID del bar debe ser un string (hasheado)' })
  id_bar: number;

  @IsNotEmpty({ message: 'El número de productos es requerido' })
  @IsNumber({}, { message: 'El número de productos debe ser un número' })
  @IsPositive({ message: 'El número de productos debe ser un valor positivo' })
  n_productos: number;

  @IsNotEmpty({ message: 'El valor Total es requerido' })
  @IsNumber({}, { message: 'El valor total debe ser un número' })
  @IsPositive({ message: 'El valor total debe ser un valor positivo' })
  total: number;
}
