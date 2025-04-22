import { ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard(['jwt', 'anonymous']) {
  handleRequest(err: any, user: any) {
    return user;
  }
}
