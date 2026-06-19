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
        imageUrl: 'https://www.stokke.com/on/demandware.static/-/Library-Sites-StokkeSharedLibrary/default/dw00996f67/cms_assets/yoyo6m_jpg__size-xl.jpg',
      },
      {
        name: 'Poussette Bugaboo Butterfly',
        description: 'Pliage compact en une main, légère et maniable. Assise confortable, réglable en hauteur. Idéale pour les parents actifs.',
        price: 18.00, stock: 3,
        imageUrl: 'https://www.bugaboo.com/dw/image/v2/BDLP_PRD/on/demandware.static/-/Sites-bugaboo-master/default/dw25b5e3a4/images/PV007669/Bugaboo-Butterfly-2-travel-stroller-black-base-heritage-black-fabrics-heritage-black-sun-canopy-x-PV007669-01.png',
      },
      {
        name: 'Poussette Joie Pact Flex',
        description: 'Poussette compacte avec siège réversible. Pliage facile, s\'autoporte une fois pliée. Compatibilité siège auto.',
        price: 10.00, stock: 6,
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/joie-pact-flex.jpg',
      },
      {
        name: 'Poussette Trio Chicco Mysa',
        description: 'Système trio complet : cosy, nacelle et siège. Pliage compact, grande capote soleil. Poignée ergonomique réglable.',
        price: 14.00, stock: 4,
        imageUrl: 'https://cdn.artsana.com/assets/chicco/images/00011710000000_000_01_08702687122082401_1280x1280.jpg',
      },
      {
        name: 'Poussette Maxi-Cosi Lara²',
        description: 'Ultra légère (4,5 kg), tient dans un sac à dos. Parfaite pour les voyages et l\'avion. Assise inclinable.',
        price: 12.00, stock: 5,
        imageUrl: 'https://images.maxi-cosi.com/dorel-public-storage-prod/catalog/product/cache/74c1057f7991b4edb2bc7bdaa94de933/1/2/1233029110_2023_maxicosi_stroller_ultracompact_lara2_grey_selectgrey_3qrtleft.png',
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
        imageUrl: 'https://a.storyblok.com/f/187315/1667x2500/6b22e7f46e/babybjorn-travelcrib-light-silver-mesh-040948-001.png',
      },
      {
        name: 'Berceau Cododo Chicco Next2Me Magic',
        description: 'Berceau qui s\'attache au lit parental. Idéal pour l\'allaitement nocturne. 5 hauteurs réglables, filet de ventilation.',
        price: 12.00, stock: 3,
        imageUrl: 'https://www.mamasandpapas.com/cdn/shop/files/chicco-bedside-sleeping-chicco-next2me-magic-evo-bedside-crib-dark-grey-62214440911185.jpg?v=1726321045&width=1000',
      },
      {
        name: 'Lit Bébé Stokke Sleepi Mini',
        description: 'Design ovale breveté, aucun coin dangereux. Évolutif : mini puis lit standard. Matériaux naturels certifiés.',
        price: 14.00, stock: 2,
        imageUrl: 'https://www.stokke.com/dw/image/v2/AAQF_PRD/on/demandware.static/-/Sites-stokke-master-catalog/default/dwf59fd539/images/inriverimages/mainview/Sleepi-Mini_Natural_5067_eCom.jpg',
      },
      {
        name: 'Couffin Moses Basket Naturel',
        description: 'Couffin tressé naturel avec matelas ferme. Léger et transportable d\'une pièce à l\'autre. Housses lavables incluses.',
        price: 6.00, stock: 5,
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/couffin-moses-basket.jpg',
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
        imageUrl: 'https://www.stokke.com/dw/image/v2/AAQF_PRD/on/demandware.static/-/Sites-stokke-master-catalog/default/dw660bb2ae/images/inriverimages/mainview/TrippTrapp_Natural_2-8_SP.jpg',
      },
      {
        name: 'Chaise Haute Chicco Polly Magic Relax',
        description: 'Chaise évolutive 3 en 1 : transat, chaise haute, chaise enfant. Dossier inclinable, harnais 5 points.',
        price: 7.00, stock: 4,
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/chicco-polly-magic-relax.jpg',
      },
      {
        name: 'Chauffe-biberon Philips Avent',
        description: 'Chauffe rapidement et uniformément biberons et petits pots. Compatible toutes marques. Sans BPA.',
        price: 3.00, stock: 4,
        imageUrl: 'https://images.philips.com/is/image/philipsconsumer/d5a98e72b93d4a4793c0ac5800a2195b?$png$&wid=410&hei=410',
      },
      {
        name: 'Stérilisateur Vapeur Philips Avent',
        description: 'Stérilise 6 biberons en 6 minutes. Garde stérile jusqu\'à 24h. Compatible micro-ondes. Inclus : pince et brosse.',
        price: 4.00, stock: 6,
        imageUrl: 'https://images.philips.com/is/image/philipsconsumer/a70bcf41d0ff4eb88355ac5400d4f758?wid=700&hei=700&$pnglarge$',
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
        imageUrl: 'https://www.pushchairexpert.com/cdn/shop/files/Pallas-G-Moon-Black.jpg?v=1724760548&width=1214',
      },
      {
        name: 'Siège Auto Maxi-Cosi Pebble 360 Pro',
        description: 'Rotation 360° pour installation facile. Dos à la route jusqu\'à 15 mois. Compatible FamilyFix 360. Norme i-Size.',
        price: 14.00, stock: 4, safety: 'i-Size ECE R129',
        imageUrl: 'https://images.maxi-cosi.com/dorel-public-storage-prod/catalog/product/cache/74c1057f7991b4edb2bc7bdaa94de933/8/0/8052470301_2024_maxicosi_carseat_babycarseat_pebble360pro2_brown_twillictruffle_3qrtleft.png',
      },
      {
        name: 'Siège Auto Joie i-Spin Safe',
        description: 'Rotation 360° avec protection anti-recul intégrée. Dos à la route jusqu\'à 4 ans. Hamac de couchage inclinable.',
        price: 10.00, stock: 5, safety: 'i-Size ECE R129',
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/joie-i-spin-safe.jpg',
      },
      {
        name: 'Siège Auto BeSafe iZi Turn M i-Size',
        description: 'Siège rotatif premium avec coque interchangeable. Protection SIP+ latérale brevetée. De la naissance à 18 kg.',
        price: 16.00, stock: 3, safety: 'i-Size ECE R129',
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/besafe-izi-turn-m.jpg',
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
        imageUrl: 'https://images.mattel.net/image/upload/w_646,f_auto,c_scale/shop-us-prod/files/3a9d9b6f48985eb693a52d70d8a60334a1826214.jpg',
      },
      {
        name: 'Balancelle BabyBjörn Bouncer Bliss',
        description: 'Balancelle légère et portable, fonctionne avec les mouvements du bébé. Design ergonomique, tissu 3D lavable.',
        price: 8.00, stock: 5,
        imageUrl: 'https://a.storyblok.com/f/187315/1667x2500/f252633f18/us-006033-bouncer-bliss-blue-woven-melange-pp-babybjorn-01.png',
      },
      {
        name: 'Transat Babymoov Swoon Up',
        description: 'Transat évolutif 5 en 1 avec balancement automatique. Musique et vibrations intégrées. Réglable en hauteur.',
        price: 6.00, stock: 4,
        imageUrl: 'https://babymoov.com/cdn/shop/products/SWOON-UP.png?v=1679913252&width=500',
      },
      {
        name: 'Mobile Musical Tiny Love Meadow Days',
        description: 'Mobile avec 3 modes de jeu, 18 mélodies et lumières LED. Bras articulé rotatif, fixation universelle.',
        price: 3.00, stock: 7,
        imageUrl: 'https://cdn.jsdelivr.net/gh/abbas-fakih39/kids-project@main/designs/imagesproduits/tiny-love-meadow-days-mobile.jpg',
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
  const p2  = createdProducts['Poussette Bugaboo Butterfly'];
  const p5  = createdProducts['Poussette Maxi-Cosi Lara²'];
  const p6  = createdProducts['Lit Parapluie BabyBjörn Light'];
  const p8  = createdProducts['Lit Bébé Stokke Sleepi Mini'];
  const p10 = createdProducts['Chaise Haute Stokke Tripp Trapp'];
  const p11 = createdProducts['Chaise Haute Chicco Polly Magic Relax'];
  const p12 = createdProducts['Chauffe-biberon Philips Avent'];
  const p14 = createdProducts['Siège Auto Cybex Pallas G'];
  const p15 = createdProducts['Siège Auto Maxi-Cosi Pebble 360 Pro'];
  const p16 = createdProducts['Siège Auto Joie i-Spin Safe'];
  const p17 = createdProducts['Siège Auto BeSafe iZi Turn M i-Size'];
  const p18 = createdProducts["Tapis d'Éveil Fisher-Price Deluxe"];
  const p19 = createdProducts['Balancelle BabyBjörn Bouncer Bliss'];
  const p21 = createdProducts['Mobile Musical Tiny Love Meadow Days'];

  console.log('Création des réservations et des avis...');

  // Helper : crée un booking terminé + 1 review (1 review par booking max)
  async function mkBooking(
    user: typeof client1,
    start: string, end: string,
    items: Array<{ p: any; price: number }>,
    reviewProductId: number | null,
    reviewUserId: number,
    reviewRating: number,
    reviewComment: string,
    delivery: DeliveryMethod = DeliveryMethod.retrait_en_magasin,
    address?: { street: string; city: string; zip: string },
  ) {
    const days = (new Date(end).getTime() - new Date(start).getTime()) / 86_400_000;
    const amount = items.reduce((s, i) => s + days * i.price, 0);
    const bk = await prisma.booking.create({
      data: {
        booking_user_id:         user.user_id,
        booking_start_date:      new Date(start),
        booking_end_date:        new Date(end),
        booking_total_amount:    amount,
        booking_status:          BookingStatus.terminee,
        booking_delivery_method: delivery,
        ...(address ? { booking_delivery_street: address.street, booking_delivery_city: address.city, booking_delivery_zip: address.zip } : {}),
        products: { create: items.map(i => ({ bp_product_id: i.p.products_id, bp_quantity: 1, bp_price_snapshot: i.price })) },
        payment:  { create: { payments_amount: amount, payments_method: PaymentMethod.carte_bancaire, payments_status: PaymentStatus.valide } },
      },
    });
    if (reviewProductId) {
      await prisma.review.create({ data: { review_booking_id: bk.booking_id, review_product_id: reviewProductId, review_user_id: reviewUserId, review_rating: reviewRating, review_comment: reviewComment } });
    }
    return bk;
  }

  // ── B1 : client1, terminée — Babyzen + Cybex → review Babyzen ★5
  const b1 = await mkBooking(client1, '2026-02-01', '2026-02-05',
    [{ p: p1, price: 15 }, { p: p14, price: 12 }],
    p1.products_id, client1.user_id, 5, 'Parfaite pour notre séjour à Paris ! Très légère et pratique.',
  );
  void b1;

  // ── B2 : client2, en cours ─────────────────────────────────
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
      products: { create: [{ bp_product_id: p10.products_id, bp_quantity: 1, bp_price_snapshot: 8.00 }] },
      payment: { create: { payments_amount: 88.00, payments_method: PaymentMethod.paypal, payments_status: PaymentStatus.valide } },
    },
  });

  // ── B3 : client1, annulée ──────────────────────────────────
  await prisma.booking.create({
    data: {
      booking_user_id:         client1.user_id,
      booking_start_date:      new Date('2026-03-01T10:00:00Z'),
      booking_end_date:        new Date('2026-03-03T10:00:00Z'),
      booking_total_amount:    2 * 3.00,
      booking_status:          BookingStatus.annulee,
      booking_delivery_method: DeliveryMethod.retrait_en_magasin,
      products: { create: [{ bp_product_id: p12.products_id, bp_quantity: 1, bp_price_snapshot: 3.00 }] },
    },
  });

  // Une review par booking — 1 produit par booking pour les reviews
  // Produits avec 2 reviews : p1 (Babyzen), p10 (Tripp Trapp), p18 (Fisher-Price)
  // Produits avec 1 review  : p2, p5, p6, p8, p11, p14, p15, p16, p17, p19, p21
  // Produits avec 0 review  : p3, p4, p7, p9, p12, p13, p20
  await mkBooking(client2, '2026-01-08', '2026-01-12', [{ p: p1,  price: 15 }], p1.products_id,  client2.user_id, 4, 'Excellent rapport qualité-prix pour voyager léger. Pliage ultra rapide !');
  await mkBooking(client2, '2026-01-10', '2026-01-15', [{ p: p14, price: 12 }], p14.products_id, client2.user_id, 4, 'Très bon siège, facile à installer en Isofix. Notre fils se sent en sécurité.');
  await mkBooking(client1, '2026-01-12', '2026-01-16', [{ p: p2,  price: 18 }], p2.products_id,  client1.user_id, 4, 'Légère et maniable, parfaite pour nos vacances en ville !');
  await mkBooking(client2, '2026-01-15', '2026-01-20', [{ p: p5,  price: 12 }], p5.products_id,  client2.user_id, 5, 'Ultra légère, elle tient dans le bagage cabine. Indispensable pour voyager avec bébé !');
  await mkBooking(client1, '2026-01-18', '2026-01-22', [{ p: p8,  price: 14 }], p8.products_id,  client1.user_id, 5, 'Design magnifique et bébé dormait à merveille. Matériaux de qualité premium.');
  await mkBooking(client2, '2026-01-20', '2026-01-27', [{ p: p10, price: 8  }], p10.products_id, client2.user_id, 5, 'Magnifique chaise, bébé s\'y installe à merveille. Qualité irréprochable !');
  await mkBooking(client1, '2026-01-22', '2026-01-29', [{ p: p10, price: 8  }], p10.products_id, client1.user_id, 5, 'Design intemporel, notre fils l\'utilisera encore des années. Très stable et solide.');
  await mkBooking(client2, '2026-02-01', '2026-02-06', [{ p: p11, price: 7  }], p11.products_id, client2.user_id, 4, 'Fonctionnelle et confortable, les repas deviennent plus simples !');
  await mkBooking(client1, '2026-02-05', '2026-02-12', [{ p: p15, price: 14 }], p15.products_id, client1.user_id, 5, 'Rotation 360° géniale, installation et sortie de bébé super faciles !');
  await mkBooking(client2, '2026-02-08', '2026-02-14', [{ p: p16, price: 10 }], p16.products_id, client2.user_id, 5, 'Rotation 360° et protection anti-recul intégrée — on se sent vraiment en sécurité !');
  await mkBooking(client1, '2026-02-10', '2026-02-17', [{ p: p17, price: 16 }], p17.products_id, client1.user_id, 4, 'Siège de qualité premium, notre bébé est bien protégé. Un peu lourd mais ça en vaut la peine.', DeliveryMethod.livraison, { street: '3 rue de la République', city: 'Bordeaux', zip: '33000' });
  await mkBooking(client2, '2026-02-15', '2026-02-20', [{ p: p18, price: 4  }], p18.products_id, client2.user_id, 5, 'Notre bébé adore les lumières et la musique ! L\'arche musicale est très bien conçue.');
  await mkBooking(client1, '2026-03-15', '2026-03-18', [{ p: p18, price: 4  }], p18.products_id, client1.user_id, 4, 'Très bon tapis pour l\'éveil. Les couleurs et sons stimulent bien bébé dès les premiers mois.');
  await mkBooking(client1, '2026-03-01', '2026-03-05', [{ p: p19, price: 8  }], p19.products_id, client1.user_id, 5, 'Indispensable ! Mon bébé s\'endort dessus en quelques minutes. Ultra léger et portable.');
  await mkBooking(client2, '2026-03-05', '2026-03-09', [{ p: p21, price: 3  }], p21.products_id, client2.user_id, 4, 'Très beau mobile, musiques douces et apaisantes. Bébé reste fasciné pendant de longues minutes.');
  await mkBooking(client2, '2026-03-08', '2026-03-13', [{ p: p6,  price: 10 }], p6.products_id,  client2.user_id, 4, 'Montage et démontage en 2 minutes, bébé dort très bien dedans. Très léger à transporter.');

  console.log('Génération de la data fictive terminée avec succès !');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
