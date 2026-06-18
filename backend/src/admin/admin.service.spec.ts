import { Test, TestingModule } from '@nestjs/testing';
import { AdminService } from './admin.service';
import { PrismaService } from '../prisma/prisma.service';

const mockPrisma = {
  booking: { count: jest.fn() },
  user:    { count: jest.fn() },
  product: { count: jest.fn() },
  payment: { aggregate: jest.fn() },
};

describe('AdminService', () => {
  let service: AdminService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdminService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<AdminService>(AdminService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getStats', () => {
    it('returns aggregated stats', async () => {
      mockPrisma.booking.count
        .mockResolvedValueOnce(42)  // total
        .mockResolvedValueOnce(5)   // pending
        .mockResolvedValueOnce(8)   // active
        .mockResolvedValueOnce(12); // confirmed
      mockPrisma.user.count.mockResolvedValue(23);
      mockPrisma.product.count.mockResolvedValue(15);
      mockPrisma.payment.aggregate.mockResolvedValue({ _sum: { payments_amount: 1850 } });

      const result = await service.getStats();

      expect(result).toMatchObject({
        total_bookings:     42,
        pending_bookings:   5,
        active_bookings:    8,
        confirmed_bookings: 12,
        total_users:        23,
        total_products:     15,
        total_revenue:      1850,
      });
    });

    it('returns 0 revenue when no validated payments', async () => {
      mockPrisma.booking.count.mockResolvedValue(0);
      mockPrisma.user.count.mockResolvedValue(0);
      mockPrisma.product.count.mockResolvedValue(0);
      mockPrisma.payment.aggregate.mockResolvedValue({ _sum: { payments_amount: null } });

      const result = await service.getStats();
      expect(result.total_revenue).toBe(0);
    });
  });
});
