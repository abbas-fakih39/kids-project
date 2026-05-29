import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductImageDto } from './dto/create-product-image.dto';

@Injectable()
export class ProductImagesService {
  constructor(private prisma: PrismaService) {}

  async addImage(dto: CreateProductImageDto) {
    return this.prisma.productImage.create({
      data: {
        image_products_id: dto.image_products_id,
        image_url: dto.image_url,
        image_order: dto.image_order || 0,
      },
    });
  }

  async reorder(id: number, newOrder: number) {
    const image = await this.prisma.productImage.findUnique({ where: { image_id: id } });
    if (!image) throw new NotFoundException('Image not found');

    return this.prisma.productImage.update({
      where: { image_id: id },
      data: { image_order: newOrder },
    });
  }

  async remove(id: number) {
    return this.prisma.productImage.delete({
      where: { image_id: id },
    });
  }
}
