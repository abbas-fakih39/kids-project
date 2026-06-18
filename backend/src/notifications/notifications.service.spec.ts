import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsService } from './notifications.service';

describe('NotificationsService', () => {
  let service: NotificationsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [NotificationsService],
    }).compile();
    service = module.get<NotificationsService>(NotificationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('skips silently when FCM_SERVER_KEY is not set', async () => {
    const fetchSpy = jest.spyOn(global, 'fetch');
    await service.sendToToken('device-token', 'Test', 'Hello');
    expect(fetchSpy).not.toHaveBeenCalled();
  });
});
