import { Injectable } from '@nestjs/common';
import { PdfResult } from '../pdf-report/interfaces/pdf-result.interface';

export interface EmailAttachment {
  filename: string;
  content: string;
  encoding: string;
  contentType: string;
}

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  attachments?: EmailAttachment[];
}

@Injectable()
export class EmailService {
  /**
   * Envía un email con un reporte PDF adjunto usando base64
   */
  async sendReportEmail(
    to: string,
    subject: string,
    htmlContent: string,
    pdfAttachment: PdfResult,
  ): Promise<void> {
    const mailOptions: EmailOptions = {
      to,
      subject,
      html: htmlContent,
      attachments: [
        {
          filename: pdfAttachment.filename,
          content: pdfAttachment.base64,
          encoding: 'base64',
          contentType: pdfAttachment.mimeType,
        },
      ],
    };

    // Aquí implementarías tu lógica de envío de email
    // Por ejemplo con nodemailer:
    // await this.mailer.sendMail(mailOptions);

    console.log(
      `Email enviado a ${to} con PDF adjunto: ${pdfAttachment.filename}`,
    );
  }

  /**
   * Envía múltiples reportes en un solo email
   */
  async sendMultipleReportsEmail(
    to: string,
    subject: string,
    htmlContent: string,
    pdfAttachments: PdfResult[],
  ): Promise<void> {
    const attachments = pdfAttachments.map((pdf) => ({
      filename: pdf.filename,
      content: pdf.base64,
      encoding: 'base64',
      contentType: pdf.mimeType,
    }));

    const mailOptions: EmailOptions = {
      to,
      subject,
      html: htmlContent,
      attachments,
    };

    // await this.mailer.sendMail(mailOptions);
    console.log(
      `Email enviado a ${to} con ${pdfAttachments.length} PDFs adjuntos`,
    );
  }
}
