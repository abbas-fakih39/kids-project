import { Controller, Get, Post, Body, Patch, Param, UseGuards, ParseIntPipe, DefaultValuePipe, Query } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('bookings')
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  create(@CurrentUser() user: any, @Body() createBookingDto: CreateBookingDto) {
    return this.bookingsService.create(user.sub, createBookingDto);
  }

  @Roles(UserRole.admin)
  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page?: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit?: number,
  ) {
    return this.bookingsService.findAll(page, limit);
  }

  @Patch(':id/cancel')
  cancel(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.bookingsService.cancel(id, user.sub, user.role);
  }

  @Get('mine')
  findMine(@CurrentUser() user: any) {
    return this.bookingsService.findMine(user.sub);
  }

  @Get(':id/invoice')
  getInvoice(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.bookingsService.getInvoice(id, user.sub, user.role);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.bookingsService.findOne(id, user.sub, user.role);
  }

  @Roles(UserRole.admin)
  @Patch(':id/status')
  updateStatus(@Param('id', ParseIntPipe) id: number, @Body() updateBookingStatusDto: UpdateBookingStatusDto) {
    return this.bookingsService.updateStatus(id, updateBookingStatusDto);
  }
}
