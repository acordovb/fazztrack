import { Module } from '@nestjs/common';
import { BackupService } from './backup.service';
import { BackupController } from './backup.controller';
import { DatabaseModule } from '../../database/database.module';
import { MailModule } from '../../shared/mail/mail.module';

@Module({
  imports: [DatabaseModule, MailModule],
  controllers: [BackupController],
  providers: [BackupService],
  exports: [BackupService],
})
export class BackupModule {}
