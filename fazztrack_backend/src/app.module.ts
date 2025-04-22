import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { BarsModule } from './modules/bars/bars.module';
import { ProductosModule } from './modules/productos/productos.module';
import { EstudiantesModule } from './modules/estudiantes/estudiantes.module';
import { AbonosModule } from './modules/abonos/abonos.module';
import { VentasModule } from './modules/ventas/ventas.module';
import { LoggerModule, LoggerMiddleware } from './common/logger';
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
    LoggerModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // Apply the LoggerMiddleware to all routes
    consumer.apply(LoggerMiddleware).forRoutes('*');
  }
}
