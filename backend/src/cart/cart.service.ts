import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';

const MS_PER_DAY = 1000 * 60 * 60 * 24;

@Injectable()
export class CartService {
  constructor(private prisma: PrismaService) {}

  async getCart(userId: number) {
    const cartInclude = {
      items: {
        include: {
          product: {
            include: {
              images: { orderBy: { image_order: 'asc' as const }, take: 1 },
            },
          },
        },
      },
    };

    return this.prisma.cart.upsert({
      where: { carts_user_id: userId },
      create: { carts_user_id: userId },
      update: {},
      include: cartInclude,
    });
  }

  async addItem(userId: number, dto: AddCartItemDto) {
    const cart = await this.getCart(userId);

    const product = await this.prisma.product.findUnique({
      where: { products_id: dto.cart_item_product_id },
    });

    if (!product) throw new NotFoundException('Product not found');
    if (product.products_stock < dto.cart_item_quantity) {
      throw new BadRequestException('Not enough stock');
    }

    const startDate = new Date(dto.cart_item_start_date);
    const endDate = new Date(dto.cart_item_end_date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (startDate < today) {
      throw new BadRequestException('Start date cannot be in the past');
    }
    if (endDate <= startDate) {
      throw new BadRequestException('End date must be after start date');
    }

    const nbDays = Math.ceil((endDate.getTime() - startDate.getTime()) / MS_PER_DAY);
    const totalPrice = Number(product.products_price_per_day) * dto.cart_item_quantity * nbDays;

    return this.prisma.cartItem.create({
      data: {
        cart_item_cart_id: cart.carts_id,
        cart_item_product_id: dto.cart_item_product_id,
        cart_item_quantity: dto.cart_item_quantity,
        cart_item_start_date: startDate,
        cart_item_end_date: endDate,
        cart_item_price_snapshot: totalPrice,
      },
    });
  }

  async updateItem(userId: number, itemId: number, dto: UpdateCartItemDto) {
    const cart = await this.getCart(userId);
    const item = await this.prisma.cartItem.findFirst({
      where: { cart_item_id: itemId, cart_item_cart_id: cart.carts_id },
      include: { product: true },
    });

    if (!item) throw new NotFoundException('Cart item not found');

    const newQty = dto.cart_item_quantity ?? item.cart_item_quantity;
    const startDate = dto.cart_item_start_date ? new Date(dto.cart_item_start_date) : item.cart_item_start_date;
    const endDate = dto.cart_item_end_date ? new Date(dto.cart_item_end_date) : item.cart_item_end_date;

    if (dto.cart_item_start_date || dto.cart_item_end_date) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      if (startDate < today) throw new BadRequestException('Start date cannot be in the past');
      if (endDate <= startDate) throw new BadRequestException('End date must be after start date');
    }

    const nbDays = Math.ceil((endDate.getTime() - startDate.getTime()) / MS_PER_DAY) || 1;
    const newSnapshot = Number(item.product.products_price_per_day) * newQty * nbDays;

    return this.prisma.cartItem.update({
      where: { cart_item_id: itemId },
      data: {
        cart_item_quantity: newQty,
        cart_item_start_date: startDate,
        cart_item_end_date: endDate,
        cart_item_price_snapshot: newSnapshot,
      },
    });
  }

  async removeItem(userId: number, itemId: number) {
    const cart = await this.getCart(userId);
    const item = await this.prisma.cartItem.findFirst({
      where: { cart_item_id: itemId, cart_item_cart_id: cart.carts_id },
    });

    if (!item) throw new NotFoundException('Cart item not found');

    return this.prisma.cartItem.delete({
      where: { cart_item_id: itemId },
    });
  }

  async clearCart(userId: number) {
    const cart = await this.getCart(userId);
    return this.prisma.cartItem.deleteMany({
      where: { cart_item_cart_id: cart.carts_id },
    });
  }
}
