export class EstudianteDto {
  id: string; // Changed from number to string to store hashed IDs
  nombre: string;
  celular: string | null;
  curso: string | null;
  nombre_representante: string | null;
}
