import { IsOptional, IsString } from 'class-validator';

export class UpdateBarDto {
  @IsOptional()
  @IsString({ message: 'Bar name must be a string' })
  nombre?: string;
}
