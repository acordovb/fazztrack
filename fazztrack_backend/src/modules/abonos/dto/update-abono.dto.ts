import {
  IsOptional,
  IsNumber,
  IsPositive,
  IsString,
  IsDate,
} from 'class-validator';

export class UpdateAbonoDto {
  @IsOptional()
  @IsNumber({}, { message: 'El ID del estudiante debe ser un número' })
  id_estudiante?: number;

  @IsOptional()
  @IsNumber({}, { message: 'El total debe ser un número' })
  @IsPositive({ message: 'El total debe ser un valor positivo' })
  total?: number;

  @IsOptional()
  @IsString({ message: 'El tipo de abono debe ser una cadena de texto' })
  tipo_abono?: string;

  @IsOptional()
  @IsDate({ message: 'La fecha de abono debe ser una fecha válida' })
  fecha_abono?: Date;
}
