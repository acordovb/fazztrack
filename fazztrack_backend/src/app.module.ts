import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { BarsModule } from './modules/bars/bars.module';

@Module({
  imports: [PrismaModule, BarsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
