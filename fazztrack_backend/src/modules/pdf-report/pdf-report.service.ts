import { Injectable, Logger } from '@nestjs/common';
import { unlink } from 'fs/promises';
import { basename } from 'path';
import { ReportRequestDto, ReportResponseDto } from './dto';
import { ReportDataService } from './services/report-data.service';
import { PdfGeneratorService } from './services/pdf-generator.service';
import { ReportDataProcessorService } from './services/report-data-processor.service';
import { MailService } from '../../shared/mail/mail.service';

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
      filePaths: [],
      studentsProcessed: reportRequest.studentIds.length,
    };
  }

  private async processReportsInBackground(
    studentIds: string[],
  ): Promise<void> {
    const startTime = Date.now();
    this.logger.log(
      `Starting background processing for ${studentIds.length} student reports`,
    );

    const filePaths: string[] = [];
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
              const filePath =
                await this.pdfGeneratorService.generatePdf(processedData);
              return filePath;
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
            filePaths.push(result.value);
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
      if (filePaths.length > 0) {
        await this.sendReportsViaEmail(
          filePaths,
          `Reportes de Estudiantes - ${processedCount} reportes generados`,
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
      // Clean up any generated files even if email sending failed
      await this.cleanupPdfFiles(filePaths);
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
      filePaths: [],
      studentsProcessed: 0,
    };
  }

  private async processAllReportsInBackground(): Promise<void> {
    const startTime = Date.now();
    this.logger.log('Starting background processing for all student reports');

    const filePaths: string[] = [];
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
            const filePath =
              await this.pdfGeneratorService.generatePdf(processedData);
            return filePath;
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
            filePaths.push(result.value);
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
      if (filePaths.length > 0) {
        await this.sendReportsViaEmail(
          filePaths,
          `Reportes de Todos los Estudiantes - ${processedCount} reportes generados`,
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
      // Clean up any generated files even if email sending failed
      await this.cleanupPdfFiles(filePaths);
    }
  }

  /**
   * Send reports via email with PDF attachments
   */
  private async sendReportsViaEmail(
    filePaths: string[],
    subject: string,
  ): Promise<void> {
    try {
      // Use the optimized mail service method
      await this.mailService.sendEmailWithPDFFiles(subject, filePaths);

      this.logger.log(
        `Email sent successfully with ${filePaths.length} PDF attachments`,
      );

      // Clean up PDF files after successful email sending
      await this.cleanupPdfFiles(filePaths);
    } catch (error) {
      this.logger.error('Failed to send reports via email:', error);
      // Still try to clean up files even if email failed
      await this.cleanupPdfFiles(filePaths);
      throw error;
    }
  }

  /**
   * Clean up generated PDF files
   */
  private async cleanupPdfFiles(filePaths: string[]): Promise<void> {
    if (filePaths.length === 0) {
      return;
    }

    const cleanupPromises = filePaths.map(async (filePath) => {
      try {
        await unlink(filePath);
        this.logger.log(`Successfully deleted PDF file: ${basename(filePath)}`);
      } catch (error) {
        this.logger.warn(
          `Failed to delete PDF file ${basename(filePath)}:`,
          error,
        );
      }
    });

    await Promise.allSettled(cleanupPromises);
    this.logger.log(`Cleanup completed for ${filePaths.length} PDF files`);
  }
}
