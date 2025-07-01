import { BaseDto } from '../../../common/crud/base.interface';

export class ControlHistoricoDto implements BaseDto {
  id: string;
  id_estudiante: string;
  total_pendiente_ult_mes_abono: number;
  total_pendiente_ult_mes_venta: number;
  total_ventas?: number;
  total_abonos?: number;
}
