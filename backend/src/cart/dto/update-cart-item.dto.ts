import { IsDateString, IsNumber, Min, IsOptional } from 'class-validator';

export class UpdateCartItemDto {
  @IsNumber()
  @Min(1)
  @IsOptional()
  cart_item_quantity?: number;

  @IsDateString()
  @IsOptional()
  cart_item_start_date?: string;

  @IsDateString()
  @IsOptional()
  cart_item_end_date?: string;
}
