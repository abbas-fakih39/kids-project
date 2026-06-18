import { Test, TestingModule } from '@nestjs/testing';
import { PaymentsService } from './payments.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';

const mockPrisma = {
  booking: { findUnique: jest.fn() },
  payment: { findUnique: jest.fn(), findFirst: jest.fn(), update: jest.fn() },
  product: { update: jest.fn() },
  $transaction: jest.fn(),
};

describe('PaymentsService', () => {
  let service: PaymentsService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaymentsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<PaymentsService>(PaymentsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── findByBooking ──────────────────────────────────────────

  describe('findByBooking', () => {
    it('throws NotFoundException when booking does not exist', async () => {
      mockPrisma.booking.findUnique.mockResolvedValue(null);
      await expect(service.findByBooking(99, 1, 'client')).rejects.toThrow(NotFoundException);
    });

    it('throws ForbiddenException when user does not own the booking', async () => {
      mockPrisma.booking.findUnique.mockResolvedValue({ booking_id: 1, booking_user_id: 2 });
      await expect(service.findByBooking(1, 1, 'client')).rejects.toThrow(ForbiddenException);
    });

    it('returns payment for the booking owner', async () => {
      mockPrisma.booking.findUnique.mockResolvedValue({ booking_id: 1, booking_user_id: 1 });
      mockPrisma.payment.findUnique.mockResolvedValue({ payments_id: 10, payments_booking_id: 1 });
      const result = await service.findByBooking(1, 1, 'client');
      expect(result).toMatchObject({ payments_id: 10 });
    });

    it('allows admin to view any booking payment', async () => {
      mockPrisma.booking.findUnique.mockResolvedValue({ booking_id: 1, booking_user_id: 99 });
      mockPrisma.payment.findUnique.mockResolvedValue({ payments_id: 10 });
      const result = await service.findByBooking(1, 1, 'admin');
      expect(result).toMatchObject({ payments_id: 10 });
    });
  });

  // ── initiatePayment ───────────────────────────────────────

  describe('initiatePayment', () => {
    it('returns simulated response when Stripe is not configured', async () => {
      // STRIPE_SECRET_KEY not set in test env → stripe instance is null → simulated mode
      mockPrisma.booking.findUnique.mockResolvedValue({
        booking_id: 1,
        booking_user_id: 1,
        booking_total_price: 100,
        payment: null,
      });
      const result = await service.initiatePayment(1, 1, 'client');
      expect(result).toMatchObject({ simulated: true, client_secret: null });
    });

    it('returns simulated response regardless of bookingId when Stripe is not configured', async () => {
      const result = await service.initiatePayment(99, 1, 'client');
      expect(result).toMatchObject({ simulated: true, client_secret: null });
      // DB is never called in simulated mode
      expect(mockPrisma.booking.findUnique).not.toHaveBeenCalled();
    });
  });

  // ── updateStatus ──────────────────────────────────────────

  describe('updateStatus', () => {
    it('updates payment status', async () => {
      mockPrisma.payment.update.mockResolvedValue({ payments_id: 5, payments_status: 'valide' });
      const result = await service.updateStatus(5, { status: 'valide' as any });
      expect(result).toMatchObject({ payments_id: 5 });
      expect(mockPrisma.payment.update).toHaveBeenCalledWith({
        where: { payments_id: 5 },
        data: { payments_status: 'valide' },
      });
    });
  });
});
