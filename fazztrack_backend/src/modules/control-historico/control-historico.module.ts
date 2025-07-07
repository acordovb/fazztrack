import { Module } from '@nestjs/common';
import { ControlHistoricoService } from './control-historico.service';
import { ControlHistoricoController } from './control-historico.controller';
import { ControlHistoricoCronService } from './control-historico-cron.service';
import { VentasModule } from '../ventas/ventas.module';
import { AbonosModule } from '../abonos/abonos.module';
import { EstudiantesModule } from '../estudiantes/estudiantes.module';

@Module({
  imports: [VentasModule, AbonosModule, EstudiantesModule],
  controllers: [ControlHistoricoController],
  providers: [ControlHistoricoService, ControlHistoricoCronService],
  exports: [ControlHistoricoService],
})
export class ControlHistoricoModule {}
