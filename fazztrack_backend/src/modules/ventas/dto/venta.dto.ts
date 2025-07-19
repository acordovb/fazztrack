import { ProductoDto } from 'src/modules/productos/dto';

export class VentaDto {
  id: string;
  id_estudiante: string;
  id_producto: string;
  fecha_transaccion: Date;
  id_bar: string;
  n_productos: number;
  total: number;
  comentario?: string;
  producto?: ProductoDto;
}
