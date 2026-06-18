import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { PaymentMethod, PaymentStatus, UserRole, BookingStatus } from '@prisma/client';

const STATUS_MESSAGES: Partial<Record<BookingStatus, string>> = {
  [BookingStatus.confirmee]:  'Votre réservation a été confirmée.',
  [BookingStatus.en_cours]:   'Votre location est maintenant en cours.',
  [BookingStatus.terminee]:   'Votre location est terminée. Merci !',
  [BookingStatus.annulee]:    'Votre réservation a été annulée.',
};

@Injectable()
export class BookingsService {
  constructor(
    private prisma: PrismaService,
    private notifs: NotificationsService,
  ) {}

  async create(userId: number, dto: CreateBookingDto) {
    const startDate = new Date(dto.booking_start_date);
    const endDate = new Date(dto.booking_end_date);
    const msPerDay = 1000 * 60 * 60 * 24;
    const nbDays = Math.ceil((endDate.getTime() - startDate.getTime()) / msPerDay);

    if (nbDays <= 0) {
      throw new BadRequestException('End date must be after start date');
    }

    return this.prisma.$transaction(async (prisma) => {
      let totalAmount = 0;
      const bpData: any[] = [];

      for (const item of dto.items) {
        const product = await prisma.product.findUnique({ where: { products_id: item.bp_product_id } });
        if (!product) throw new NotFoundException(`Product ${item.bp_product_id} not found`);

        const updated = await prisma.product.updateMany({
          where: { products_id: item.bp_product_id, products_stock: { gte: item.bp_quantity } },
          data: { products_stock: { decrement: item.bp_quantity } },
        });
        if (updated.count === 0) {
          throw new BadRequestException(`Stock insuffisant pour "${product.products_name}"`);
        }

        const priceSnapshot = product.products_price_per_day;
        totalAmount += Number(priceSnapshot) * item.bp_quantity * nbDays;

        bpData.push({
          bp_product_id: product.products_id,
          bp_quantity: item.bp_quantity,
          bp_price_snapshot: priceSnapshot,
        });
      }

      const booking = await prisma.booking.create({
        data: {
          booking_user_id: userId,
          booking_start_date: startDate,
          booking_end_date: endDate,
          booking_total_amount: totalAmount,
          booking_delivery_method: dto.booking_delivery_method,
          booking_delivery_street: dto.booking_delivery_street,
          booking_delivery_city: dto.booking_delivery_city,
          booking_delivery_zip: dto.booking_delivery_zip,
          booking_delivery_country: dto.booking_delivery_country,
          products: {
            create: bpData,
          },
          payment: {
            create: {
              payments_amount: totalAmount,
              payments_method: dto.booking_payment_method ?? PaymentMethod.carte_bancaire,
              payments_status: PaymentStatus.en_attente,
            },
          },
        },
        include: {
          products: true,
          payment: true,
        },
      });

      return booking;
    });
  }

  async findAll(page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const [items, total] = await Promise.all([
      this.prisma.booking.findMany({
        include: { products: true, payment: true, user: { select: { user_nom: true, user_prenom: true, user_email: true } } },
        skip,
        take: limit,
        orderBy: { booking_created_at: 'desc' },
      }),
      this.prisma.booking.count(),
    ]);
    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findMine(userId: number) {
    return this.prisma.booking.findMany({
      where: { booking_user_id: userId },
      include: { products: { include: { product: true } }, payment: true, review: true },
      orderBy: { booking_created_at: 'desc' },
    });
  }

  async findOne(id: number, userId: number, role: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { booking_id: id },
      include: { products: { include: { product: true } }, payment: true, review: true },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    if (role !== UserRole.admin && booking.booking_user_id !== userId) {
      throw new ForbiddenException('Access denied');
    }
    return booking;
  }

  async cancel(id: number, userId: number, role: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { booking_id: id },
      include: { products: true },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    if (role !== UserRole.admin && booking.booking_user_id !== userId) {
      throw new ForbiddenException('Access denied');
    }
    const cancellable: BookingStatus[] = [BookingStatus.en_attente, BookingStatus.confirmee];
    if (!cancellable.includes(booking.booking_status)) {
      throw new BadRequestException('Only pending or confirmed bookings can be cancelled');
    }

    return this.prisma.$transaction(async (prisma) => {
      for (const bp of booking.products) {
        await prisma.product.update({
          where: { products_id: bp.bp_product_id },
          data: { products_stock: { increment: bp.bp_quantity } },
        });
      }
      return prisma.booking.update({
        where: { booking_id: id },
        data: { booking_status: BookingStatus.annulee },
      });
    });
  }

  async getInvoice(id: number, userId: number, role: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { booking_id: id },
      include: {
        products: { include: { product: true } },
        payment: true,
        user: { select: { user_nom: true, user_prenom: true, user_email: true } },
      },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    if (role !== UserRole.admin && booking.booking_user_id !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return {
      invoice_number: `INV-${booking.booking_id.toString().padStart(6, '0')}`,
      date: booking.booking_created_at,
      client: {
        nom: booking.user.user_nom,
        prenom: booking.user.user_prenom,
        email: booking.user.user_email,
      },
      items: booking.products.map((bp) => {
        const nbDays = Math.ceil(
          (new Date(booking.booking_end_date).getTime() - new Date(booking.booking_start_date).getTime())
          / (1000 * 60 * 60 * 24),
        ) || 1;
        return {
          product_name: bp.product.products_name,
          quantity: bp.bp_quantity,
          unit_price: Number(bp.bp_price_snapshot),
          nb_days: nbDays,
          start_date: booking.booking_start_date,
          end_date: booking.booking_end_date,
          subtotal: Number(bp.bp_price_snapshot) * bp.bp_quantity * nbDays,
        };
      }),
      total_amount: Number(booking.booking_total_amount),
      delivery_method: booking.booking_delivery_method,
      payment_method: booking.payment?.payments_method ?? null,
      payment_status: booking.payment?.payments_status ?? null,
    };
  }

  async updateStatus(id: number, dto: UpdateBookingStatusDto) {
    const booking = await this.prisma.booking.update({
      where: { booking_id: id },
      data: { booking_status: dto.status },
      include: { user: { select: { user_push_token: true } } },
    });

    const token = booking.user?.user_push_token;
    const message = STATUS_MESSAGES[dto.status];
    if (token && message) {
      await this.notifs.sendToToken(
        token,
        'Kits & Kids',
        message,
        { booking_id: String(id) },
      );
    }

    return booking;
  }
}
