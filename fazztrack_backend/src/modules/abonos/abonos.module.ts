import { Module } from '@nestjs/common';
import { AbonosService } from './abonos.service';
import { AbonosController } from './abonos.controller';

@Module({
  controllers: [AbonosController],
  providers: [AbonosService],
  exports: [AbonosService],
})
export class AbonosModule {}
