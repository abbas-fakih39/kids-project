import { IsEnum, IsOptional } from 'class-validator';
import { PaymentStatus, PaymentMethod } from '@prisma/client';

export class UpdatePaymentStatusDto {
  @IsEnum(PaymentStatus)
  @IsOptional()
  status?: PaymentStatus;

  @IsEnum(PaymentMethod)
  @IsOptional()
  method?: PaymentMethod;
}
