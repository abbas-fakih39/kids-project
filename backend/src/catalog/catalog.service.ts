import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ProductStatus } from '@prisma/client';

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  async findAllGroupedByCategory() {
    const categories = await this.prisma.category.findMany({
      orderBy: { cat_order: 'asc' },
      include: {
        products: {
          where: { products_category_id: { not: null } },
          orderBy: { products_name: 'asc' },
          select: {
            products_id:            true,
            products_name:          true,
            products_description:   true,
            products_image_url:     true,
            products_stock:         true,
            products_price_per_day: true,
            products_status:        true,
            products_safety_standards: true,
          },
        },
      },
    });

    return categories.map((cat) => ({
      id:    cat.cat_id,
      name:  cat.cat_name,
      slug:  cat.cat_slug,
      order: cat.cat_order,
      products: cat.products.map((p) => ({
        id:          p.products_id,
        name:        p.products_name,
        description: p.products_description,
        imageUrl:    p.products_image_url,
        stock:       p.products_stock,
        dailyPrice:  Number(p.products_price_per_day),
        status:      p.products_status,
        safety:      p.products_safety_standards,
        isAvailable: p.products_status === ProductStatus.disponible && p.products_stock > 0,
      })),
    }));
  }
}
