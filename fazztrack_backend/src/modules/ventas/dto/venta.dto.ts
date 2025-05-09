export class VentaDto {
  id: string; // Changed from number to string to store hashed IDs
  id_estudiante: number | null;
  id_producto: number | null;
  fecha_transaccion: Date | null;
  id_bar: number | null;
  n_productos: number;
}
