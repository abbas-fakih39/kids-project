import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductStatus, BookingStatus } from '@prisma/client';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private serialize<T extends { products_price_per_day?: unknown }>(p: T) {
    return { ...p, products_price_per_day: Number(p.products_price_per_day) };
  }

  private roundRating(r: number | null): number {
    return Math.round((r ?? 0) * 10) / 10;
  }

  async create(dto: CreateProductDto) {
    const product = await this.prisma.product.create({
      data: {
        products_name: dto.products_name,
        products_description: dto.products_description,
        products_category: dto.products_category,
        products_price_per_day: dto.products_price_per_day,
        products_stock: dto.products_stock,
        products_safety_standards: dto.products_safety_standards,
        products_status: dto.products_status,
      },
    });
    return this.serialize(product);
  }

  async findAll(
    category?: string,
    status?: ProductStatus,
    q?: string,
    page = 1,
    limit = 20,
    startDate?: string,
    endDate?: string,
  ) {
    const where: Record<string, unknown> = {};
    if (category) where.products_category = category;
    if (status) where.products_status = status;
    if (q) {
      where.OR = [
        { products_name: { contains: q, mode: 'insensitive' } },
        { products_description: { contains: q, mode: 'insensitive' } },
      ];
    }

    // Date-based availability: exclude products fully booked in the period
    if (startDate && endDate) {
      const start = new Date(startDate);
      const end   = new Date(endDate);

      const bookedQty = await this.prisma.bookingProduct.groupBy({
        by: ['bp_product_id'],
        where: {
          booking: {
            booking_status: { notIn: [BookingStatus.annulee] },
            booking_start_date: { lte: end },
            booking_end_date:   { gte: start },
          },
        },
        _sum: { bp_quantity: true },
      });

      if (bookedQty.length > 0) {
        const bookedIds = bookedQty.map((b) => b.bp_product_id);
        const stocks = await this.prisma.product.findMany({
          where: { products_id: { in: bookedIds } },
          select: { products_id: true, products_stock: true },
        });
        const stockMap: Record<number, number> = Object.fromEntries(
          stocks.map((p) => [p.products_id, p.products_stock]),
        );

        const fullyBookedIds = bookedQty
          .filter((b) => (b._sum.bp_quantity ?? 0) >= (stockMap[b.bp_product_id] ?? 0))
          .map((b) => b.bp_product_id);

        if (fullyBookedIds.length > 0) {
          where.products_id = { notIn: fullyBookedIds };
        }
      }

      // Only show available products when dates are selected
      if (!status) where.products_status = ProductStatus.disponible;
    }

    const skip = (page - 1) * limit;

    const [items, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        include: { images: { orderBy: { image_order: 'asc' } } },
        skip,
        take: limit,
        orderBy: { products_id: 'asc' },
      }),
      this.prisma.product.count({ where }),
    ]);

    // Aggregate ratings
    const productIds = items.map((p) => p.products_id);
    const ratingAggs = productIds.length > 0
      ? await this.prisma.review.groupBy({
          by: ['review_product_id'],
          where: { review_product_id: { in: productIds } },
          _avg: { review_rating: true },
          _count: { review_id: true },
        })
      : [];

    const ratingMap: Record<number, { avg: number; count: number }> = Object.fromEntries(
      ratingAggs.map((r) => [
        r.review_product_id,
        { avg: this.roundRating(r._avg.review_rating), count: r._count.review_id },
      ]),
    );

    return {
      items: items.map((p) => ({
        ...this.serialize(p),
        avg_rating:   ratingMap[p.products_id]?.avg   ?? 0,
        review_count: ratingMap[p.products_id]?.count ?? 0,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: number) {
    const product = await this.prisma.product.findUnique({
      where: { products_id: id },
      include: {
        images: { orderBy: { image_order: 'asc' } },
        reviews: {
          include: { user: { select: { user_nom: true, user_prenom: true } } },
          orderBy: { review_created_at: 'desc' },
        },
      },
    });
    if (!product) throw new NotFoundException('Product not found');

    const reviewCount = product.reviews.length;
    const avgRating = reviewCount > 0
      ? this.roundRating(
          product.reviews.reduce((s, r) => s + r.review_rating, 0) / reviewCount,
        )
      : 0;

    return { ...this.serialize(product), avg_rating: avgRating, review_count: reviewCount };
  }

  async update(id: number, dto: UpdateProductDto) {
    const product = await this.prisma.product.update({
      where: { products_id: id },
      data: {
        products_name: dto.products_name,
        products_description: dto.products_description,
        products_category: dto.products_category,
        products_price_per_day: dto.products_price_per_day,
        products_stock: dto.products_stock,
        products_safety_standards: dto.products_safety_standards,
        products_status: dto.products_status,
      },
    });
    return this.serialize(product);
  }

  async remove(id: number) {
    return this.prisma.product.delete({ where: { products_id: id } });
  }
}
