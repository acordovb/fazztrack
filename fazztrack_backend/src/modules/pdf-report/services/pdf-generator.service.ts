import { Injectable } from '@nestjs/common';
import * as puppeteer from 'puppeteer';
import * as fs from 'fs/promises';
import * as path from 'path';
import { ProcessedReportData } from '../interfaces/report-data.interface';
import { PdfResult } from '../interfaces/pdf-result.interface';

@Injectable()
export class PdfGeneratorService {
  private readonly templatePath = path.join(
    __dirname,
    '..',
    'templates',
    'report-template.html',
  );

  /**
   * Genera un PDF en base64 a partir de los datos del reporte (método optimizado)
   */
  async generatePdfBase64(reportData: ProcessedReportData): Promise<PdfResult> {
    const htmlContent = await this.generateHtmlContent(reportData);
    const filename = this.generateFileName(reportData.student.nombre);

    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    try {
      const page = await browser.newPage();
      await page.setContent(htmlContent, { waitUntil: 'networkidle0' });

      const pdfBuffer = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: {
          top: '20px',
          right: '20px',
          bottom: '20px',
          left: '20px',
        },
      });

      return {
        base64: Buffer.from(pdfBuffer).toString('base64'),
        filename,
        mimeType: 'application/pdf',
      };
    } finally {
      await browser.close();
    }
  }

  /**
   * Genera el contenido HTML reemplazando los placeholders del template
   */
  private async generateHtmlContent(
    data: ProcessedReportData,
  ): Promise<string> {
    let template = await fs.readFile(this.templatePath, 'utf-8');

    // Reemplazar placeholders básicos
    template = template.replace(/{{studentName}}/g, data.student.nombre);
    template = template.replace(/{{currentMonthName}}/g, data.currentMonthName);
    template = template.replace(
      /{{currentYear}}/g,
      data.currentYear.toString(),
    );
    template = template.replace(/{{currentDate}}/g, data.currentDate);
    template = template.replace(/{{currentTime}}/g, data.currentTime);
    template = template.replace(
      /{{totalAbonos}}/g,
      data.totalAbonos.toFixed(2),
    );
    template = template.replace(
      /{{totalVentas}}/g,
      data.totalVentas.toFixed(2),
    );
    template = template.replace(
      /{{saldoPendienteMesAnterior}}/g,
      data.saldoPendienteMesAnterior.toFixed(2),
    );
    template = template.replace(
      /{{saldoPendienteMesAnteriorAbs}}/g,
      Math.abs(data.saldoPendienteMesAnterior).toFixed(2),
    );
    template = template.replace(
      /{{saldoPendienteSign}}/g,
      data.saldoPendienteMesAnterior >= 0 ? '+' : '-',
    );
    template = template.replace(
      /{{saldoPendienteLabel}}/g,
      data.saldoPendienteMesAnterior >= 0
        ? 'Saldo a favor del mes anterior'
        : 'Saldo pendiente del mes anterior',
    );
    template = template.replace(
      /{{saldoActual}}/g,
      data.saldoActual.toFixed(2),
    );
    template = template.replace(
      /{{saldoActualLabel}}/g,
      data.saldoActual >= 0 ? 'Saldo a favor' : 'Valor pendiente de pago',
    );

    // Reemplazar información del rango de fechas
    template = template.replace(/{{reportDateRange}}/g, data.reportDateRange);

    // Reemplazar información del bar si está disponible
    const barInfo = data.barName
      ? `<div class="info-row"><span class="info-label">Bar:</span><span class="info-value">${data.barName}</span></div>`
      : '';
    template = template.replace(/{{barInfo}}/g, barInfo);

    // Reemplazar información condicional del estudiante
    template = this.replaceStudentInfo(template, data);

    // Reemplazar clases CSS para saldos
    template = template.replace(
      /{{saldoPendienteClass}}/g,
      data.saldoPendienteMesAnterior >= 0 ? 'positive' : 'negative',
    );
    template = template.replace(
      /{{saldoActualClass}}/g,
      data.saldoActual >= 0 ? 'positive' : 'negative',
    );

    // Reemplazar secciones de abonos y ventas
    template = template.replace(
      /{{abonosSection}}/g,
      this.generateAbonosSection(data.abonos),
    );
    template = template.replace(
      /{{ventasSection}}/g,
      this.generateVentasSection(data.ventas),
    );

    return template;
  }

  /**
   * Reemplaza la información condicional del estudiante
   */
  private replaceStudentInfo(
    template: string,
    data: ProcessedReportData,
  ): string {
    const studentCourse = data.student.curso
      ? `<div class="info-row"><span class="info-label">Curso:</span><span class="info-value">${data.student.curso}</span></div>`
      : '';

    const studentPhone = data.student.celular
      ? `<div class="info-row"><span class="info-label">Celular:</span><span class="info-value">${data.student.celular}</span></div>`
      : '';

    const studentRepresentative = data.student.nombre_representante
      ? `<div class="info-row"><span class="info-label">Representante:</span><span class="info-value">${data.student.nombre_representante}</span></div>`
      : '';

    template = template.replace(/{{studentCourse}}/g, studentCourse);
    template = template.replace(/{{studentPhone}}/g, studentPhone);
    template = template.replace(
      /{{studentRepresentative}}/g,
      studentRepresentative,
    );

    return template;
  }

  /**
   * Genera la sección HTML de abonos
   */
  private generateAbonosSection(abonos: any[]): string {
    if (abonos.length === 0) {
      return '<div class="no-data">No hay abonos registrados en este mes</div>';
    }

    const rows = abonos
      .map(
        (abono) => `
      <tr>
        <td class="date">${new Date(abono.fecha_abono).toLocaleDateString('es-ES')}</td>
        <td>${abono.tipo_abono}</td>
        <td>${abono.comentario || '-'}</td>
        <td class="amount-cell positive">$${abono.total.toFixed(2)}</td>
      </tr>
    `,
      )
      .join('');

    return `
      <table class="table-content">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Tipo de Abono</th>
            <th>Comentario</th>
            <th>Monto</th>
          </tr>
        </thead>
        <tbody>
          ${rows}
        </tbody>
      </table>
    `;
  }

  /**
   * Genera la sección HTML de ventas
   */
  private generateVentasSection(ventas: any[]): string {
    if (ventas.length === 0) {
      return '<div class="no-data">No hay ventas registradas en este mes</div>';
    }

    const rows = ventas
      .map(
        (venta) => `
      <tr>
        <td class="date">${new Date(venta.fecha_transaccion).toLocaleDateString('es-ES')}</td>
        <td>${venta.producto?.nombre || 'Producto no disponible'}</td>
        <td>${venta.n_productos}</td>
        <td class="amount-cell negative">$${venta.total.toFixed(2)}</td>
      </tr>
    `,
      )
      .join('');

    return `
      <table class="table-content">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          ${rows}
        </tbody>
      </table>
    `;
  }

  /**
   * Genera el nombre del archivo PDF
   */
  private generateFileName(studentName: string): string {
    const cleanName = studentName.replace(/\s+/g, '_');
    return `reporte_${cleanName}_${Date.now()}.pdf`;
  }
}
