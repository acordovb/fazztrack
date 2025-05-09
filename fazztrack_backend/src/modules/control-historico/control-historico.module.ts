import { Module } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoController } from './control-historico.controller';

@Module({
  imports: [],
  controllers: [ControlHistoricoController],
  providers: [ControlHistoricoService],
  exports: [ControlHistoricoService],
})
export class ControlHistoricoModule {}
