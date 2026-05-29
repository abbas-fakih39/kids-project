import { Injectable, NotFoundException, ForbiddenException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdatePaymentStatusDto } from './dto/update-payment-status.dto';
import { WebhookPaymentDto } from './dto/webhook-payment.dto';
import { PaymentMethod, PaymentStatus, BookingStatus, UserRole } from '@prisma/client';
import * as crypto from 'crypto';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(private prisma: PrismaService) {}

  async findByBooking(bookingId: number, userId: number, role: string) {
    const booking = await this.prisma.booking.findUnique({ where: { booking_id: bookingId } });
    if (!booking) throw new NotFoundException('Booking not found');
    if (role !== UserRole.admin && booking.booking_user_id !== userId) {
      throw new ForbiddenException('Access denied');
    }
    const payment = await this.prisma.payment.findUnique({
      where: { payments_booking_id: bookingId },
    });
    if (!payment) throw new NotFoundException('Payment not found for this booking');
    return payment;
  }

  async handleWebhook(rawBody: Buffer, dto: WebhookPaymentDto, signature: string | undefined) {
    const secret = process.env.WEBHOOK_SECRET;
    if (!secret) throw new Error('WEBHOOK_SECRET must be set');
    if (!signature) throw new BadRequestException('Missing webhook signature');

    // HMAC is verified against the raw request bytes, not the re-serialised DTO.
    const expected = crypto
      .createHmac('sha256', secret)
      .update(rawBody)
      .digest('hex');

    const sigBuffer = Buffer.from(signature, 'hex');
    const expBuffer = Buffer.from(expected, 'hex');
    if (sigBuffer.length !== expBuffer.length ||
        !crypto.timingSafeEqual(sigBuffer, expBuffer)) {
      throw new BadRequestException('Invalid webhook signature');
    }

    const payment = await this.prisma.payment.findUnique({
      where: { payments_id: dto.payment_id },
      include: { booking: { include: { products: true } } },
    });
    if (!payment) throw new NotFoundException('Payment not found');

    const statusMap: Record<string, { paymentStatus: PaymentStatus; bookingStatus: BookingStatus | null }> = {
      'payment.succeeded': { paymentStatus: PaymentStatus.valide,    bookingStatus: BookingStatus.confirmee },
      'payment.failed':    { paymentStatus: PaymentStatus.echoue,    bookingStatus: null },
      'payment.refunded':  { paymentStatus: PaymentStatus.rembourse, bookingStatus: BookingStatus.annulee },
    };
    const mapped = statusMap[dto.event_type];
    if (!mapped) throw new BadRequestException(`Unknown event_type: ${dto.event_type}`);

    await this.prisma.$transaction(async (prisma) => {
      await prisma.payment.update({
        where: { payments_id: dto.payment_id },
        data: { payments_status: mapped.paymentStatus },
      });
      if (mapped.bookingStatus) {
        await prisma.booking.update({
          where: { booking_id: payment.payments_booking_id },
          data: { booking_status: mapped.bookingStatus },
        });
        if (mapped.bookingStatus === BookingStatus.annulee && payment.booking) {
          for (const bp of payment.booking.products) {
            await prisma.product.update({
              where: { products_id: bp.bp_product_id },
              data: { products_stock: { increment: bp.bp_quantity } },
            });
          }
        }
      }
    });

    return { received: true };
  }

  async updateStatus(id: number, dto: UpdatePaymentStatusDto) {
    const data: { payments_status?: PaymentStatus; payments_method?: PaymentMethod } = {};
    if (dto.status) data.payments_status = dto.status;
    if (dto.method) data.payments_method = dto.method;

    return this.prisma.payment.update({
      where: { payments_id: id },
      data,
    });
  }
}
