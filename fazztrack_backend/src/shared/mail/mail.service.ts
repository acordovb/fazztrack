// import { Injectable, Logger } from '@nestjs/common';
// import { ConfigService } from '@nestjs/config';
// import { Resend } from 'resend';

// export interface EmailAttachment {
//   filename: string;
//   content: Buffer | string;
//   contentType?: string;
// }

// @Injectable()
// export class MailService {
//   private readonly logger = new Logger(MailService.name);
//   private resend: Resend;
//   private readonly defaultFromEmail: string;

//   constructor(private configService: ConfigService) {
//     const resendApiKey = this.configService.get<string>('RESEND_API_KEY');
//     if (!resendApiKey) {
//       throw new Error('RESEND_API_KEY is not configured');
//     }

//     this.resend = new Resend(resendApiKey);
//     this.defaultFromEmail = 'Fazztrack System <fazztrack@resend.dev>';
//   }

//   /**
//    * Send email with PDF results in base64 (OPTIMIZED METHOD)
//    * This method is more efficient as it doesn't require file I/O
//    */
//   async sendEmailWithPdfResults(
//     subject: string,
//     htmlContent?: string,
//     textContent?: string,
//     studentNames?: string[],
//   ): Promise<void> {
//     if (pdfResults.length === 0) {
//       this.logger.warn('No PDF results to send');
//       return;
//     }

//     try {
//       // Convert PdfResult objects to EmailAttachment format
//       const attachments: EmailAttachment[] = [];

//       for (const pdfResult of pdfResults) {
//         try {
//           // Convert base64 to Buffer for email attachment
//           const content = Buffer.from(pdfResult.base64, 'base64');

//           // Validate file size (most email providers have limits)
//           const maxSize = 25 * 1024 * 1024; // 25MB limit
//           if (content.length > maxSize) {
//             this.logger.warn(
//               `PDF file ${pdfResult.filename} is too large (${Math.round(content.length / 1024 / 1024)}MB), skipping`,
//             );
//             continue;
//           }

//           attachments.push({
//             filename: pdfResult.filename,
//             content,
//             contentType: pdfResult.mimeType,
//           });
//         } catch (error) {
//           this.logger.error(
//             `Failed to process PDF result ${pdfResult.filename}:`,
//             error,
//           );
//         }
//       }

//       if (attachments.length === 0) {
//         this.logger.warn('No valid PDF results could be processed');
//         return;
//       }

//       await this.sendPDFEmailsInBatches(
//         subject,
//         attachments,
//         htmlContent,
//         textContent,
//         studentNames,
//       );

//       this.logger.log(
//         `Successfully sent email with ${attachments.length} PDF attachments using base64 method`,
//       );
//     } catch (error) {
//       this.logger.error('Failed to send email with PDF results:', error);
//       throw error;
//     }
//   }

//   /**
//    * Send PDFs in batches to handle email provider limits
//    */
//   private async sendPDFEmailsInBatches(
//     subject: string,
//     pdfs: EmailAttachment[],
//     htmlContent?: string,
//     textContent?: string,
//     studentNames?: string[],
//   ): Promise<void> {
//     const MAX_ATTACHMENTS_PER_EMAIL = 25;

//     // Split PDFs into chunks if necessary
//     const pdfChunks = this.chunkArray(pdfs, MAX_ATTACHMENTS_PER_EMAIL);

//     for (let i = 0; i < pdfChunks.length; i++) {
//       const chunk = pdfChunks[i];
//       const isMultipart = pdfChunks.length > 1;

//       // Modify subject for multi-part emails
//       const emailSubject = isMultipart
//         ? `${subject} - Parte ${i + 1} de ${pdfChunks.length}`
//         : subject;

//       // Create email content
//       const defaultHtml = this.generateDefaultHtmlContent(
//         emailSubject,
//         chunk.length,
//         isMultipart,
//         i + 1,
//         pdfChunks.length,
//         studentNames,
//       );

//       const defaultText = this.generateDefaultTextContent(
//         emailSubject,
//         chunk.length,
//         isMultipart,
//         i + 1,
//         pdfChunks.length,
//         studentNames,
//       );

//       try {
//         await this.sendSingleEmail(
//           emailSubject,
//           htmlContent || defaultHtml,
//           textContent || defaultText,
//           chunk,
//         );
//       } catch (error) {
//         this.logger.error(
//           `Failed to send email ${i + 1}/${pdfChunks.length}:`,
//           error,
//         );
//         throw error;
//       }
//     }
//   }

