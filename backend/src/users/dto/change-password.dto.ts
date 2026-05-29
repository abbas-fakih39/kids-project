import { IsString, IsNotEmpty, MinLength, Matches } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty()
  current_password: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @Matches(/(?=.*[A-Z])(?=.*[0-9])/, {
    message: 'Le nouveau mot de passe doit contenir au moins une majuscule et un chiffre',
  })
  new_password: string;
}
