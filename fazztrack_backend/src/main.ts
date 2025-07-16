import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { UnhashIdPipe } from './common/pipes/unhash-id.pipe';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new UnhashIdPipe());
  await app.listen(process.env.PORT || 3000);
  console.log(`Fazztrack is running 🚀 on: ${await app.getUrl()}`);
}
bootstrap();
