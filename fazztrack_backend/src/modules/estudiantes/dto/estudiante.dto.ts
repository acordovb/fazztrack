import { BarDto } from 'src/modules/bars/dto';

export class EstudianteDto {
  id: string;
  nombre: string;
  id_bar: string;
  celular: string | null;
  curso: string | null;
  nombre_representante: string | null;
  bar?: BarDto;
}
