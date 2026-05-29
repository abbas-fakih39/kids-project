import { Controller, Get, Body, Patch, Param, Delete, UseGuards, ParseIntPipe, ForbiddenException } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Roles(UserRole.admin)
  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get('profile')
  getProfile(@CurrentUser() user: any) {
    return this.usersService.findOne(user.sub);
  }

  @Patch('profile/password')
  changePassword(@CurrentUser() user: any, @Body() changePasswordDto: ChangePasswordDto) {
    return this.usersService.changePassword(user.sub, changePasswordDto);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    if (user.sub !== id && user.role !== UserRole.admin) throw new ForbiddenException();
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any, @Body() updateUserDto: UpdateUserDto) {
    if (user.sub !== id && user.role !== UserRole.admin) throw new ForbiddenException();
    return this.usersService.update(id, updateUserDto);
  }

  @Delete('me')
  removeMe(@CurrentUser() user: any) {
    return this.usersService.remove(user.sub);
  }

  @Roles(UserRole.admin)
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id);
  }
}
