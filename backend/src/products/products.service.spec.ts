import { Test, TestingModule } from '@nestjs/testing';
import { ProductsService } from './products.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException } from '@nestjs/common';

const mockProduct = {
  products_id: 1,
  products_name: 'Poussette travel',
  products_category: 'Poussettes',
  products_price_per_day: 15,
  products_stock: 3,
  products_status: 'disponible',
  products_description: null,
  products_safety_standards: null,
  products_created_at: new Date(),
  products_updated_at: null,
  images: [],
};

const mockPrisma = {
  product: {
    create: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  bookingProduct: { groupBy: jest.fn() },
  review: { groupBy: jest.fn() },
};

describe('ProductsService', () => {
  let service: ProductsService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<ProductsService>(ProductsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── findAll ───────────────────────────────────────────────

  describe('findAll', () => {
    it('returns paginated items with ratings', async () => {
      mockPrisma.product.findMany.mockResolvedValue([mockProduct]);
      mockPrisma.product.count.mockResolvedValue(1);
      mockPrisma.review.groupBy.mockResolvedValue([
        { review_product_id: 1, _avg: { review_rating: 4.5 }, _count: { review_id: 10 } },
      ]);

      const result = await service.findAll();

      expect(result.total).toBe(1);
      expect(result.items).toHaveLength(1);
      expect(result.items[0]).toMatchObject({ avg_rating: 4.5, review_count: 10 });
    });

    it('returns avg_rating 0 and review_count 0 for products with no reviews', async () => {
      mockPrisma.product.findMany.mockResolvedValue([mockProduct]);
      mockPrisma.product.count.mockResolvedValue(1);
      mockPrisma.review.groupBy.mockResolvedValue([]);

      const result = await service.findAll();
      expect(result.items[0]).toMatchObject({ avg_rating: 0, review_count: 0 });
    });

    it('calls groupBy for availability when dates are provided', async () => {
      mockPrisma.bookingProduct.groupBy.mockResolvedValue([]);
      mockPrisma.product.findMany.mockResolvedValue([mockProduct]);
      mockPrisma.product.count.mockResolvedValue(1);
      mockPrisma.review.groupBy.mockResolvedValue([]);

      await service.findAll(undefined, undefined, undefined, 1, 20, '2026-07-01', '2026-07-10');

      expect(mockPrisma.bookingProduct.groupBy).toHaveBeenCalledWith(
        expect.objectContaining({ by: ['bp_product_id'] }),
      );
    });

    it('excludes fully-booked products when dates are provided', async () => {
      mockPrisma.bookingProduct.groupBy.mockResolvedValue([
        { bp_product_id: 1, _sum: { bp_quantity: 3 } }, // stock is 3, fully booked
      ]);
      mockPrisma.product.findMany
        .mockResolvedValueOnce([{ products_id: 1, products_stock: 3 }]) // stock lookup
        .mockResolvedValueOnce([]);                                       // main query returns nothing
      mockPrisma.product.count.mockResolvedValue(0);
      mockPrisma.review.groupBy.mockResolvedValue([]);

      const result = await service.findAll(undefined, undefined, undefined, 1, 20, '2026-07-01', '2026-07-10');
      expect(result.total).toBe(0);
    });
  });

  // ── findOne ───────────────────────────────────────────────

  describe('findOne', () => {
    it('throws NotFoundException for unknown id', async () => {
      mockPrisma.product.findUnique.mockResolvedValue(null);
      await expect(service.findOne(99)).rejects.toThrow(NotFoundException);
    });

    it('computes avg_rating from reviews', async () => {
      mockPrisma.product.findUnique.mockResolvedValue({
        ...mockProduct,
        reviews: [
          { review_rating: 5 },
          { review_rating: 4 },
          { review_rating: 3 },
        ],
      });
      const result = await service.findOne(1);
      expect(result.avg_rating).toBe(4);
      expect(result.review_count).toBe(3);
    });

    it('returns avg_rating 0 when no reviews', async () => {
      mockPrisma.product.findUnique.mockResolvedValue({ ...mockProduct, reviews: [] });
      const result = await service.findOne(1);
      expect(result.avg_rating).toBe(0);
    });
  });
});
