import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

export interface EmailAttachment {
  filename: string;
  content: Buffer | string;
  contentType?: string;
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
    this.defaultFromEmail = 'Fazztrack System Backup <fazztrack@resend.dev>';
  }

  /**
   * Send email with CSV backup
   * This method sends a CSV backup of a database table
   */
  async sendCsvBackupEmail(
    csvContent: string,
    tableName: string,
    backupDate: string = new Date().toISOString().split('T')[0],
  ): Promise<void> {
    try {
      const filename = `${tableName}_backup_${backupDate}.csv`;
      const csvBuffer = Buffer.from(csvContent, 'utf-8');

      // Validate file size (25MB limit)
      const maxSize = 25 * 1024 * 1024;
      if (csvBuffer.length > maxSize) {
        this.logger.warn(
          `CSV backup file is too large (${Math.round(csvBuffer.length / 1024 / 1024)}MB), cannot send`,
        );
        throw new Error('CSV backup file is too large to send via email');
      }

      const attachment: EmailAttachment = {
        filename,
        content: csvBuffer,
        contentType: 'text/csv',
      };

      const subject = `Backup de Base de Datos - ${tableName} - ${backupDate}`;
      const htmlContent = this.generateCsvBackupHtmlContent(
        tableName,
        backupDate,
      );
      const textContent = this.generateCsvBackupTextContent(
        tableName,
        backupDate,
      );

      await this.sendSingleEmail(subject, htmlContent, textContent, [
        attachment,
      ]);

      this.logger.log(
        `Successfully sent CSV backup email for table: ${tableName}`,
      );
    } catch (error) {
      this.logger.error('Failed to send CSV backup email:', error);
      throw error;
    }
  }

  /**
   * Generate HTML content for CSV backup emails
   */
  private generateCsvBackupHtmlContent(
    tableName: string,
    backupDate: string,
  ): string {
    return `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333; margin-bottom: 20px;">Backup de Base de Datos - ${tableName}</h2>
        
        <div style="background-color: #e8f5e8; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #4CAF50;">
          <h3 style="color: #2E7D32; margin: 0 0 15px 0; font-size: 16px;">Información del Backup:</h3>
          <ul style="margin: 0; padding-left: 20px; color: #666;">
            <li style="margin-bottom: 5px;"><strong>Tabla:</strong> ${tableName}</li>
            <li style="margin-bottom: 5px;"><strong>Fecha:</strong> ${backupDate}</li>
            <li style="margin-bottom: 5px;"><strong>Formato:</strong> CSV</li>
          </ul>
        </div>
        
        <div style="background-color: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
          <p style="color: #666; line-height: 1.6; margin: 0;">
            Se adjunta el archivo CSV con el backup completo de la tabla <strong>${tableName}</strong> de la base de datos.
          </p>
          <p style="color: #666; line-height: 1.6; margin: 10px 0 0 0;">
            Este backup fue generado automáticamente el ${backupDate}.
          </p>
        </div>
        
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px; text-align: center;">
          Este es un mensaje automático de FazzTrack. Por favor no responda a este correo.
        </p>
      </div>
    `;
  }

  /**
   * Generate text content for CSV backup emails
   */
  private generateCsvBackupTextContent(
    tableName: string,
    backupDate: string,
  ): string {
    return `Backup de Base de Datos - ${tableName}

INFORMACIÓN DEL BACKUP:
- Tabla: ${tableName}
- Fecha: ${backupDate}
- Formato: CSV

Se adjunta el archivo CSV con el backup completo de la tabla ${tableName} de la base de datos.
Este backup fue generado automáticamente el ${backupDate}.

---
Este es un mensaje automático de FazzTrack. Por favor no responda a este correo.`;
  }

  /**
   * Send a single email with attachments
   */
  private async sendSingleEmail(
    subject: string,
    html?: string,
    text?: string,
    attachments: EmailAttachment[] = [],
  ): Promise<void> {
    const to = ['fazztrack1963@gmail.com'];
    const from = this.defaultFromEmail;

    try {
      const emailData: any = {
        from,
        to,
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
    } catch (error) {
      this.logger.error('Failed to send email:', error);
      throw error;
    }
  }
}
