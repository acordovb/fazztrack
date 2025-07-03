import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './database/database.module';
import { BarsModule } from './modules/bars/bars.module';
import { ProductosModule } from './modules/productos/productos.module';
import { EstudiantesModule } from './modules/estudiantes/estudiantes.module';
import { AbonosModule } from './modules/abonos/abonos.module';
import { VentasModule } from './modules/ventas/ventas.module';
import { ControlHistoricoModule } from './modules/control-historico/control-historico.module';
import { PdfReportModule } from './modules/pdf-report/pdf-report.module';
import { LoggerModule, LoggerMiddleware } from './common/logger';
import configuration from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    DatabaseModule,
    BarsModule,
    ProductosModule,
    EstudiantesModule,
    AbonosModule,
    VentasModule,
    ControlHistoricoModule,
    PdfReportModule,
    LoggerModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggerMiddleware).forRoutes('*path');
  }
}
