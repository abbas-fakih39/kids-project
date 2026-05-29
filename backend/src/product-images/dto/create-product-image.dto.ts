import { IsNumber, IsString, IsNotEmpty, IsUrl, Min, IsOptional } from 'class-validator';

export class CreateProductImageDto {
  @IsNumber()
  @Min(1)
  image_products_id: number;

  @IsUrl()
  @IsNotEmpty()
  image_url: string;

  @IsNumber()
  @Min(0)
  @IsOptional()
  image_order?: number;
}
