import { IsArray, IsString, ArrayNotEmpty } from 'class-validator';

export class ReportRequestDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  studentIds: string[];
}
