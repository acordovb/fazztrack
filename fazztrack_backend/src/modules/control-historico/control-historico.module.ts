import { Module } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoController } from './control-historico.controller';
import { VentasModule } from '../ventas/ventas.module';
import { AbonosModule } from '../abonos/abonos.module';

@Module({
  imports: [VentasModule, AbonosModule],
  controllers: [ControlHistoricoController],
  providers: [ControlHistoricoService],
  exports: [ControlHistoricoService],
})
export class ControlHistoricoModule {}
