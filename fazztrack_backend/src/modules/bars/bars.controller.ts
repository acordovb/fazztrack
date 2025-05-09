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
import { BarsService } from './bars.service';
import { CreateBarDto, UpdateBarDto, BarDto } from './dto';

@Controller('bares')
export class BarsController {
  constructor(private readonly barsService: BarsService) {}

  @Post()
  create(@Body() createBarDto: CreateBarDto): Promise<BarDto> {
    return this.barsService.create(createBarDto);
  }

  @Get()
  findAll(): Promise<BarDto[]> {
    return this.barsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<BarDto> {
    return this.barsService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateBarDto: UpdateBarDto,
  ): Promise<BarDto> {
    return this.barsService.update(id, updateBarDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.barsService.remove(id);
  }
}
