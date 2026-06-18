import { Test, TestingModule } from '@nestjs/testing';
import { SupportService } from './support.service';
import { PrismaService } from '../prisma/prisma.service';

const mockPrisma = {
  supportRequest: {
    create: jest.fn(),
  },
};

describe('SupportService', () => {
  let service: SupportService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SupportService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<SupportService>(SupportService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('creates a support request and returns success with the new id', async () => {
    mockPrisma.supportRequest.create.mockResolvedValue({ support_id: 42 });

    const result = await service.create({
      email: 'jean@test.fr',
      prenom: 'Jean',
      nom: 'Dupont',
      message: 'Mon problème de réservation',
    });

    expect(result).toEqual({ success: true, id: 42 });
    expect(mockPrisma.supportRequest.create).toHaveBeenCalledWith({
      data: {
        support_email: 'jean@test.fr',
        support_prenom: 'Jean',
        support_nom: 'Dupont',
        support_subject: null,
        support_message: 'Mon problème de réservation',
        support_order_ref: null,
      },
    });
  });

  it('passes subject and order_ref when provided', async () => {
    mockPrisma.supportRequest.create.mockResolvedValue({ support_id: 7 });

    await service.create({
      email: 'a@b.fr',
      prenom: 'A',
      nom: 'B',
      subject: 'Remboursement',
      message: 'Je veux un remboursement',
      order_ref: 'CMD-001',
    });

    expect(mockPrisma.supportRequest.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        support_subject: 'Remboursement',
        support_order_ref: 'CMD-001',
      }),
    });
  });
});
