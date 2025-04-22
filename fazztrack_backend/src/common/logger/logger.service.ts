import { Injectable, LoggerService } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AppLoggerService implements LoggerService {
  private readonly isDebugEnabled: boolean;

  constructor(private configService: ConfigService) {
    this.isDebugEnabled = this.configService.get<boolean>('debug')!;
  }

  log(message: any, context?: string): void {
    if (this.isDebugEnabled) {
      console.log(
        `[${context || 'LOG'}] ${new Date().toISOString()} - ${message}`,
      );
    }
  }

  error(message: any, trace?: string, context?: string): void {
    if (this.isDebugEnabled) {
      console.error(
        `[${context || 'ERROR'}] ${new Date().toISOString()} - ${message}`,
      );
      if (trace) {
        console.error(trace);
      }
    }
  }

  warn(message: any, context?: string): void {
    if (this.isDebugEnabled) {
      console.warn(
        `[${context || 'WARN'}] ${new Date().toISOString()} - ${message}`,
      );
    }
  }

  debug(message: any, context?: string): void {
    if (this.isDebugEnabled) {
      console.debug(
        `[${context || 'DEBUG'}] ${new Date().toISOString()} - ${message}`,
      );
    }
  }

  verbose(message: any, context?: string): void {
    if (this.isDebugEnabled) {
      console.log(
        `[${context || 'VERBOSE'}] ${new Date().toISOString()} - ${message}`,
      );
    }
  }
}
