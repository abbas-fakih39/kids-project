import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException } from '@nestjs/common';

const mockPrisma = {
  user: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
};

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── getPreferences ────────────────────────────────────────

  describe('getPreferences', () => {
    it('returns notification preferences for existing user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({
        user_notif_push: true,
        user_notif_promo: false,
        user_notif_transactional: true,
      });
      const result = await service.getPreferences(1);
      expect(result).toMatchObject({
        user_notif_push: true,
        user_notif_promo: false,
        user_notif_transactional: true,
      });
    });

    it('throws NotFoundException for missing user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null);
      await expect(service.getPreferences(99)).rejects.toThrow(NotFoundException);
    });
  });

  // ── updatePreferences ─────────────────────────────────────

  describe('updatePreferences', () => {
    it('updates only the provided fields', async () => {
      mockPrisma.user.update.mockResolvedValue({
        user_notif_push: false,
        user_notif_promo: true,
        user_notif_transactional: true,
      });
      const result = await service.updatePreferences(1, { promo: true });
      expect(result.user_notif_promo).toBe(true);
      expect(mockPrisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { user_id: 1 },
          data: { user_notif_promo: true },
        }),
      );
    });

    it('updates multiple preferences at once', async () => {
      mockPrisma.user.update.mockResolvedValue({
        user_notif_push: true,
        user_notif_promo: true,
        user_notif_transactional: false,
      });
      await service.updatePreferences(1, { push: true, promo: true, transactional: false });
      expect(mockPrisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: {
            user_notif_push: true,
            user_notif_promo: true,
            user_notif_transactional: false,
          },
        }),
      );
    });
  });
});
