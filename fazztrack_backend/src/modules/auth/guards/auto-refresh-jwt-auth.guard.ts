import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { IS_PRIVATE_KEY } from '../decorators/private.decorator';

@Injectable()
export class AutoRefreshJwtAuthGuard extends AuthGuard('jwt') {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
    private reflector: Reflector,
  ) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Check if endpoint is marked as public
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      // Public routes are accessible without authentication
      return true;
    }

    // Check if endpoint is marked as private
    const isPrivate = this.reflector.getAllAndOverride<boolean>(
      IS_PRIVATE_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (isPrivate) {
      try {
        // For private routes, strictly enforce JWT authentication
        return (await super.canActivate(context)) as boolean;
      } catch (error) {
        throw new UnauthorizedException(
          'No tienes permisos para acceder a este recurso',
        );
      }
    }

    // Default behavior for routes without decorators
    // Since we apply this guard globally, by default we'll require authentication
    // unless routes are explicitly marked as public
    try {
      return (await super.canActivate(context)) as boolean;
    } catch (error) {
      throw new UnauthorizedException(
        'No tienes permisos para acceder a este recurso',
      );
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
