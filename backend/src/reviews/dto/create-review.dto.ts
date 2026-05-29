import { IsNumber, IsInt, IsString, Min, Max, IsOptional, MaxLength } from 'class-validator';
import { StripHtml } from '../../common/transforms/strip-html.transform';

export class CreateReviewDto {
  @IsNumber()
  @Min(1)
  review_booking_id: number;

  @IsNumber()
  @Min(1)
  review_product_id: number;

  @IsInt()
  @Min(1)
  @Max(5)
  review_rating: number;

  @StripHtml()
  @IsString()
  @IsOptional()
  @MaxLength(1000)
  review_comment?: string;
}
