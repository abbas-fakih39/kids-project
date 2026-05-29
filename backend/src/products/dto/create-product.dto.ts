import { IsString, IsNotEmpty, IsNumber, IsOptional, Min, IsEnum } from 'class-validator';
import { ProductStatus } from '@prisma/client';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  products_name: string;

  @IsString()
  @IsOptional()
  products_description?: string;

  @IsString()
  @IsNotEmpty()
  products_category: string;

  @IsNumber()
  @Min(0.01)
  products_price_per_day: number;

  @IsNumber()
  @Min(0)
  products_stock: number;

  @IsString()
  @IsOptional()
  products_safety_standards?: string;

  @IsEnum(ProductStatus)
  @IsOptional()
  products_status?: ProductStatus;
}
