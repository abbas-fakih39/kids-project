import { IsEmail, IsNotEmpty, IsString, IsOptional, MinLength, MaxLength, Matches, IsDateString } from 'class-validator';
import { Transform } from 'class-transformer';
import { StripHtml } from '../../common/transforms/strip-html.transform';

export class RegisterDto {
  @StripHtml()
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(100)
  nom: string;

  @StripHtml()
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(100)
  prenom: string;

  @IsDateString()
  @IsOptional()
  birth?: string;

  @Transform(({ value }) => (typeof value === 'string' ? value.toLowerCase().trim() : value))
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsOptional()
  @Matches(/^\+?[0-9]{7,15}$/, { message: 'Invalid phone number format' })
  number?: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @Matches(/(?=.*[A-Z])(?=.*[0-9])/, {
    message: 'Le mot de passe doit contenir au moins une majuscule et un chiffre',
  })
  password: string;
}
