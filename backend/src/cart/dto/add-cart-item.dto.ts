import { IsDateString, IsNumber, Min } from 'class-validator';

export class AddCartItemDto {
  @IsNumber()
  @Min(1)
  cart_item_product_id: number;

  @IsNumber()
  @Min(1)
  cart_item_quantity: number;

  @IsDateString()
  cart_item_start_date: string;

  @IsDateString()
  cart_item_end_date: string;
}
