import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { BookingStatus } from '@prisma/client';

@Injectable()
export class ReviewsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: number, dto: CreateReviewDto) {
    return this.prisma.$transaction(async (prisma) => {
      const booking = await prisma.booking.findUnique({
        where: { booking_id: dto.review_booking_id },
        include: {
          products: { where: { bp_product_id: dto.review_product_id } },
          review: true,
        },
      });

      if (!booking || booking.booking_user_id !== userId) {
        throw new BadRequestException('Booking not found or not owned by user');
      }
      if (booking.booking_status !== BookingStatus.terminee) {
        throw new BadRequestException('You can only review completed bookings');
      }
      if (booking.products.length === 0) {
        throw new BadRequestException('This product was not in the specified booking');
      }
      if (booking.review) {
        throw new BadRequestException('You have already submitted a review for this booking');
      }

      return prisma.review.create({
        data: {
          review_booking_id: dto.review_booking_id,
          review_user_id: userId,
          review_product_id: dto.review_product_id,
          review_rating: dto.review_rating,
          review_comment: dto.review_comment,
        },
      });
    });
  }

  async findByProduct(productId: number, page = 1, limit = 10) {
    const skip = (page - 1) * limit;
    const [items, total] = await Promise.all([
      this.prisma.review.findMany({
        where: { review_product_id: productId },
        include: { user: { select: { user_nom: true, user_prenom: true } } },
        orderBy: { review_created_at: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.review.count({ where: { review_product_id: productId } }),
    ]);
    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }
}
