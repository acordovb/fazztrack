import { CreateDto } from 'src/common/crud/base.interface';
import { IsNumber, IsPositive } from 'class-validator';

export class CreateControlHistoricoDto implements CreateDto {
  @IsNumber()
  @IsPositive()
  id_estudiante: number;

  @IsNumber()
  total_abono: number;

  @IsNumber()
  total_venta: number;

  @IsNumber()
  total_pendiente_ult_mes_abono: number;

  @IsNumber()
  total_pendiente_ult_mes_venta: number;
}
