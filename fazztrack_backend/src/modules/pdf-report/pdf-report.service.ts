import { Injectable } from '@nestjs/common';
import { ReportRequestDto, ReportResponseDto } from './dto';
import { ReportDataService } from './services/report-data.service';
import { PdfGeneratorService } from './services/pdf-generator.service';
import { ReportDataProcessorService } from './services/report-data-processor.service';

@Injectable()
export class PdfReportService {
  constructor(
    private readonly reportDataService: ReportDataService,
    private readonly pdfGeneratorService: PdfGeneratorService,
    private readonly reportDataProcessorService: ReportDataProcessorService,
  ) {}

  async generateReportsForStudents(
    reportRequest: ReportRequestDto,
  ): Promise<ReportResponseDto> {
    setImmediate(() => {
      this.processReportsInBackground(reportRequest.studentIds).catch(
        (error) => {
          console.error('Error procesando reportes en background:', error);
        },
      );
    });

    return {
      message:
        'Su solicitud ha sido recibida exitosamente. Los reportes serán generados y enviados a su correo electrónico en los próximos minutos.',
      filePaths: [],
      studentsProcessed: reportRequest.studentIds.length,
    };
  }

  private async processReportsInBackground(
    studentIds: string[],
  ): Promise<void> {
    const filePaths: string[] = [];
    let processedCount = 0;

    for (const studentId of studentIds) {
      try {
        const reportData =
          await this.reportDataService.getReportData(studentId);
        if (reportData) {
          const processedData =
            await this.reportDataProcessorService.processReportData(reportData);
          const filePath =
            await this.pdfGeneratorService.generatePdf(processedData);

          filePaths.push(filePath);
          processedCount++;
        } else {
          console.log(
            `Sin datos para generar reporte del estudiante ${studentId}`,
          );
        }
      } catch (error) {
        console.error(
          `Error generando reporte para estudiante ${studentId}:`,
          error,
        );
      }
    }

    // Aquí podrías llamar al servicio de correo para enviar los PDFs
    // await this.emailService.sendReports(filePaths);
  }

  async generateAllReports(): Promise<ReportResponseDto> {
    setImmediate(() => {
      this.processAllReportsInBackground().catch((error) => {
        console.error(
          'Error procesando todos los reportes en background:',
          error,
        );
      });
    });

    return {
      message:
        'Su solicitud ha sido recibida exitosamente. Los reportes serán generados y enviados a su correo electrónico en los próximos minutos.',
      filePaths: [],
      studentsProcessed: 0,
    };
  }

  private async processAllReportsInBackground(): Promise<void> {
    const allReportsData =
      await this.reportDataService.getAllStudentsReportData();

    const filePaths: string[] = [];
    let processedCount = 0;

    for (const reportData of allReportsData) {
      try {
        const processedData =
          await this.reportDataProcessorService.processReportData(reportData);
        const filePath =
          await this.pdfGeneratorService.generatePdf(processedData);

        filePaths.push(filePath);
        processedCount++;
      } catch (error) {
        console.error(
          `Error generando reporte para estudiante ${reportData.student.nombre}:`,
          error,
        );
      }
    }

    // Aquí podrías llamar al servicio de correo para enviar los PDFs
    // await this.emailService.sendAllReports(filePaths);
  }
}
