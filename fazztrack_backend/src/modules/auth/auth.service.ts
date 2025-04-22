import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { v4 as uuidv4 } from 'uuid';
import { AuthResponseDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async loginAnonymous(): Promise<AuthResponseDto> {
    const userId = uuidv4();
    return this.generateToken(userId);
  }

  // Used by the AutoRefreshJwtAuthGuard to validate tokens
  async validateToken(payload: any): Promise<any> {
    if (!payload.sub) {
      return null;
    }
    return { userId: payload.sub };
  }

  // Generate token for a user ID
  private generateToken(userId: string): AuthResponseDto {
    const expiresIn = parseInt(
      this.configService.get<string>('jwt.expiresIn') ?? '72000',
      10,
    );

    const payload = { sub: userId };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: expiresIn,
      secret:
        this.configService.get<string>('jwt.secret') || 'fazztrack_secret',
    });

    return {
      userId,
      accessToken,
      expiresIn,
    };
  }
}
