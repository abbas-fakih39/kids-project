import { Injectable, UnauthorizedException, ForbiddenException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const userExists = await this.prisma.user.findUnique({
      where: { user_email: dto.email },
    });
    if (userExists) throw new ConflictException('Email already in use');

    const hashedPassword = await bcrypt.hash(dto.password, 12);
    const newUser = await this.prisma.user.create({
      data: {
        user_nom: dto.nom,
        user_prenom: dto.prenom,
        user_email: dto.email,
        user_password: hashedPassword,
        user_birth: dto.birth ? new Date(dto.birth) : null,
        user_number: dto.number,
      },
    });

    const tokens = await this.generateTokens(newUser.user_id, newUser.user_email, newUser.user_role);
    await this.updateRefreshTokenHash(newUser.user_id, tokens.refreshToken);
    return tokens;
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { user_email: dto.email } });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const passwordMatches = await bcrypt.compare(dto.password, user.user_password);
    if (!passwordMatches) throw new UnauthorizedException('Invalid credentials');

    const tokens = await this.generateTokens(user.user_id, user.user_email, user.user_role);
    await this.updateRefreshTokenHash(user.user_id, tokens.refreshToken);
    return tokens;
  }

  async logout(userId: number) {
    await this.prisma.user.updateMany({
      where: {
        user_id: userId,
        user_refresh_token: { not: null },
      },
      data: { user_refresh_token: null },
    });
  }

  async refreshTokens(userId: number, rt: string) {
    const user = await this.prisma.user.findUnique({ where: { user_id: userId } });
    if (!user || !user.user_refresh_token) throw new ForbiddenException('Access Denied');

    const rtMatches = await bcrypt.compare(rt, user.user_refresh_token);
    if (!rtMatches) throw new ForbiddenException('Access Denied');

    const tokens = await this.generateTokens(user.user_id, user.user_email, user.user_role);
    await this.updateRefreshTokenHash(user.user_id, tokens.refreshToken);
    return tokens;
  }

  // --- Helper methods ---

  private async generateTokens(userId: number, email: string, role: string) {
    const accessSecret = process.env.JWT_ACCESS_SECRET;
    const refreshSecret = process.env.JWT_REFRESH_SECRET;
    if (!accessSecret || !refreshSecret) {
      throw new Error('JWT_ACCESS_SECRET and JWT_REFRESH_SECRET must be set');
    }
    const payload = { sub: userId, email, role };
    const [at, rt] = await Promise.all([
      this.jwtService.signAsync(payload, { secret: accessSecret, expiresIn: '15m' }),
      this.jwtService.signAsync(payload, { secret: refreshSecret, expiresIn: '7d' }),
    ]);
    return { accessToken: at, refreshToken: rt };
  }

  private async updateRefreshTokenHash(userId: number, rt: string) {
    const hash = await bcrypt.hash(rt, 12);
    await this.prisma.user.update({
      where: { user_id: userId },
      data: { user_refresh_token: hash },
    });
  }
}
