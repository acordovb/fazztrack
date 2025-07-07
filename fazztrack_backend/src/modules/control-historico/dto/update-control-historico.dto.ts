import { UpdateDto } from 'src/common/crud/base.interface';
import { IsNumber, IsOptional } from 'class-validator';

export class UpdateControlHistoricoDto implements UpdateDto {
  @IsNumber()
  @IsOptional()
  n_mes?: number;

  @IsNumber()
  @IsOptional()
  total_pendiente_ult_mes_abono?: number;

  @IsNumber()
  @IsOptional()
  total_pendiente_ult_mes_venta?: number;
}
