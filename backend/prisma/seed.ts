import 'dotenv/config';
import { PrismaClient, UserRole, BookingStatus, DeliveryMethod, PaymentMethod, PaymentStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' || process.env.DATABASE_URL?.includes('render.com')
    ? { rejectUnauthorized: false }
    : false,
});
const adapter = new PrismaPg(pool as any) as any;
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Suppression des anciennes données...');
  await prisma.cartItem.deleteMany();
  await prisma.cart.deleteMany();
  await prisma.review.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.bookingProduct.deleteMany();
  await prisma.productImage.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.product.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash('password123', 10);

  console.log('Création des utilisateurs...');
  const admin = await prisma.user.create({
    data: {
      user_nom: 'Admin', user_prenom: 'Super', user_email: 'admin@kitsandkids.com', user_password: passwordHash, user_role: UserRole.admin,
    },
  });
  const client1 = await prisma.user.create({
    data: {
      user_nom: 'Dupont', user_prenom: 'Marie', user_email: 'marie.dupont@example.com', user_password: passwordHash, user_role: UserRole.client,
    },
  });
  const client2 = await prisma.user.create({
    data: {
      user_nom: 'Martin', user_prenom: 'Paul', user_email: 'paul.martin@example.com', user_password: passwordHash, user_role: UserRole.client,
    },
  });

  console.log('Création des produits...');
  // 1. Poussette
  const p1 = await prisma.product.create({
    data: {
      products_name: 'Poussette Yoyo 2 Babyzen', products_description: 'Ultra compacte, pliage en 1 seconde, idéale voyage en cabine avion. Légère et maniable en ville.', products_category: 'Poussettes', products_price_per_day: 15.00, products_stock: 5, products_safety_standards: 'EN 1888',
      images: { create: [
        { image_url: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&q=80', image_order: 0 },
        { image_url: 'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?w=800&q=80', image_order: 1 },
      ]},
    },
  });
  // 2. Lit Parapluie (stock 0)
  const p2 = await prisma.product.create({
    data: {
      products_name: 'Lit Parapluie BabyBjörn Light', products_description: 'Très confortable et léger à transporter. Montage rapide sans outils, matelas inclus.', products_category: 'Lits', products_price_per_day: 10.00, products_stock: 0,
      images: { create: [
        { image_url: 'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=800&q=80', image_order: 0 },
        { image_url: 'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=800&q=80', image_order: 1 },
      ]},
    },
  });
  // 3. Chaise Haute (stock faible)
  const p3 = await prisma.product.create({
    data: {
      products_name: 'Chaise Haute Stokke Tripp Trapp', products_description: 'Évolutive et ergonomique, accompagne l\'enfant de 6 mois à l\'âge adulte. Baby set inclus.', products_category: 'Repas', products_price_per_day: 8.00, products_stock: 1,
      images: { create: [
        { image_url: 'https://images.unsplash.com/photo-1566004100631-35d015d6a491?w=800&q=80', image_order: 0 },
        { image_url: 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?w=800&q=80', image_order: 1 },
      ]},
    },
  });
  // 4. Siège Auto
  const p4 = await prisma.product.create({
    data: {
      products_name: 'Siège Auto Cybex Pallas G', products_description: 'Sécurité maximale avec bouclier d\'impact breveté. Convient de 3 mois à 12 ans. Isofix inclus.', products_category: 'Voyage', products_price_per_day: 12.00, products_stock: 10,
      images: { create: [
        { image_url: 'https://images.unsplash.com/photo-1549317336-206569e8475c?w=800&q=80', image_order: 0 },
        { image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80', image_order: 1 },
      ]},
    },
  });
  // 5. Chauffe-biberon
  const p5 = await prisma.product.create({
    data: {
      products_name: 'Chauffe-biberon Philips Avent', products_description: 'Chauffe rapidement et uniformément biberons et petits pots. Compatible toutes marques. Sans BPA.', products_category: 'Repas', products_price_per_day: 3.00, products_stock: 4,
      images: { create: [
        { image_url: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80', image_order: 0 },
        { image_url: 'https://images.unsplash.com/photo-1515488042361-ee00e01ded1e?w=800&q=80', image_order: 1 },
      ]},
    },
  });

  console.log('Création des réservations et des avis...');
  // Booking 1: Terminée (avec review complète ET review sans commentaire)
  const b1 = await prisma.booking.create({
    data: {
      booking_user_id: client1.user_id, booking_start_date: new Date('2026-02-01T10:00:00Z'), booking_end_date: new Date('2026-02-05T10:00:00Z'), booking_total_amount: 5 * 15.00 + 5 * 12.00, booking_status: BookingStatus.terminee, booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: {
        create: [
          { bp_product_id: p1.products_id, bp_quantity: 1, bp_price_snapshot: 15.00 },
          { bp_product_id: p4.products_id, bp_quantity: 1, bp_price_snapshot: 12.00 }
        ],
      },
      payment: {
        create: { payments_amount: 135.00, payments_method: PaymentMethod.carte_bancaire, payments_status: PaymentStatus.valide },
      },
    },
  });

  // Création des reviews pour Booking 1
  // Review normale avec texte
  await prisma.review.create({
    data: { review_booking_id: b1.booking_id, review_product_id: p1.products_id, review_user_id: client1.user_id, review_rating: 5, review_comment: 'Parfait pour notre séjour à Paris ! Matériel très propre.' },
  });
  // Removed Review BIZARRE to respect @unique on review_booking_id

  // Booking 2: En cours (livraison à domicile, aucune review possible car pas terminée)
  await prisma.booking.create({
    data: {
      booking_user_id: client2.user_id, booking_start_date: new Date('2026-03-25T10:00:00Z'), booking_end_date: new Date('2026-04-05T10:00:00Z'), booking_total_amount: 11 * 8.00, booking_status: BookingStatus.en_cours, booking_delivery_method: DeliveryMethod.livraison, booking_delivery_street: '15 rue du Louvre', booking_delivery_city: 'Paris', booking_delivery_zip: '75001',
      products: {
        create: [{ bp_product_id: p3.products_id, bp_quantity: 1, bp_price_snapshot: 8.00 }],
      },
      payment: {
        create: { payments_amount: 88.00, payments_method: PaymentMethod.paypal, payments_status: PaymentStatus.valide },
      },
    },
  });

  // Booking 3: Annulée (avec produit sans image, pas de paiement approuvé)
  await prisma.booking.create({
    data: {
      booking_user_id: client1.user_id, booking_start_date: new Date('2026-03-01T10:00:00Z'), booking_end_date: new Date('2026-03-03T10:00:00Z'), booking_total_amount: 2 * 3.00, booking_status: BookingStatus.annulee, booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: {
        create: [{ bp_product_id: p5.products_id, bp_quantity: 1, bp_price_snapshot: 3.00 }],
      },
    },
  });

  console.log('Génération de la data fictive terminée avec succès !');
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
