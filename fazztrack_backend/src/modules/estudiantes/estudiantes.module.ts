import { Module } from '@nestjs/common';
import { EstudiantesService } from './estudiantes.service';
import { EstudiantesController } from './estudiantes.controller';

@Module({
  imports: [],
  controllers: [EstudiantesController],
  providers: [EstudiantesService],
  exports: [EstudiantesService],
})
export class EstudiantesModule {}
