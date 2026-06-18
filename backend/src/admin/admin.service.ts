import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BookingStatus, PaymentStatus } from '@prisma/client';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getStats() {
    const [
      totalBookings,
      pendingBookings,
      activeBookings,
      confirmedBookings,
      totalUsers,
      totalProducts,
      revenueAgg,
    ] = await Promise.all([
      this.prisma.booking.count(),
      this.prisma.booking.count({ where: { booking_status: BookingStatus.en_attente } }),
      this.prisma.booking.count({ where: { booking_status: BookingStatus.en_cours } }),
      this.prisma.booking.count({ where: { booking_status: BookingStatus.confirmee } }),
      this.prisma.user.count(),
      this.prisma.product.count(),
      this.prisma.payment.aggregate({
        _sum: { payments_amount: true },
        where: { payments_status: PaymentStatus.valide },
      }),
    ]);

    return {
      total_bookings:     totalBookings,
      pending_bookings:   pendingBookings,
      active_bookings:    activeBookings,
      confirmed_bookings: confirmedBookings,
      total_users:        totalUsers,
      total_products:     totalProducts,
      total_revenue:      Number(revenueAgg._sum.payments_amount ?? 0),
    };
  }
}
