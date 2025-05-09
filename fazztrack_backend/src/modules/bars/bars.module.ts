import { Module } from '@nestjs/common';
import { BarsService } from './bars.service';
import { BarsController } from './bars.controller';

@Module({
  imports: [],
  controllers: [BarsController],
  providers: [BarsService],
  exports: [BarsService],
})
export class BarsModule {}
