import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { BarsModule } from './modules/bars/bars.module';
import { ProductosModule } from './modules/productos/productos.module';

@Module({
  imports: [PrismaModule, BarsModule, ProductosModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
