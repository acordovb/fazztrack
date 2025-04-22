import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { BarsModule } from './modules/bars/bars.module';
import { ProductosModule } from './modules/productos/productos.module';
import { EstudiantesModule } from './modules/estudiantes/estudiantes.module';
import { AbonosModule } from './modules/abonos/abonos.module';
import { VentasModule } from './modules/ventas/ventas.module';
import configuration from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    PrismaModule,
    BarsModule,
    ProductosModule,
    EstudiantesModule,
    AbonosModule,
    VentasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
