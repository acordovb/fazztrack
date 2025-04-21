import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { BarsService } from './bars.service';
import { CreateBarDto, UpdateBarDto, BarDto } from './dto';

@Controller('bars')
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
  findOne(@Param('id', ParseIntPipe) id: number): Promise<BarDto> {
    return this.barsService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateBarDto: UpdateBarDto,
  ): Promise<BarDto> {
    return this.barsService.update(id, updateBarDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.barsService.remove(id);
  }
}
