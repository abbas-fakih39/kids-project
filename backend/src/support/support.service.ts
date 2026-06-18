import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSupportDto } from './dto/create-support.dto';

@Injectable()
export class SupportService {
  private readonly logger = new Logger(SupportService.name);

  constructor(private prisma: PrismaService) {}

  async create(dto: CreateSupportDto) {
    const request = await this.prisma.supportRequest.create({
      data: {
        support_email: dto.email,
        support_prenom: dto.prenom,
        support_nom: dto.nom,
        support_subject: dto.subject ?? null,
        support_message: dto.message,
        support_order_ref: dto.order_ref ?? null,
      },
    });
    this.logger.log(`Support request #${request.support_id} from ${dto.email}`);
    return { success: true, id: request.support_id };
  }
}
