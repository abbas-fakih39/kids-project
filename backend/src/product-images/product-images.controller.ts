import { Controller, Post, Body, Patch, Param, Delete, UseGuards, ParseIntPipe } from '@nestjs/common';
import { ProductImagesService } from './product-images.service';
import { CreateProductImageDto } from './dto/create-product-image.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.admin)
@Controller('product-images')
export class ProductImagesController {
  constructor(private readonly productImagesService: ProductImagesService) {}

  @Post()
  addImage(@Body() createProductImageDto: CreateProductImageDto) {
    return this.productImagesService.addImage(createProductImageDto);
  }

  @Patch(':id/order')
  reorder(
    @Param('id', ParseIntPipe) id: number,
    @Body('order', ParseIntPipe) order: number,
  ) {
    return this.productImagesService.reorder(id, order);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.productImagesService.remove(id);
  }
}
