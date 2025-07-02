import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsDate,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateAbonoDto {
  @IsNotEmpty({ message: 'El ID del estudiante es requerido' })
  @IsNumber({}, { message: 'El ID del estudiante debe ser un número' })
  id_estudiante: number;

  @IsNotEmpty({ message: 'El total del abono es requerido' })
  @IsNumber({}, { message: 'El total debe ser un número' })
  @IsPositive({ message: 'El total debe ser un valor positivo' })
  total: number;

  @IsNotEmpty({ message: 'El ID del bar es requerido' })
  @IsString({ message: 'El tipo de abono debe ser una cadena de texto' })
  tipo_abono: string;

  @IsNotEmpty({ message: 'La fecha de abono es requerida' })
  @IsDate({ message: 'La fecha de abono debe ser una fecha válida' })
  @Transform(({ value }) => (value ? new Date(value) : new Date()))
  fecha_abono: Date;

  @IsOptional()
  @IsString({ message: 'El comentario debe ser una cadena de texto' })
  comentario?: string;
}
