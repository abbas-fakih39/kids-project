import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly serverKey = process.env.FCM_SERVER_KEY ?? null;

  async sendToToken(token: string, title: string, body: string, data?: Record<string, string>): Promise<void> {
    if (!this.serverKey) {
      this.logger.debug(`FCM not configured — skipping notification: "${title}"`);
      return;
    }
    try {
      const res = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Authorization': `key=${this.serverKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          to: token,
          notification: { title, body },
          data: data ?? {},
        }),
      });
      if (!res.ok) {
        this.logger.warn(`FCM send failed: ${res.status} ${await res.text()}`);
      }
    } catch (err: any) {
      this.logger.warn(`FCM send error: ${err?.message}`);
    }
  }
}
