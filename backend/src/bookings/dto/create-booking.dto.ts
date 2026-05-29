import { IsDateString, IsEnum, IsNumber, IsOptional, IsString, ValidateNested, IsArray, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { DeliveryMethod, PaymentMethod } from '@prisma/client';

export class BookingItemDto {
  @IsNumber()
  @Min(1)
  bp_product_id: number;

  @IsNumber()
  @Min(1)
  bp_quantity: number;
}

export class CreateBookingDto {
  @IsDateString()
  booking_start_date: string;

  @IsDateString()
  booking_end_date: string;

  @IsEnum(DeliveryMethod)
  booking_delivery_method: DeliveryMethod;

  @IsString()
  @IsOptional()
  booking_delivery_street?: string;

  @IsString()
  @IsOptional()
  booking_delivery_city?: string;

  @IsString()
  @IsOptional()
  booking_delivery_zip?: string;

  @IsString()
  @IsOptional()
  booking_delivery_country?: string;

  @IsEnum(PaymentMethod)
  @IsOptional()
  booking_payment_method?: PaymentMethod;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => BookingItemDto)
  items: BookingItemDto[];
}
