import { IsOptional, IsString, IsNumber, Min, IsEnum } from 'class-validator';
import { ProductStatus } from '@prisma/client';

export class UpdateProductDto {
  @IsString()
  @IsOptional()
  products_name?: string;

  @IsString()
  @IsOptional()
  products_description?: string;

  @IsString()
  @IsOptional()
  products_category?: string;

  @IsNumber()
  @Min(0.01)
  @IsOptional()
  products_price_per_day?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  products_stock?: number;

  @IsString()
  @IsOptional()
  products_safety_standards?: string;

  @IsEnum(ProductStatus)
  @IsOptional()
  products_status?: ProductStatus;
}
