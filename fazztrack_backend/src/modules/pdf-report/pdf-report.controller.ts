import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { PdfReportService } from './pdf-report.service';
import { ReportRequestDto, ReportResponseDto } from './dto';

@Controller('pdf-reports')
export class PdfReportController {
  constructor(private readonly pdfReportService: PdfReportService) {}

  @Post('generate')
  @HttpCode(HttpStatus.OK)
  async generateReports(
    @Body() reportRequest: ReportRequestDto,
  ): Promise<ReportResponseDto> {
    return this.pdfReportService.generateReportsForStudents(reportRequest);
  }

  @Post('generate-all')
  @HttpCode(HttpStatus.OK)
  async generateAllReports(): Promise<ReportResponseDto> {
    return this.pdfReportService.generateAllReports();
  }
}
