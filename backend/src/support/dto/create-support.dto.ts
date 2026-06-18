import { IsEmail, IsString, IsNotEmpty, MaxLength, IsOptional } from 'class-validator';

export class CreateSupportDto {
  @IsEmail()
  email: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  prenom: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nom: string;

  @IsString()
  @IsOptional()
  @MaxLength(255)
  subject?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  message: string;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  order_ref?: string;
}
