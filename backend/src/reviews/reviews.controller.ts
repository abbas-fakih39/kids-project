import { Controller, Get, Post, Body, Param, UseGuards, ParseIntPipe, DefaultValuePipe, Query } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@CurrentUser() user: any, @Body() createReviewDto: CreateReviewDto) {
    return this.reviewsService.create(user.sub, createReviewDto);
  }

  @Get('product/:productId')
  findByProduct(
    @Param('productId', ParseIntPipe) productId: number,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page?: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit?: number,
  ) {
    return this.reviewsService.findByProduct(productId, page, limit);
  }
}
