import { IsOptional, IsString, MinLength, MaxLength, Matches } from 'class-validator';
import { StripHtml } from '../../common/transforms/strip-html.transform';

export class UpdateUserDto {
  @StripHtml()
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  nom?: string;

  @StripHtml()
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  prenom?: string;

  @IsString()
  @IsOptional()
  birth?: string;

  @IsString()
  @IsOptional()
  @Matches(/^\+?[0-9]{7,15}$/, { message: 'Invalid phone number format' })
  number?: string;
}
