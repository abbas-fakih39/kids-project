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

  // ── POUSSETTES (5) ────────────────────────────────────────────
  const p1 = await prisma.product.create({ data: {
    products_name: 'Poussette Babyzen Yoyo 2',
    products_description: 'Ultra compacte, pliage en 1 seconde, acceptée en cabine avion. Légère (6 kg), maniable en ville et parfaite pour les voyages.',
    products_category: 'Poussettes', products_price_per_day: 15.00, products_stock: 5, products_safety_standards: 'EN 1888',
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p2 = await prisma.product.create({ data: {
    products_name: 'Poussette Bugaboo Butterfly',
    products_description: 'Pliage compact en une main, légère et maniable. Assise confortable, réglable en hauteur. Idéale pour les parents actifs.',
    products_category: 'Poussettes', products_price_per_day: 18.00, products_stock: 3,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p3 = await prisma.product.create({ data: {
    products_name: 'Poussette Joie Pact Flex',
    products_description: 'Poussette compacte avec siège réversible. Pliage facile, s\'autoporte une fois pliée. Compatibilité siège auto.',
    products_category: 'Poussettes', products_price_per_day: 10.00, products_stock: 6,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1590736704728-f4730bb30770?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p4 = await prisma.product.create({ data: {
    products_name: 'Poussette Trio Chicco Mysa',
    products_description: 'Système trio complet : cosy, nacelle et siège. Pliage compact, grande capote soleil. Poignée ergonomique réglable.',
    products_category: 'Poussettes', products_price_per_day: 14.00, products_stock: 4,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1544776193-352d25ca82cd?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p5 = await prisma.product.create({ data: {
    products_name: 'Poussette Maxi-Cosi Lara²',
    products_description: 'Ultra légère (4,5 kg), tient dans un sac à dos. Parfaite pour les voyages et l\'avion. Assise inclinable.',
    products_category: 'Poussettes', products_price_per_day: 12.00, products_stock: 5,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=800&q=80', image_order: 0 },
    ]},
  }});

  // ── LITS (4) ──────────────────────────────────────────────────
  const p6 = await prisma.product.create({ data: {
    products_name: 'Lit Parapluie BabyBjörn Light',
    products_description: 'Très confortable et léger à transporter. Montage rapide sans outils, matelas inclus. Normes EU strictes.',
    products_category: 'Lits', products_price_per_day: 10.00, products_stock: 0,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p7 = await prisma.product.create({ data: {
    products_name: 'Berceau Cododo Chicco Next2Me Magic',
    products_description: 'Berceau qui s\'attache au lit parental. Idéal pour l\'allaitement nocturne. 5 hauteurs réglables, filet de ventilation.',
    products_category: 'Lits', products_price_per_day: 12.00, products_stock: 3,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1519689373023-dd07c7988603?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p8 = await prisma.product.create({ data: {
    products_name: 'Lit Bébé Stokke Sleepi Mini',
    products_description: 'Design ovale breveté, aucun coin dangereux. Évolutif : mini puis lit standard. Matériaux naturels certifiés.',
    products_category: 'Lits', products_price_per_day: 14.00, products_stock: 2,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1617575521317-d6234c3cce54?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p9 = await prisma.product.create({ data: {
    products_name: 'Couffin Moses Basket Naturel',
    products_description: 'Couffin tressé naturel avec matelas ferme. Léger et transportable d\'une pièce à l\'autre. Housses lavables incluses.',
    products_category: 'Lits', products_price_per_day: 6.00, products_stock: 5,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1586375300773-8384e3e4916f?w=800&q=80', image_order: 0 },
    ]},
  }});

  // ── REPAS (4) ─────────────────────────────────────────────────
  const p10 = await prisma.product.create({ data: {
    products_name: 'Chaise Haute Stokke Tripp Trapp',
    products_description: 'Évolutive et ergonomique, accompagne l\'enfant de 6 mois à l\'âge adulte. Baby set et plateau inclus.',
    products_category: 'Repas', products_price_per_day: 8.00, products_stock: 1,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1566004100631-35d015d6a491?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p11 = await prisma.product.create({ data: {
    products_name: 'Chaise Haute Chicco Polly Magic Relax',
    products_description: 'Chaise évolutive 3 en 1 : transat, chaise haute, chaise enfant. Dossier inclinable, harnais 5 points.',
    products_category: 'Repas', products_price_per_day: 7.00, products_stock: 4,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p12 = await prisma.product.create({ data: {
    products_name: 'Chauffe-biberon Philips Avent',
    products_description: 'Chauffe rapidement et uniformément biberons et petits pots. Compatible toutes marques. Sans BPA.',
    products_category: 'Repas', products_price_per_day: 3.00, products_stock: 4,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p13 = await prisma.product.create({ data: {
    products_name: 'Stérilisateur Vapeur Philips Avent',
    products_description: 'Stérilise 6 biberons en 6 minutes. Garde stérile jusqu\'à 24h. Compatible micro-ondes. Inclus : pince et brosse.',
    products_category: 'Repas', products_price_per_day: 4.00, products_stock: 6,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1515488042361-ee00e01ded1e?w=800&q=80', image_order: 0 },
    ]},
  }});

  // ── SIÈGES AUTO (4) ───────────────────────────────────────────
  const p14 = await prisma.product.create({ data: {
    products_name: 'Siège Auto Cybex Pallas G',
    products_description: 'Sécurité maximale avec bouclier d\'impact breveté. Convient de 3 mois à 12 ans. Isofix inclus. Norme i-Size.',
    products_category: 'Sièges auto', products_price_per_day: 12.00, products_stock: 10,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1549317336-206569e8475c?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p15 = await prisma.product.create({ data: {
    products_name: 'Siège Auto Maxi-Cosi Pebble 360 Pro',
    products_description: 'Rotation 360° pour installation facile. Dos à la route jusqu\'à 15 mois. Compatible FamilyFix 360. Norme i-Size.',
    products_category: 'Sièges auto', products_price_per_day: 14.00, products_stock: 4,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p16 = await prisma.product.create({ data: {
    products_name: 'Siège Auto Joie i-Spin Safe',
    products_description: 'Rotation 360° avec protection anti-recul intégrée. Dos à la route jusqu\'à 4 ans. Hamac de couchage inclinable.',
    products_category: 'Sièges auto', products_price_per_day: 10.00, products_stock: 5,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1562887245-e8bc77d0fd27?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p17 = await prisma.product.create({ data: {
    products_name: 'Siège Auto BeSafe iZi Turn M i-Size',
    products_description: 'Siège rotatif premium avec coque interchangeable. Protection SIP+ latérale brevetée. De la naissance à 18 kg.',
    products_category: 'Sièges auto', products_price_per_day: 16.00, products_stock: 3,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80', image_order: 0 },
    ]},
  }});

  // ── JOUETS (4) ────────────────────────────────────────────────
  const p18 = await prisma.product.create({ data: {
    products_name: 'Tapis d\'Éveil Fisher-Price Deluxe',
    products_description: 'Tapis d\'activités avec arche musicale, miroir et jouets suspendus. Stimule l\'éveil sensoriel. Dès la naissance.',
    products_category: 'Jouets', products_price_per_day: 4.00, products_stock: 8,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p19 = await prisma.product.create({ data: {
    products_name: 'Balancelle BabyBjörn Bouncer Bliss',
    products_description: 'Balancelle légère et portable, fonctionne avec les mouvements du bébé. Design ergonomique, tissu 3D lavable.',
    products_category: 'Jouets', products_price_per_day: 8.00, products_stock: 5,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1553395572-0ef353d9f229?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p20 = await prisma.product.create({ data: {
    products_name: 'Transat Babymoov Swoon Up',
    products_description: 'Transat évolutif 5 en 1 avec balancement automatique. Musique et vibrations intégrées. Réglable en hauteur.',
    products_category: 'Jouets', products_price_per_day: 6.00, products_stock: 4,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1515488042361-ee00e01ded1e?w=800&q=80', image_order: 0 },
    ]},
  }});

  const p21 = await prisma.product.create({ data: {
    products_name: 'Mobile Musical Tiny Love Meadow Days',
    products_description: 'Mobile avec 3 modes de jeu, 18 mélodies et lumières LED. Bras articulé rotatif, fixation universelle.',
    products_category: 'Jouets', products_price_per_day: 3.00, products_stock: 7,
    images: { create: [
      { image_url: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=800&q=80', image_order: 0 },
    ]},
  }});

  console.log('Création des réservations et des avis...');
  // Booking 1: Terminée (avec review complète ET review sans commentaire)
  const b1 = await prisma.booking.create({
    data: {
      booking_user_id: client1.user_id, booking_start_date: new Date('2026-02-01T10:00:00Z'), booking_end_date: new Date('2026-02-05T10:00:00Z'), booking_total_amount: 5 * 15.00 + 5 * 12.00, booking_status: BookingStatus.terminee, booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: {
        create: [
          { bp_product_id: p1.products_id, bp_quantity: 1, bp_price_snapshot: 15.00 },
          { bp_product_id: p14.products_id, bp_quantity: 1, bp_price_snapshot: 12.00 }
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
    data: { review_booking_id: b1.booking_id, review_product_id: p1.products_id, review_user_id: client1.user_id, review_rating: 5, review_comment: 'Parfaite pour notre séjour à Paris ! Très légère et pratique.' },
  });
  // Removed Review BIZARRE to respect @unique on review_booking_id

  // Booking 2: En cours (livraison à domicile, aucune review possible car pas terminée)
  await prisma.booking.create({
    data: {
      booking_user_id: client2.user_id, booking_start_date: new Date('2026-03-25T10:00:00Z'), booking_end_date: new Date('2026-04-05T10:00:00Z'), booking_total_amount: 11 * 8.00, booking_status: BookingStatus.en_cours, booking_delivery_method: DeliveryMethod.livraison, booking_delivery_street: '15 rue du Louvre', booking_delivery_city: 'Paris', booking_delivery_zip: '75001',
      products: {
        create: [{ bp_product_id: p10.products_id, bp_quantity: 1, bp_price_snapshot: 8.00 }],
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
        create: [{ bp_product_id: p12.products_id, bp_quantity: 1, bp_price_snapshot: 3.00 }],
      },
    },
  });

  console.log('Génération de la data fictive terminée avec succès !');
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
