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
  Query,
} from '@nestjs/common';
import { ProductosService } from './productos.service';
import { CreateProductoDto, UpdateProductoDto, ProductoDto } from './dto';

@Controller('productos')
export class ProductosController {
  constructor(private readonly productosService: ProductosService) {}

  @Post()
  create(@Body() createProductoDto: CreateProductoDto): Promise<ProductoDto> {
    console.log('Creating producto:', createProductoDto);
    return this.productosService.create(createProductoDto);
  }

  @Get()
  findAll(): Promise<ProductoDto[]> {
    return this.productosService.findAll();
  }
  @Get('search')
  search(
    @Query('nombre') nombre?: string,
    @Query('idBar') idBar?: string,
  ): Promise<ProductoDto[]> {
    if (nombre) {
      return this.productosService.searchByNombre(nombre, idBar);
    }
    return this.productosService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<ProductoDto> {
    return this.productosService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateProductoDto: UpdateProductoDto,
  ): Promise<ProductoDto> {
    return this.productosService.update(id, updateProductoDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.productosService.remove(id);
  }
}
