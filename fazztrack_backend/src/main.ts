import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { UnhashIdPipe } from './common/pipes/unhash-id.pipe';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  app.setGlobalPrefix('api/v1');
  const port = configService.get('port') || 3000;
  app.useGlobalPipes(new UnhashIdPipe());
  await app.listen(port);
  console.log(`Fazztrack is running on: ${await app.getUrl()}`);
}
bootstrap();
