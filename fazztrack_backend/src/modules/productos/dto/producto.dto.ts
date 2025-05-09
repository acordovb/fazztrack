export class ProductoDto {
  id: string; // Changed from number to string to store hashed IDs
  nombre: string;
  id_bar?: number | null;
  precio: number;
  categoria?: string | null;
}
