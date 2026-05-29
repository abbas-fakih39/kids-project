import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductStatus } from '@prisma/client';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  // Prisma Decimal fields serialize as decimal.js objects {s,e,d} in JSON.
  // Convert to plain JS number so Flutter receives a proper numeric value.
  private serialize<T extends { products_price_per_day?: unknown }>(p: T) {
    return { ...p, products_price_per_day: Number(p.products_price_per_day) };
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

  async findAll(category?: string, status?: ProductStatus, q?: string, page = 1, limit = 20) {
    const where: Record<string, unknown> = {};
    if (category) where.products_category = category;
    if (status) where.products_status = status;
    if (q) {
      where.OR = [
        { products_name: { contains: q, mode: 'insensitive' } },
        { products_description: { contains: q, mode: 'insensitive' } },
      ];
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

    return {
      items: items.map((p) => this.serialize(p)),
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
    return this.serialize(product);
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
