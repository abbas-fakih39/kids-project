import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { UpdateNotifPrefsDto } from './dto/update-notif-prefs.dto';
import * as bcrypt from 'bcrypt';
import { Prisma } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        user_id: true,
        user_nom: true,
        user_prenom: true,
        user_email: true,
        user_role: true,
        user_created_at: true,
      },
    });
  }

  async findOne(id: number) {
    const user = await this.prisma.user.findUnique({
      where: { user_id: id },
      select: {
        user_id: true,
        user_nom: true,
        user_prenom: true,
        user_email: true,
        user_birth: true,
        user_number: true,
        user_role: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async getPreferences(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
      select: {
        user_notif_push: true,
        user_notif_promo: true,
        user_notif_transactional: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updatePreferences(userId: number, dto: UpdateNotifPrefsDto) {
    return this.prisma.user.update({
      where: { user_id: userId },
      data: {
        ...(dto.push !== undefined && { user_notif_push: dto.push }),
        ...(dto.promo !== undefined && { user_notif_promo: dto.promo }),
        ...(dto.transactional !== undefined && { user_notif_transactional: dto.transactional }),
      },
      select: {
        user_notif_push: true,
        user_notif_promo: true,
        user_notif_transactional: true,
      },
    });
  }

  async update(id: number, dto: UpdateUserDto) {
    try {
      return await this.prisma.user.update({
        where: { user_id: id },
        data: {
          user_nom: dto.nom,
          user_prenom: dto.prenom,
          user_birth: dto.birth ? new Date(dto.birth) : undefined,
          user_number: dto.number,
        },
        select: {
          user_id: true,
          user_nom: true,
          user_prenom: true,
          user_email: true,
        },
      });
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2025') {
        throw new NotFoundException('User not found');
      }
      throw e;
    }
  }

  async changePassword(userId: number, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
      select: { user_password: true },
    });
    if (!user) throw new NotFoundException('User not found');

    const isValid = await bcrypt.compare(dto.current_password, user.user_password);
    if (!isValid) throw new BadRequestException('Mot de passe actuel incorrect');

    const newHash = await bcrypt.hash(dto.new_password, 12);
    await this.prisma.user.update({
      where: { user_id: userId },
      data: { user_password: newHash, user_refresh_token: null },
    });
    return { message: 'Mot de passe mis à jour' };
  }

  async savePushToken(userId: number, token: string) {
    await this.prisma.user.update({
      where: { user_id: userId },
      data: { user_push_token: token },
    });
    return { success: true };
  }

  async remove(id: number) {
    try {
      return await this.prisma.user.delete({ where: { user_id: id } });
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError) {
        if (e.code === 'P2025') throw new NotFoundException('User not found');
        if (e.code === 'P2003' || e.code === 'P2014') {
          throw new BadRequestException('Impossible de supprimer ce compte : des réservations sont associées');
        }
      }
      throw e;
    }
  }
}
