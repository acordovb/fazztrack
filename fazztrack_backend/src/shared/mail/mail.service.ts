import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

export interface EmailAttachment {
  filename: string;
  content: Buffer | string;
  contentType?: string;
}

export interface SendEmailOptions {
  to: string | string[];
  subject: string;
  html?: string;
  text?: string;
  attachments?: EmailAttachment[];
  from?: string;
}

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private resend: Resend;
  private readonly defaultFromEmail: string;

  constructor(private configService: ConfigService) {
    const resendApiKey = this.configService.get<string>('RESEND_API_KEY');
    if (!resendApiKey) {
      throw new Error('RESEND_API_KEY is not configured');
    }

    this.resend = new Resend(resendApiKey);
    this.defaultFromEmail = 'FazzTrack <no-reply@fazztrack.com>';
  }

  /**
   * Send email with PDF attachments
   * If more than 25 PDFs are provided, it will split them into multiple emails
   */
  async sendEmailWithPDFs(
    to: string | string[],
    subject: string,
    pdfs: EmailAttachment[],
    htmlContent?: string,
    textContent?: string,
    from?: string,
  ): Promise<void> {
    const recipients = Array.isArray(to) ? to : [to];
    const MAX_ATTACHMENTS_PER_EMAIL = 25;

    // Validate PDFs
    const validPdfs = pdfs.filter((pdf) => {
      if (!pdf.filename.toLowerCase().endsWith('.pdf')) {
        this.logger.warn(`Skipping non-PDF file: ${pdf.filename}`);
        return false;
      }
      return true;
    });

    if (validPdfs.length === 0) {
      this.logger.warn('No valid PDF files to send');
      return;
    }

    // Split PDFs into chunks if necessary
    const pdfChunks = this.chunkArray(validPdfs, MAX_ATTACHMENTS_PER_EMAIL);

    this.logger.log(
      `Sending ${validPdfs.length} PDFs in ${pdfChunks.length} email(s) to ${recipients.length} recipient(s)`,
    );

    for (let i = 0; i < pdfChunks.length; i++) {
      const chunk = pdfChunks[i];
      const isMultipart = pdfChunks.length > 1;

      // Modify subject for multi-part emails
      const emailSubject = isMultipart
        ? `${subject} - Parte ${i + 1} de ${pdfChunks.length}`
        : subject;

      // Create email content
      const defaultHtml = this.generateDefaultHtmlContent(
        emailSubject,
        chunk.length,
        isMultipart,
        i + 1,
        pdfChunks.length,
      );

      const defaultText = this.generateDefaultTextContent(
        emailSubject,
        chunk.length,
        isMultipart,
        i + 1,
        pdfChunks.length,
      );

      try {
        await this.sendEmail({
          to: recipients,
          subject: emailSubject,
          html: htmlContent || defaultHtml,
          text: textContent || defaultText,
          attachments: chunk,
          from: from || this.defaultFromEmail,
        });

        this.logger.log(
          `Successfully sent email ${i + 1}/${pdfChunks.length} with ${chunk.length} PDF(s)`,
        );
      } catch (error) {
        this.logger.error(
          `Failed to send email ${i + 1}/${pdfChunks.length}:`,
          error,
        );
        throw error;
      }
    }
  }

  /**
   * Send a single email
   */
  async sendEmail(options: SendEmailOptions): Promise<void> {
    const {
      to,
      subject,
      html,
      text,
      attachments = [],
      from = this.defaultFromEmail,
    } = options;

    try {
      const emailData: any = {
        from,
        to: Array.isArray(to) ? to : [to],
        subject,
      };

      if (html) {
        emailData.html = html;
      }

      if (text) {
        emailData.text = text;
      }

      if (attachments && attachments.length > 0) {
        emailData.attachments = attachments.map((attachment) => ({
          filename: attachment.filename,
          content: attachment.content,
          ...(attachment.contentType && {
            contentType: attachment.contentType,
          }),
        }));
      }

      const result = await this.resend.emails.send(emailData);
      this.logger.log(`Email sent successfully with ID: ${result.data?.id}`);
    } catch (error) {
      this.logger.error('Failed to send email:', error);
      throw error;
    }
  }

  /**
   * Generate default HTML content for PDF emails
   */
  private generateDefaultHtmlContent(
    subject: string,
    pdfCount: number,
    isMultipart: boolean,
    currentPart?: number,
    totalParts?: number,
  ): string {
    const partInfo = isMultipart
      ? `<p style="color: #666; font-size: 14px; margin-bottom: 15px;">
           <strong>Parte ${currentPart} de ${totalParts}</strong>
         </p>`
      : '';

    return `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333; margin-bottom: 20px;">${subject}</h2>
        ${partInfo}
        <div style="background-color: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
          <p style="color: #666; line-height: 1.6; margin: 0;">
            Se adjuntan <strong>${pdfCount} archivo(s) PDF</strong> en este correo.
          </p>
          ${
            isMultipart
              ? `
            <p style="color: #666; line-height: 1.6; margin: 10px 0 0 0;">
              <em>Nota: Debido a la cantidad de archivos, los PDFs se han dividido en ${totalParts} correos separados.</em>
            </p>
          `
              : ''
          }
        </div>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px; text-align: center;">
          Este es un mensaje automático de FazzTrack. Por favor no responda a este correo.
        </p>
      </div>
    `;
  }

  /**
   * Generate default text content for PDF emails
   */
  private generateDefaultTextContent(
    subject: string,
    pdfCount: number,
    isMultipart: boolean,
    currentPart?: number,
    totalParts?: number,
  ): string {
    const partInfo = isMultipart
      ? `Parte ${currentPart} de ${totalParts}\n\n`
      : '';
    const multipartNote = isMultipart
      ? `\n\nNota: Debido a la cantidad de archivos, los PDFs se han dividido en ${totalParts} correos separados.`
      : '';

    return `${subject}\n\n${partInfo}Se adjuntan ${pdfCount} archivo(s) PDF en este correo.${multipartNote}\n\n---\nEste es un mensaje automático de FazzTrack. Por favor no responda a este correo.`;
  }

  /**
   * Utility method to chunk array into smaller arrays
   */
  private chunkArray<T>(array: T[], size: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  }
}
