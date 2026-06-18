import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
// eslint-disable-next-line @typescript-eslint/no-require-imports
const Stripe = require('stripe');
import { PrismaService } from '../prisma/prisma.service';
import { UpdatePaymentStatusDto } from './dto/update-payment-status.dto';
import { PaymentMethod, PaymentStatus, BookingStatus, UserRole } from '@prisma/client';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  private readonly stripe: any;

  constructor(private prisma: PrismaService) {
    const key = process.env.STRIPE_SECRET_KEY;
    this.stripe = key ? new Stripe(key, { apiVersion: '2026-05-27.dahlia' }) : null;
  }

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

  async initiatePayment(bookingId: number, userId: number, role: string) {
    if (!this.stripe) {
      return { simulated: true, client_secret: null };
    }

    const booking = await this.prisma.booking.findUnique({
      where: { booking_id: bookingId },
      include: { payment: true },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    if (role !== UserRole.admin && booking.booking_user_id !== userId) {
      throw new ForbiddenException('Access denied');
    }
    if (!booking.payment) throw new NotFoundException('Payment record not found');

    const amountCents = Math.round(Number(booking.payment.payments_amount) * 100);
    const intent = await this.stripe.paymentIntents.create({
      amount: amountCents,
      currency: 'eur',
      metadata: { booking_id: String(bookingId) },
    });

    await this.prisma.payment.update({
      where: { payments_booking_id: bookingId },
      data: { payments_stripe_intent_id: intent.id },
    });

    return { client_secret: intent.client_secret };
  }

  async handleWebhook(rawBody: Buffer, signature: string | undefined) {
    if (!this.stripe) {
      throw new InternalServerErrorException('Stripe is not configured');
    }

    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!webhookSecret) throw new InternalServerErrorException('STRIPE_WEBHOOK_SECRET must be set');
    if (!signature) throw new BadRequestException('Missing stripe-signature header');

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let event: any;
    try {
      event = this.stripe.webhooks.constructEvent(rawBody, signature, webhookSecret);
    } catch (err: any) {
      throw new BadRequestException(`Webhook verification failed: ${err.message}`);
    }

    const intentId = (event.data.object as any).id;
    const payment = await this.prisma.payment.findFirst({
      where: { payments_stripe_intent_id: intentId },
      include: { booking: { include: { products: true } } },
    });

    if (!payment) {
      this.logger.warn(`Webhook: no payment found for intent ${intentId}`);
      return { received: true };
    }

    const statusMap: Partial<Record<string, { paymentStatus: PaymentStatus; bookingStatus: BookingStatus | null }>> = {
      'payment_intent.succeeded':      { paymentStatus: PaymentStatus.valide,    bookingStatus: BookingStatus.confirmee },
      'payment_intent.payment_failed': { paymentStatus: PaymentStatus.echoue,    bookingStatus: null },
      'payment_intent.canceled':       { paymentStatus: PaymentStatus.echoue,    bookingStatus: null },
    };
    const mapped = statusMap[event.type];
    if (!mapped) return { received: true };

    await this.prisma.$transaction(async (prisma) => {
      await prisma.payment.update({
        where: { payments_id: payment.payments_id },
        data: { payments_status: mapped.paymentStatus },
      });
      if (mapped.bookingStatus) {
        await prisma.booking.update({
          where: { booking_id: payment.payments_booking_id },
          data: { booking_status: mapped.bookingStatus },
        });
      }
      if (event.type === 'payment_intent.canceled' && payment.booking) {
        for (const bp of payment.booking.products) {
          await prisma.product.update({
            where: { products_id: bp.bp_product_id },
            data: { products_stock: { increment: bp.bp_quantity } },
          });
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
