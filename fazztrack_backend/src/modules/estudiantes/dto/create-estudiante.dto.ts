import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateEstudianteDto {
  @IsNotEmpty({ message: 'El nombre del estudiante es requerido' })
  @IsString({ message: 'El nombre debe ser una cadena de texto' })
  nombre: string;

  @IsNotEmpty({ message: 'El ID del bar es requerido' })
  @IsNumber({}, { message: 'El ID del bar debe ser un número' })
  id_bar: number;

  @IsOptional()
  @IsString({ message: 'El número de celular debe ser una cadena de texto' })
  celular?: string;

  @IsOptional()
  @IsString({ message: 'El curso debe ser una cadena de texto' })
  curso?: string;

  @IsOptional()
  @IsString({ message: 'El nombre del representante debe ser un string' })
  nombre_representante?: string;
}
