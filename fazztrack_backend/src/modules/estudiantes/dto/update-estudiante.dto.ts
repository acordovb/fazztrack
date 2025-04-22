import { IsOptional, IsString } from 'class-validator';

export class UpdateEstudianteDto {
  @IsOptional()
  @IsString({ message: 'El nombre debe ser una cadena de texto' })
  nombre?: string;

  @IsOptional()
  @IsString({ message: 'El número de celular debe ser una cadena de texto' })
  celular?: string;

  @IsOptional()
  @IsString({ message: 'El curso debe ser una cadena de texto' })
  curso?: string;

  @IsOptional()
  @IsString({
    message: 'El nombre del representante debe ser una cadena de texto',
  })
  nombre_representante?: string;
}
