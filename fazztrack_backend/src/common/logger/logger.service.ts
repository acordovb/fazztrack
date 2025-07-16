import { Injectable, LoggerService } from '@nestjs/common';

@Injectable()
export class AppLoggerService implements LoggerService {
  private readonly colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    dim: '\x1b[2m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    gray: '\x1b[90m',
  };

  constructor() {}

  private formatTimestamp(): string {
    const now = new Date();
    return `${this.colors.gray}${now.toISOString()}${this.colors.reset}`;
  }

  private formatContext(context: string, color: string): string {
    return `${color}${this.colors.bright}[${context}]${this.colors.reset}`;
  }

  private formatMessage(message: any): string {
    if (typeof message === 'object') {
      return JSON.stringify(message, null, 2);
    }
    return String(message);
  }

  log(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'LOG', this.colors.green);
    const msg = this.formatMessage(message);

    console.log(
      `${timestamp} ${ctx} ${this.colors.white}${msg}${this.colors.reset}`,
    );
  }

  error(message: any, trace?: string, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'ERROR', this.colors.red);
    const msg = this.formatMessage(message);

    console.error(
      `${timestamp} ${ctx} ${this.colors.red}${msg}${this.colors.reset}`,
    );
    if (trace) {
      console.error(
        `${this.colors.dim}${this.colors.red}${trace}${this.colors.reset}`,
      );
    }
  }

  warn(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'WARN', this.colors.yellow);
    const msg = this.formatMessage(message);

    console.warn(
      `${timestamp} ${ctx} ${this.colors.yellow}${msg}${this.colors.reset}`,
    );
  }

  debug(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'DEBUG', this.colors.magenta);
    const msg = this.formatMessage(message);

    console.debug(
      `${timestamp} ${ctx} ${this.colors.magenta}${msg}${this.colors.reset}`,
    );
  }

  verbose(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'VERBOSE', this.colors.cyan);
    const msg = this.formatMessage(message);

    console.log(
      `${timestamp} ${ctx} ${this.colors.cyan}${msg}${this.colors.reset}`,
    );
  }

  /**
   * Log success messages with green color
   */
  success(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'SUCCESS', this.colors.green);
    const msg = this.formatMessage(message);

    console.log(
      `${timestamp} ${ctx} ${this.colors.green}${this.colors.bright}${msg}${this.colors.reset}`,
    );
  }

  /**
   * Log info messages with blue color
   */
  info(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'INFO', this.colors.blue);
    const msg = this.formatMessage(message);

    console.log(
      `${timestamp} ${ctx} ${this.colors.blue}${msg}${this.colors.reset}`,
    );
  }

  /**
   * Log HTTP request/response with appropriate colors based on status
   */
  http(message: any, statusCode?: number, context?: string): void {
    const timestamp = this.formatTimestamp();
    let color = this.colors.green;
    let logLevel = 'HTTP';

    if (statusCode) {
      if (statusCode >= 500) {
        color = this.colors.red;
        logLevel = 'HTTP_ERROR';
      } else if (statusCode >= 400) {
        color = this.colors.yellow;
        logLevel = 'HTTP_WARN';
      } else if (statusCode >= 300) {
        color = this.colors.cyan;
        logLevel = 'HTTP_REDIRECT';
      }
    }

    const ctx = this.formatContext(context || logLevel, color);
    const msg = this.formatMessage(message);

    console.log(`${timestamp} ${ctx} ${color}${msg}${this.colors.reset}`);
  }

  /**
   * Log database operations
   */
  database(message: any, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'DATABASE', this.colors.magenta);
    const msg = this.formatMessage(message);

    console.log(
      `${timestamp} ${ctx} ${this.colors.magenta}${msg}${this.colors.reset}`,
    );
  }

  /**
   * Log with custom color
   */
  custom(message: any, color: string, context?: string): void {
    const timestamp = this.formatTimestamp();
    const ctx = this.formatContext(context || 'CUSTOM', color);
    const msg = this.formatMessage(message);

    console.log(`${timestamp} ${ctx} ${color}${msg}${this.colors.reset}`);
  }
}
