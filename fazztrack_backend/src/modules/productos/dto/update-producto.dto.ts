import { IsNumber, IsOptional, IsPositive, IsString } from 'class-validator';

export class UpdateProductoDto {
  @IsOptional()
  @IsString({ message: 'El nombre del producto debe ser una cadena de texto' })
  nombre?: string;

  @IsOptional()
  @IsNumber({}, { message: 'El ID del bar debe ser un número' })
  id_bar?: number;

  @IsOptional()
  @IsNumber({}, { message: 'El precio debe ser un número' })
  @IsPositive({ message: 'El precio debe ser un valor positivo' })
  precio?: number;

  @IsOptional()
  @IsString({ message: 'La categoría debe ser una cadena de texto' })
  categoria?: string;
}
