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

// ─── Catalog data (mirrors localfiles/image-seed-idea.json) ───────────────────

const CATALOG = [
  {
    name: 'Poussettes', slug: 'poussettes', order: 1,
    products: [
      {
        name: 'Poussette Babyzen Yoyo 2',
        description: 'Ultra compacte, pliage en 1 seconde, acceptée en cabine avion. Légère (6 kg), maniable en ville et parfaite pour les voyages.',
        price: 15.00, stock: 5, safety: 'EN 1888',
        imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&q=80',
      },
      {
        name: 'Poussette Bugaboo Butterfly',
        description: 'Pliage compact en une main, légère et maniable. Assise confortable, réglable en hauteur. Idéale pour les parents actifs.',
        price: 18.00, stock: 3,
        imageUrl: 'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?w=800&q=80',
      },
      {
        name: 'Poussette Joie Pact Flex',
        description: 'Poussette compacte avec siège réversible. Pliage facile, s\'autoporte une fois pliée. Compatibilité siège auto.',
        price: 10.00, stock: 6,
        imageUrl: 'https://images.unsplash.com/photo-1590736704728-f4730bb30770?w=800&q=80',
      },
      {
        name: 'Poussette Trio Chicco Mysa',
        description: 'Système trio complet : cosy, nacelle et siège. Pliage compact, grande capote soleil. Poignée ergonomique réglable.',
        price: 14.00, stock: 4,
        imageUrl: 'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=800&q=80',
      },
      {
        name: 'Poussette Maxi-Cosi Lara²',
        description: 'Ultra légère (4,5 kg), tient dans un sac à dos. Parfaite pour les voyages et l\'avion. Assise inclinable.',
        price: 12.00, stock: 5,
        imageUrl: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=800&q=80',
      },
    ],
  },
  {
    name: 'Lits', slug: 'lits', order: 2,
    products: [
      {
        name: 'Lit Parapluie BabyBjörn Light',
        description: 'Très confortable et léger à transporter. Montage rapide sans outils, matelas inclus. Normes EU strictes.',
        price: 10.00, stock: 0,
        imageUrl: 'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=800&q=80',
      },
      {
        name: 'Berceau Cododo Chicco Next2Me Magic',
        description: 'Berceau qui s\'attache au lit parental. Idéal pour l\'allaitement nocturne. 5 hauteurs réglables, filet de ventilation.',
        price: 12.00, stock: 3,
        imageUrl: 'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=800&q=80',
      },
      {
        name: 'Lit Bébé Stokke Sleepi Mini',
        description: 'Design ovale breveté, aucun coin dangereux. Évolutif : mini puis lit standard. Matériaux naturels certifiés.',
        price: 14.00, stock: 2,
        imageUrl: 'https://images.unsplash.com/photo-1617575521317-d6234c3cce54?w=800&q=80',
      },
      {
        name: 'Couffin Moses Basket Naturel',
        description: 'Couffin tressé naturel avec matelas ferme. Léger et transportable d\'une pièce à l\'autre. Housses lavables incluses.',
        price: 6.00, stock: 5,
        imageUrl: 'https://images.unsplash.com/photo-1586375300773-8384e3e4916f?w=800&q=80',
      },
    ],
  },
  {
    name: 'Repas', slug: 'repas', order: 3,
    products: [
      {
        name: 'Chaise Haute Stokke Tripp Trapp',
        description: 'Évolutive et ergonomique, accompagne l\'enfant de 6 mois à l\'âge adulte. Baby set et plateau inclus.',
        price: 8.00, stock: 1,
        imageUrl: 'https://images.unsplash.com/photo-1566004100631-35d015d6a491?w=800&q=80',
      },
      {
        name: 'Chaise Haute Chicco Polly Magic Relax',
        description: 'Chaise évolutive 3 en 1 : transat, chaise haute, chaise enfant. Dossier inclinable, harnais 5 points.',
        price: 7.00, stock: 4,
        imageUrl: 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?w=800&q=80',
      },
      {
        name: 'Chauffe-biberon Philips Avent',
        description: 'Chauffe rapidement et uniformément biberons et petits pots. Compatible toutes marques. Sans BPA.',
        price: 3.00, stock: 4,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80',
      },
      {
        name: 'Stérilisateur Vapeur Philips Avent',
        description: 'Stérilise 6 biberons en 6 minutes. Garde stérile jusqu\'à 24h. Compatible micro-ondes. Inclus : pince et brosse.',
        price: 4.00, stock: 6,
        imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e01ded1e?w=800&q=80',
      },
    ],
  },
  {
    name: 'Sièges auto', slug: 'sieges-auto', order: 4,
    products: [
      {
        name: 'Siège Auto Cybex Pallas G',
        description: 'Sécurité maximale avec bouclier d\'impact breveté. Convient de 3 mois à 12 ans. Isofix inclus. Norme i-Size.',
        price: 12.00, stock: 10, safety: 'i-Size ECE R129',
        imageUrl: 'https://images.unsplash.com/photo-1549317336-206569e8475c?w=800&q=80',
      },
      {
        name: 'Siège Auto Maxi-Cosi Pebble 360 Pro',
        description: 'Rotation 360° pour installation facile. Dos à la route jusqu\'à 15 mois. Compatible FamilyFix 360. Norme i-Size.',
        price: 14.00, stock: 4, safety: 'i-Size ECE R129',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
      },
      {
        name: 'Siège Auto Joie i-Spin Safe',
        description: 'Rotation 360° avec protection anti-recul intégrée. Dos à la route jusqu\'à 4 ans. Hamac de couchage inclinable.',
        price: 10.00, stock: 5, safety: 'i-Size ECE R129',
        imageUrl: 'https://images.unsplash.com/photo-1562887245-e8bc77d0fd27?w=800&q=80',
      },
      {
        name: 'Siège Auto BeSafe iZi Turn M i-Size',
        description: 'Siège rotatif premium avec coque interchangeable. Protection SIP+ latérale brevetée. De la naissance à 18 kg.',
        price: 16.00, stock: 3, safety: 'i-Size ECE R129',
        imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
      },
    ],
  },
  {
    name: 'Jouets', slug: 'jouets', order: 5,
    products: [
      {
        name: 'Tapis d\'Éveil Fisher-Price Deluxe',
        description: 'Tapis d\'activités avec arche musicale, miroir et jouets suspendus. Stimule l\'éveil sensoriel. Dès la naissance.',
        price: 4.00, stock: 8,
        imageUrl: 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=800&q=80',
      },
      {
        name: 'Balancelle BabyBjörn Bouncer Bliss',
        description: 'Balancelle légère et portable, fonctionne avec les mouvements du bébé. Design ergonomique, tissu 3D lavable.',
        price: 8.00, stock: 5,
        imageUrl: 'https://images.unsplash.com/photo-1553395572-0ef353d9f229?w=800&q=80',
      },
      {
        name: 'Transat Babymoov Swoon Up',
        description: 'Transat évolutif 5 en 1 avec balancement automatique. Musique et vibrations intégrées. Réglable en hauteur.',
        price: 6.00, stock: 4,
        imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e01ded1e?w=800&q=80',
      },
      {
        name: 'Mobile Musical Tiny Love Meadow Days',
        description: 'Mobile avec 3 modes de jeu, 18 mélodies et lumières LED. Bras articulé rotatif, fixation universelle.',
        price: 3.00, stock: 7,
        imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=800&q=80',
      },
    ],
  },
];

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
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  const passwordHash = await bcrypt.hash('password123', 10);

  console.log('Création des utilisateurs...');
  const admin = await prisma.user.create({
    data: {
      user_nom: 'Admin', user_prenom: 'Super',
      user_email: 'admin@kitsandkids.com',
      user_password: passwordHash, user_role: UserRole.admin,
    },
  });
  const client1 = await prisma.user.create({
    data: {
      user_nom: 'Dupont', user_prenom: 'Marie',
      user_email: 'marie.dupont@example.com',
      user_password: passwordHash, user_role: UserRole.client,
    },
  });
  const client2 = await prisma.user.create({
    data: {
      user_nom: 'Martin', user_prenom: 'Paul',
      user_email: 'paul.martin@example.com',
      user_password: passwordHash, user_role: UserRole.client,
    },
  });

  console.log('Création des catégories et des produits...');

  // Track created products for bookings
  const createdProducts: Record<string, any> = {};

  for (const cat of CATALOG) {
    const category = await prisma.category.create({
      data: { cat_name: cat.name, cat_slug: cat.slug, cat_order: cat.order },
    });

    for (const p of cat.products) {
      const product = await prisma.product.create({
        data: {
          products_name:             p.name,
          products_description:      p.description,
          products_category:         cat.name,
          products_category_id:      category.cat_id,
          products_image_url:        p.imageUrl,
          products_price_per_day:    p.price,
          products_stock:            p.stock,
          products_safety_standards: (p as any).safety ?? null,
          images: { create: [{ image_url: p.imageUrl, image_order: 0 }] },
        },
      });
      // Key by name for booking references below
      createdProducts[p.name] = product;
    }
  }

  // Convenience aliases used in bookings
  const p1  = createdProducts['Poussette Babyzen Yoyo 2'];
  const p10 = createdProducts['Chaise Haute Stokke Tripp Trapp'];
  const p12 = createdProducts['Chauffe-biberon Philips Avent'];
  const p14 = createdProducts['Siège Auto Cybex Pallas G'];

  console.log('Création des réservations et des avis...');

  const b1 = await prisma.booking.create({
    data: {
      booking_user_id:        client1.user_id,
      booking_start_date:     new Date('2026-02-01T10:00:00Z'),
      booking_end_date:       new Date('2026-02-05T10:00:00Z'),
      booking_total_amount:   5 * 15.00 + 5 * 12.00,
      booking_status:         BookingStatus.terminee,
      booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: {
        create: [
          { bp_product_id: p1.products_id,  bp_quantity: 1, bp_price_snapshot: 15.00 },
          { bp_product_id: p14.products_id, bp_quantity: 1, bp_price_snapshot: 12.00 },
        ],
      },
      payment: {
        create: {
          payments_amount: 135.00,
          payments_method: PaymentMethod.carte_bancaire,
          payments_status: PaymentStatus.valide,
        },
      },
    },
  });

  await prisma.review.create({
    data: {
      review_booking_id:  b1.booking_id,
      review_product_id:  p1.products_id,
      review_user_id:     client1.user_id,
      review_rating:      5,
      review_comment:     'Parfaite pour notre séjour à Paris ! Très légère et pratique.',
    },
  });

  await prisma.booking.create({
    data: {
      booking_user_id:         client2.user_id,
      booking_start_date:      new Date('2026-03-25T10:00:00Z'),
      booking_end_date:        new Date('2026-04-05T10:00:00Z'),
      booking_total_amount:    11 * 8.00,
      booking_status:          BookingStatus.en_cours,
      booking_delivery_method: DeliveryMethod.livraison,
      booking_delivery_street: '15 rue du Louvre',
      booking_delivery_city:   'Paris',
      booking_delivery_zip:    '75001',
      products: {
        create: [{ bp_product_id: p10.products_id, bp_quantity: 1, bp_price_snapshot: 8.00 }],
      },
      payment: {
        create: {
          payments_amount: 88.00,
          payments_method: PaymentMethod.paypal,
          payments_status: PaymentStatus.valide,
        },
      },
    },
  });

  await prisma.booking.create({
    data: {
      booking_user_id:         client1.user_id,
      booking_start_date:      new Date('2026-03-01T10:00:00Z'),
      booking_end_date:        new Date('2026-03-03T10:00:00Z'),
      booking_total_amount:    2 * 3.00,
      booking_status:          BookingStatus.annulee,
      booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: {
        create: [{ bp_product_id: p12.products_id, bp_quantity: 1, bp_price_snapshot: 3.00 }],
      },
    },
  });

  console.log('Génération de la data fictive terminée avec succès !');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
