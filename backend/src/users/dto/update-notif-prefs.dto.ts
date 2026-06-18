import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateNotifPrefsDto {
  @IsBoolean()
  @IsOptional()
  push?: boolean;

  @IsBoolean()
  @IsOptional()
  promo?: boolean;

  @IsBoolean()
  @IsOptional()
  transactional?: boolean;
}
