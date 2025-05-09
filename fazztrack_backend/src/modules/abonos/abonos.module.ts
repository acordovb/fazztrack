import { Module } from '@nestjs/common';
import { AbonosService } from './abonos.service';
import { AbonosController } from './abonos.controller';

@Module({
  imports: [],
  controllers: [AbonosController],
  providers: [AbonosService],
  exports: [AbonosService],
})
export class AbonosModule {}