//   /**
//    * Send a single email with attachments
//    */
//   private async sendSingleEmail(
//     subject: string,
//     html?: string,
//     text?: string,
//     attachments: EmailAttachment[] = [],
//   ): Promise<void> {
//     const to = ['fazztrack1963@gmail.com'];
//     const from = this.defaultFromEmail;

//     try {
//       const emailData: any = {
//         from,
//         to,
//         subject,
//       };

//       if (html) {
//         emailData.html = html;
//       }

//       if (text) {
//         emailData.text = text;
//       }

//       if (attachments && attachments.length > 0) {
//         emailData.attachments = attachments.map((attachment) => ({
//           filename: attachment.filename,
//           content: attachment.content,
//           ...(attachment.contentType && {
//             contentType: attachment.contentType,
//           }),
//         }));
//       }

//       const result = await this.resend.emails.send(emailData);
//     } catch (error) {
//       this.logger.error('Failed to send email:', error);
//       throw error;
//     }
//   }

//   /**
//    * Generate default HTML content for PDF emails
//    */
//   private generateDefaultHtmlContent(
//     subject: string,
//     pdfCount: number,
//     isMultipart: boolean,
//     currentPart?: number,
//     totalParts?: number,
//     studentNames?: string[],
//   ): string {
//     const partInfo = isMultipart
//       ? `<p style="color: #666; font-size: 14px; margin-bottom: 15px;">
//            <strong>Parte ${currentPart} de ${totalParts}</strong>
//          </p>`
//       : '';

//     // Generate student names section
//     const studentNamesSection =
//       studentNames && studentNames.length > 0
//         ? `
//         <div style="background-color: #f0f8ff; padding: 20px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #2196F3;">
//           <h3 style="color: #1976D2; margin: 0 0 15px 0; font-size: 16px;">Estudiantes incluidos en este reporte:</h3>
//           <ul style="margin: 0; padding-left: 20px; color: #666;">
//             ${studentNames.map((name) => `<li style="margin-bottom: 5px;">${name}</li>`).join('')}
//           </ul>
//         </div>
//       `
//         : '';

//     return `
//       <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
//         <h2 style="color: #333; margin-bottom: 20px;">${subject}</h2>
//         ${partInfo}
//         ${studentNamesSection}
//         <div style="background-color: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
//           <p style="color: #666; line-height: 1.6; margin: 0;">
//             Se adjuntan <strong>${pdfCount} archivo(s) PDF</strong> en este correo.
//           </p>
//           ${
//             isMultipart
//               ? `
//             <p style="color: #666; line-height: 1.6; margin: 10px 0 0 0;">
//               <em>Nota: Debido a la cantidad de archivos, los PDFs se han dividido en ${totalParts} correos separados.</em>
//             </p>
//           `
//               : ''
//           }
//         </div>
//         <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
//         <p style="color: #999; font-size: 12px; text-align: center;">
//           Este es un mensaje automático de FazzTrack. Por favor no responda a este correo.
//         </p>
//       </div>
//     `;
//   }

//   /**
//    * Generate default text content for PDF emails
//    */
//   private generateDefaultTextContent(
//     subject: string,
//     pdfCount: number,
//     isMultipart: boolean,
//     currentPart?: number,
//     totalParts?: number,
//     studentNames?: string[],
//   ): string {
//     const partInfo = isMultipart
//       ? `Parte ${currentPart} de ${totalParts}\n\n`
//       : '';
//     const multipartNote = isMultipart
//       ? `\n\nNota: Debido a la cantidad de archivos, los PDFs se han dividido en ${totalParts} correos separados.`
//       : '';

//     // Generate student names section for text
//     const studentNamesSection =
//       studentNames && studentNames.length > 0
//         ? `\n\nESTUDIANTES INCLUIDOS:\n${studentNames.map((name, index) => `${index + 1}. ${name}`).join('\n')}\n`
//         : '';

//     return `${subject}\n\n${partInfo}Se adjuntan ${pdfCount} archivo(s) PDF en este correo.${multipartNote}${studentNamesSection}\n\n---\nEste es un mensaje automático de FazzTrack. Por favor no responda a este correo.`;
//   }

//   /**
//    * Utility method to chunk array into smaller arrays
//    */
//   private chunkArray<T>(array: T[], size: number): T[][] {
//     const chunks: T[][] = [];
//     for (let i = 0; i < array.length; i += size) {
//       chunks.push(array.slice(i, i + size));
//     }
//     return chunks;
//   }
// }
