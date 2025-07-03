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
    this.processReportsInBackground(reportRequest.studentIds).catch((error) => {
      console.error('Error procesando reportes en background:', error);
    });

    return {
      message:
        'Procesando reportes en background. Se enviarán por correo cuando estén listos.',
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
            this.reportDataProcessorService.processReportData(reportData);
          const filePath =
            await this.pdfGeneratorService.generatePdf(processedData);

          filePaths.push(filePath);
          processedCount++;
          console.log(
            `Reporte ${processedCount}/${studentIds.length} generado: ${filePath}`,
          );
        }
      } catch (error) {
        console.error(
          `Error generando reporte para estudiante ${studentId}:`,
          error,
        );
      }
    }

    console.log(
      `Generación completada. ${processedCount} reportes generados exitosamente.`,
    );

    // Aquí podrías llamar al servicio de correo para enviar los PDFs
    // await this.emailService.sendReports(filePaths);
  }

  async generateAllReports(): Promise<ReportResponseDto> {
    this.processAllReportsInBackground().catch((error) => {
      console.error(
        'Error procesando todos los reportes en background:',
        error,
      );
    });

    const allStudentsData =
      await this.reportDataService.getAllStudentsReportData();

    return {
      message: `Procesando ${allStudentsData.length} reportes en background. Se enviarán por correo cuando estén listos.`,
      filePaths: [],
      studentsProcessed: allStudentsData.length,
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
          this.reportDataProcessorService.processReportData(reportData);
        const filePath =
          await this.pdfGeneratorService.generatePdf(processedData);

        filePaths.push(filePath);
        processedCount++;
        console.log(
          `Reporte ${processedCount}/${allReportsData.length} generado: ${filePath}`,
        );
      } catch (error) {
        console.error(
          `Error generando reporte para estudiante ${reportData.student.nombre}:`,
          error,
        );
      }
    }

    console.log(
      `Generación de TODOS los reportes completada. ${processedCount} reportes generados exitosamente.`,
    );

    // Aquí podrías llamar al servicio de correo para enviar los PDFs
    // await this.emailService.sendAllReports(filePaths);
  }
}
