import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service';

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);

  constructor(private prisma: PrismaService) {}

  getHello(): string {
    this.logger.log('Database connection status: Active');
    return 'Hello World!';
  }

  async testDatabaseConnection(): Promise<boolean> {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      this.logger.log('Database connection test successful');
      return true;
    } catch (error) {
      this.logger.error('Database connection test failed', error);
      return false;
    }
  }
}
