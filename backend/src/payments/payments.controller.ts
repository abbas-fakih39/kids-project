import { Controller, Get, Post, Body, Patch, Param, UseGuards, ParseIntPipe, Headers, Req } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { UpdatePaymentStatusDto } from './dto/update-payment-status.dto';
import { WebhookPaymentDto } from './dto/webhook-payment.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('webhook')
  handleWebhook(
    @Req() req: any,
    @Body() webhookDto: WebhookPaymentDto,
    @Headers('x-webhook-signature') signature: string | undefined,
  ) {
    const rawBody: Buffer = (req.rawBody as Buffer) ?? Buffer.alloc(0);
    return this.paymentsService.handleWebhook(rawBody, webhookDto, signature);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Get('booking/:bookingId')
  findByBooking(@Param('bookingId', ParseIntPipe) bookingId: number, @CurrentUser() user: any) {
    return this.paymentsService.findByBooking(bookingId, user.sub, user.role);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  @Patch(':id/status')
  updateStatus(@Param('id', ParseIntPipe) id: number, @Body() updatePaymentStatusDto: UpdatePaymentStatusDto) {
    return this.paymentsService.updateStatus(id, updatePaymentStatusDto);
  }
}
