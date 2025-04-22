import { Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthResponseDto } from './dto';
import { Public } from './decorators/public.decorator';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @Post('anonymous')
  async anonymousLogin(): Promise<AuthResponseDto> {
    return this.authService.loginAnonymous();
  }
}
