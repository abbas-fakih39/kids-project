"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const pg_1 = require("pg");
const adapter_pg_1 = require("@prisma/adapter-pg");
const pool = new pg_1.Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new adapter_pg_1.PrismaPg(pool);
const prisma = new client_1.PrismaClient({ adapter });
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
            user_nom: 'Admin', user_prenom: 'Super', user_email: 'admin@kitsandkids.com', user_password: passwordHash, user_role: client_1.UserRole.admin,
        },
    });
    const client1 = await prisma.user.create({
        data: {
            user_nom: 'Dupont', user_prenom: 'Marie', user_email: 'marie.dupont@example.com', user_password: passwordHash, user_role: client_1.UserRole.client,
        },
    });
    const client2 = await prisma.user.create({
        data: {
            user_nom: 'Martin', user_prenom: 'Paul', user_email: 'paul.martin@example.com', user_password: passwordHash, user_role: client_1.UserRole.client,
        },
    });
    console.log('Création des produits...');
    const p1 = await prisma.product.create({
        data: {
            products_name: 'Poussette Yoyo 2 Babyzen', products_description: 'Ultra compacte, idéale voyage en cabine avion.', products_category: 'Poussettes', products_price_per_day: 15.00, products_stock: 5, products_safety_standards: 'EN 1888',
            images: { create: [{ image_url: 'https://images.unsplash.com/photo-1591129938363-f24cb7340dcd?q=80&w=600', image_order: 0 }] },
        },
    });
    const p2 = await prisma.product.create({
        data: {
            products_name: 'Lit Parapluie BabyBjörn Light', products_description: 'Très confortable et léger à transporter.', products_category: 'Sommeil', products_price_per_day: 10.00, products_stock: 0,
            images: { create: [{ image_url: 'https://images.unsplash.com/photo-1544126592-807ade215a0b?q=80&w=600', image_order: 0 }] },
        },
    });
    const p3 = await prisma.product.create({
        data: {
            products_name: 'Chaise Haute Stokke Tripp Trapp', products_description: 'Évolutive et ergonomique, avec son baby set.', products_category: 'Repas', products_price_per_day: 8.00, products_stock: 1,
        },
    });
    const p4 = await prisma.product.create({
        data: {
            products_name: 'Siège Auto Cybex Pallas G', products_description: 'Sécurité maximale avec bouclier d\'impact.', products_category: 'Voyage', products_price_per_day: 12.00, products_stock: 10,
            images: { create: [{ image_url: 'https://images.unsplash.com/photo-1512497676759-4bf5d39bb3e3?q=80&w=600', image_order: 0 }] }
        },
    });
    const p5 = await prisma.product.create({
        data: {
            products_name: 'Chauffe-biberon Avent', products_description: 'Rapide et universel pour petits pots.', products_category: 'Repas', products_price_per_day: 3.00, products_stock: 4,
        },
    });
    console.log('Création des réservations et des avis...');
    const b1 = await prisma.booking.create({
        data: {
            booking_user_id: client1.user_id, booking_start_date: new Date('2026-02-01T10:00:00Z'), booking_end_date: new Date('2026-02-05T10:00:00Z'), booking_total_amount: 5 * 15.00 + 5 * 12.00, booking_status: client_1.BookingStatus.terminee, booking_delivery_method: client_1.DeliveryMethod.retrait_en_magasin,
            products: {
                create: [
                    { bp_product_id: p1.products_id, bp_quantity: 1, bp_price_snapshot: 15.00 },
                    { bp_product_id: p4.products_id, bp_quantity: 1, bp_price_snapshot: 12.00 }
                ],
            },
            payment: {
                create: { payments_amount: 135.00, payments_method: client_1.PaymentMethod.carte_bancaire, payments_status: client_1.PaymentStatus.valide },
            },
        },
    });
    await prisma.review.create({
        data: { review_booking_id: b1.booking_id, review_product_id: p1.products_id, review_user_id: client1.user_id, review_rating: 5, review_comment: 'Parfait pour notre séjour à Paris ! Matériel très propre.' },
    });
    await prisma.booking.create({
        data: {
            booking_user_id: client2.user_id, booking_start_date: new Date('2026-03-25T10:00:00Z'), booking_end_date: new Date('2026-04-05T10:00:00Z'), booking_total_amount: 11 * 8.00, booking_status: client_1.BookingStatus.en_cours, booking_delivery_method: client_1.DeliveryMethod.livraison, booking_delivery_street: '15 rue du Louvre', booking_delivery_city: 'Paris', booking_delivery_zip: '75001',
            products: {
                create: [{ bp_product_id: p3.products_id, bp_quantity: 1, bp_price_snapshot: 8.00 }],
            },
            payment: {
                create: { payments_amount: 88.00, payments_method: client_1.PaymentMethod.paypal, payments_status: client_1.PaymentStatus.valide },
            },
        },
    });
    await prisma.booking.create({
        data: {
            booking_user_id: client1.user_id, booking_start_date: new Date('2026-03-01T10:00:00Z'), booking_end_date: new Date('2026-03-03T10:00:00Z'), booking_total_amount: 2 * 3.00, booking_status: client_1.BookingStatus.annulee, booking_delivery_method: client_1.DeliveryMethod.retrait_en_magasin,
            products: {
                create: [{ bp_product_id: p5.products_id, bp_quantity: 1, bp_price_snapshot: 3.00 }],
            },
        },
    });
    console.log('Génération de la data fictive terminée avec succès !');
}
main().catch((e) => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
//# sourceMappingURL=seed.js.map