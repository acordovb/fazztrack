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

  // Example method to test database connectivity
  async testDatabaseConnection(): Promise<boolean> {
    try {
      // Execute a simple query to check connection
      await this.prisma.$queryRaw`SELECT 1`;
      this.logger.log('Database connection test successful');
      return true;
    } catch (error) {
      this.logger.error('Database connection test failed', error);
      return false;
    }
  }
}
