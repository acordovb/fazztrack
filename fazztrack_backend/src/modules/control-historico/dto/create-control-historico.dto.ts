import { CreateDto } from 'src/common/crud/base.interface';
import { IsNumber, IsPositive, IsOptional } from 'class-validator';

export class CreateControlHistoricoDto implements CreateDto {
  @IsNumber()
  @IsPositive()
  id_estudiante: number;

  @IsOptional()
  @IsNumber()
  total_pendiente_ult_mes_abono?: number;

  @IsOptional()
  @IsNumber()
  total_pendiente_ult_mes_venta?: number;
}
