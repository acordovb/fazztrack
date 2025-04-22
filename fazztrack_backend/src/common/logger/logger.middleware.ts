import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { AppLoggerService } from './logger.service';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  constructor(private readonly loggerService: AppLoggerService) {}

  use(req: Request, res: Response, next: NextFunction) {
    const { method, originalUrl } = req;
    const userAgent = req.get('user-agent') || '';

    // Log at request start
    this.loggerService.log(
      `${method} ${originalUrl} - ${userAgent}`,
      'HttpRequest',
    );

    const startTime = Date.now();

    // Log once the response is finished
    res.on('finish', () => {
      const { statusCode } = res;
      const contentLength = res.get('content-length') || 0;
      const responseTime = Date.now() - startTime;

      this.loggerService.log(
        `${method} ${originalUrl} ${statusCode} ${contentLength} - ${responseTime}ms`,
        'HttpResponse',
      );
    });

    next();
  }
}
