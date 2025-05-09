import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AbonosService } from './abonos.service';
import { CreateAbonoDto, UpdateAbonoDto, AbonoDto } from './dto';

@Controller('abonos')
export class AbonosController {
  constructor(private readonly abonosService: AbonosService) {}

  @Post()
  create(@Body() createAbonoDto: CreateAbonoDto): Promise<AbonoDto> {
    return this.abonosService.create(createAbonoDto);
  }

  @Get()
  findAll(): Promise<AbonoDto[]> {
    return this.abonosService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<AbonoDto> {
    return this.abonosService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateAbonoDto: UpdateAbonoDto,
  ): Promise<AbonoDto> {
    return this.abonosService.update(id, updateAbonoDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.abonosService.remove(id);
  }
}
