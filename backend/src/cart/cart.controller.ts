import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, ParseIntPipe } from '@nestjs/common';
import { CartService } from './cart.service';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@UseGuards(JwtAuthGuard)
@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  getCart(@CurrentUser() user: any) {
    return this.cartService.getCart(user.sub);
  }

  @Post('items')
  addItem(@CurrentUser() user: any, @Body() addCartItemDto: AddCartItemDto) {
    return this.cartService.addItem(user.sub, addCartItemDto);
  }

  @Patch('items/:id')
  updateItem(
    @CurrentUser() user: any,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateCartItemDto: UpdateCartItemDto,
  ) {
    return this.cartService.updateItem(user.sub, id, updateCartItemDto);
  }

  @Delete('items/:id')
  removeItem(@CurrentUser() user: any, @Param('id', ParseIntPipe) id: number) {
    return this.cartService.removeItem(user.sub, id);
  }

  @Delete()
  clearCart(@CurrentUser() user: any) {
    return this.cartService.clearCart(user.sub);
  }
}
