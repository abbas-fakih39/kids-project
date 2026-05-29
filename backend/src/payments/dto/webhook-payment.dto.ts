import { IsString, IsNotEmpty, IsInt, IsOptional, Min } from 'class-validator';

export class WebhookPaymentDto {
  @IsString()
  @IsNotEmpty()
  event_type: string;

  @IsInt()
  @Min(1)
  payment_id: number;

  @IsString()
  @IsOptional()
  provider_reference?: string;
}
