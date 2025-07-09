import { Module } from '@nestjs/common';
import { PdfReportController } from './pdf-report.controller';
import { PdfReportService } from './pdf-report.service';
import { ReportDataService } from './services/report-data.service';
import { PdfGeneratorService } from './services/pdf-generator.service';
import { ReportDataProcessorService } from './services/report-data-processor.service';
import { EstudiantesModule } from '../estudiantes/estudiantes.module';
import { AbonosModule } from '../abonos/abonos.module';
import { VentasModule } from '../ventas/ventas.module';
import { ControlHistoricoModule } from '../control-historico/control-historico.module';
import { BarsModule } from '../bars/bars.module';
import { MailModule } from '../../shared/mail/mail.module';

@Module({
  imports: [
    EstudiantesModule,
    AbonosModule,
    VentasModule,
    ControlHistoricoModule,
    BarsModule,
    MailModule,
  ],
  controllers: [PdfReportController],
  providers: [
    PdfReportService,
    ReportDataService,
    PdfGeneratorService,
    ReportDataProcessorService,
  ],
  exports: [PdfReportService],
})
export class PdfReportModule {}
