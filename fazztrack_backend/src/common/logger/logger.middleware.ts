import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { AppLoggerService } from './logger.service';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  constructor(private readonly loggerService: AppLoggerService) {}

  use(req: Request, res: Response, next: NextFunction) {
    const { method, originalUrl } = req;
    const userAgent = req.get('user-agent') || '';
    const clientIp = req.ip || req.connection.remoteAddress || 'unknown';

    // Log incoming request
    this.loggerService.info(
      `${method} ${originalUrl} - ${clientIp} - ${userAgent}`,
      'HttpRequest',
    );

    const startTime = Date.now();

    res.on('finish', () => {
      const { statusCode } = res;
      const contentLength = res.get('content-length') || 0;
      const responseTime = Date.now() - startTime;

      // Use the new http method for better status-based logging
      const logMessage = `${method} ${originalUrl} ${statusCode} ${contentLength}b - ${responseTime}ms`;
      this.loggerService.http(logMessage, statusCode, 'HttpResponse');
    });

    next();
  }
}
