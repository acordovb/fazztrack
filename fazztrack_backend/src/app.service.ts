import { Injectable, Logger } from '@nestjs/common';
import { DatabaseService } from './database/database.service';

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);

  constructor(private database: DatabaseService) {}

  getHello(): string {
    this.logger.log('Database connection status: Active');
    return 'Hello World!';
  }

  async testDatabaseConnection(): Promise<boolean> {
    try {
      await this.database.$queryRaw`SELECT 1`;
      this.logger.log('Database connection test successful');
      return true;
    } catch (error) {
      this.logger.error('Database connection test failed', error);
      return false;
    }
  }
}
