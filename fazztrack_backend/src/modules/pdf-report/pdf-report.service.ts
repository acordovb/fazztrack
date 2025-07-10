import { Injectable, Logger } from '@nestjs/common';
import { ReportRequestDto, ReportResponseDto } from './dto';
import { ReportDataService } from './services/report-data.service';
import { PdfGeneratorService } from './services/pdf-generator.service';
import { ReportDataProcessorService } from './services/report-data-processor.service';
import { MailService } from '../../shared/mail/mail.service';
import { PdfResult } from './interfaces/pdf-result.interface';

@Injectable()
export class PdfReportService {
  private readonly logger = new Logger(PdfReportService.name);

  constructor(
    private readonly reportDataService: ReportDataService,
    private readonly pdfGeneratorService: PdfGeneratorService,
    private readonly reportDataProcessorService: ReportDataProcessorService,
    private readonly mailService: MailService,
  ) {}

  async generateReportsForStudents(
    reportRequest: ReportRequestDto,
  ): Promise<ReportResponseDto> {
    this.logger.log(
      `Starting report generation for ${reportRequest.studentIds.length} students`,
    );

    setImmediate(() => {
      this.processReportsInBackground(reportRequest.studentIds).catch(
        (error) => {
          this.logger.error('Error procesando reportes en background:', error);
        },
      );
    });

    return {
      message:
        'Su solicitud ha sido recibida exitosamente. Los reportes serán generados y enviados a su correo electrónico en los próximos minutos.',
    };
  }

  private async processReportsInBackground(
    studentIds: string[],
  ): Promise<void> {
    const startTime = Date.now();
    this.logger.log(
      `Starting background processing for ${studentIds.length} student reports`,
    );

    const pdfResults: PdfResult[] = [];
    const studentNames: string[] = [];
    let processedCount = 0;
    let skippedCount = 0;

    try {
      // Process reports with better concurrency control
      const BATCH_SIZE = 5; // Process 5 reports at a time to avoid overwhelming the system

      for (let i = 0; i < studentIds.length; i += BATCH_SIZE) {
        const batch = studentIds.slice(i, i + BATCH_SIZE);

        const batchPromises = batch.map(async (studentId) => {
          try {
            const reportData =
              await this.reportDataService.getReportData(studentId);
            if (reportData) {
              const processedData =
                await this.reportDataProcessorService.processReportData(
                  reportData,
                );
              // Use optimized base64 method
              const pdfResult =
                await this.pdfGeneratorService.generatePdfBase64(processedData);
              return { pdfResult, studentName: reportData.student.nombre };
            } else {
              this.logger.warn(
                `Sin datos para generar reporte del estudiante ${studentId}`,
              );
              return null;
            }
          } catch (error) {
            this.logger.error(
              `Error generando reporte para estudiante ${studentId}:`,
              error,
            );
            return null;
          }
        });

        const batchResults = await Promise.allSettled(batchPromises);

        batchResults.forEach((result) => {
          if (result.status === 'fulfilled' && result.value) {
            pdfResults.push(result.value.pdfResult);
            studentNames.push(result.value.studentName);
            processedCount++;
          } else {
            skippedCount++;
          }
        });

        this.logger.log(
          `Processed batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(studentIds.length / BATCH_SIZE)}: ${processedCount} successful, ${skippedCount} skipped`,
        );
      }

      // Send emails with PDFs if any were generated
      if (pdfResults.length > 0) {
        await this.sendReportsViaEmailOptimized(
          pdfResults,
          `Reportes de Estudiantes - ${processedCount} reportes generados`,
          studentNames,
        );

        const duration = Date.now() - startTime;
        this.logger.log(
          `Successfully processed and sent ${processedCount} student reports in ${Math.round(duration / 1000)}s (${skippedCount} skipped)`,
        );
      } else {
        this.logger.warn('No reports were generated to send');
      }
    } catch (error) {
      this.logger.error('Error in background report processing:', error);
    }
  }

  async generateAllReports(): Promise<ReportResponseDto> {
    this.logger.log('Starting report generation for all students');

    setImmediate(() => {
      this.processAllReportsInBackground().catch((error) => {
        this.logger.error(
          'Error procesando todos los reportes en background:',
          error,
        );
      });
    });

    return {
      message:
        'Su solicitud ha sido recibida exitosamente. Los reportes serán generados y enviados a su correo electrónico en los próximos minutos.',
    };
  }

  private async processAllReportsInBackground(): Promise<void> {
    const startTime = Date.now();
    this.logger.log('Starting background processing for all student reports');

    const pdfResults: PdfResult[] = [];
    const studentNames: string[] = [];
    let processedCount = 0;
    let skippedCount = 0;

    try {
      const allReportsData =
        await this.reportDataService.getAllStudentsReportData();
      this.logger.log(`Retrieved data for ${allReportsData.length} students`);

      // Process reports with better concurrency control
      const BATCH_SIZE = 5; // Process 5 reports at a time

      for (let i = 0; i < allReportsData.length; i += BATCH_SIZE) {
        const batch = allReportsData.slice(i, i + BATCH_SIZE);

        const batchPromises = batch.map(async (reportData) => {
          try {
            const processedData =
              await this.reportDataProcessorService.processReportData(
                reportData,
              );
            // Use optimized base64 method
            const pdfResult =
              await this.pdfGeneratorService.generatePdfBase64(processedData);
            return { pdfResult, studentName: reportData.student.nombre };
          } catch (error) {
            this.logger.error(
              `Error generando reporte para estudiante ${reportData.student.nombre}:`,
              error,
            );
            return null;
          }
        });

        const batchResults = await Promise.allSettled(batchPromises);

        batchResults.forEach((result) => {
          if (result.status === 'fulfilled' && result.value) {
            pdfResults.push(result.value.pdfResult);
            studentNames.push(result.value.studentName);
            processedCount++;
          } else {
            skippedCount++;
          }
        });

        this.logger.log(
          `Processed batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(allReportsData.length / BATCH_SIZE)}: ${processedCount} successful, ${skippedCount} skipped`,
        );
      }

      // Send emails with PDFs if any were generated
      if (pdfResults.length > 0) {
        await this.sendReportsViaEmailOptimized(
          pdfResults,
          `Reportes de Todos los Estudiantes - ${processedCount} reportes generados`,
          studentNames,
        );

        const duration = Date.now() - startTime;
        this.logger.log(
          `Successfully processed and sent ${processedCount} reports for all students in ${Math.round(duration / 1000)}s (${skippedCount} skipped)`,
        );
      } else {
        this.logger.warn('No reports were generated to send');
      }
    } catch (error) {
      this.logger.error('Error in background all reports processing:', error);
    }
  }

  /**
   * Send reports via email with PDF attachments using base64 (OPTIMIZED)
   */
  private async sendReportsViaEmailOptimized(
    pdfResults: PdfResult[],
    subject: string,
    studentNames?: string[],
  ): Promise<void> {
    try {
      // Use the optimized mail service method with base64
      await this.mailService.sendEmailWithPdfResults(
        subject,
        pdfResults,
        undefined,
        undefined,
        studentNames,
      );

      this.logger.log(
        `Email sent successfully with ${pdfResults.length} PDF attachments using optimized base64 method`,
      );
    } catch (error) {
      this.logger.error('Failed to send reports via email:', error);
      throw error;
    }
  }
}
