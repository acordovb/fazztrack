import { IsNotEmpty, IsString } from 'class-validator';

export class CreateBarDto {
  @IsNotEmpty({ message: 'Bar name is required' })
  @IsString({ message: 'Bar name must be a string' })
  nombre: string;
}
