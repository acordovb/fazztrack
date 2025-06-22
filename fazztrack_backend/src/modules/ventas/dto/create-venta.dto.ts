import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsDate,
  IsString,
} from 'class-validator';

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
  fecha_transaccion?: Date;

  @IsNotEmpty({ message: 'El ID del bar es requerido' })
  @IsNumber({}, { message: 'El ID del bar debe ser un string (hasheado)' })
  id_bar: number;

  @IsNotEmpty({ message: 'El número de productos es requerido' })
  @IsNumber({}, { message: 'El número de productos debe ser un número' })
  @IsPositive({ message: 'El número de productos debe ser un valor positivo' })
  n_productos: number;
}
