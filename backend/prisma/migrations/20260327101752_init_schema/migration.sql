/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('client', 'admin');

-- CreateEnum
CREATE TYPE "ProductStatus" AS ENUM ('disponible', 'indisponible', 'maintenance');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('en attente', 'confirmée', 'en cours', 'terminée', 'annulée');

-- CreateEnum
CREATE TYPE "DeliveryMethod" AS ENUM ('livraison', 'retrait en magasin');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('carte bancaire', 'virement', 'PayPal');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('en attente', 'validé', 'échoué', 'remboursé');

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "users" (
    "user_id" SERIAL NOT NULL,
    "user_nom" VARCHAR(100) NOT NULL,
    "user_prenom" VARCHAR(100) NOT NULL,
    "user_birth" DATE,
    "user_email" VARCHAR(255) NOT NULL,
    "user_number" VARCHAR(20),
    "user_password" VARCHAR(255) NOT NULL,
    "user_role" "UserRole" NOT NULL DEFAULT 'client',
    "user_refresh_token" TEXT,
    "user_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "user_updated_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "products" (
    "products_id" SERIAL NOT NULL,
    "products_name" VARCHAR(255) NOT NULL,
    "products_description" TEXT,
    "products_category" VARCHAR(100) NOT NULL,
    "products_price_per_day" DECIMAL(10,2) NOT NULL,
    "products_stock" INTEGER NOT NULL DEFAULT 0,
    "products_safety_standards" VARCHAR(255),
    "products_status" "ProductStatus" NOT NULL DEFAULT 'disponible',
    "products_created_at" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "products_updated_at" DATE,

    CONSTRAINT "products_pkey" PRIMARY KEY ("products_id")
);

-- CreateTable
CREATE TABLE "product_images" (
    "image_id" SERIAL NOT NULL,
    "image_products_id" INTEGER NOT NULL,
    "image_url" VARCHAR(500) NOT NULL,
    "image_order" INTEGER NOT NULL DEFAULT 0,
    "image_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "product_images_pkey" PRIMARY KEY ("image_id")
);

-- CreateTable
CREATE TABLE "bookings" (
    "booking_id" SERIAL NOT NULL,
    "booking_user_id" INTEGER NOT NULL,
    "booking_start_date" DATE NOT NULL,
    "booking_end_date" DATE NOT NULL,
    "booking_total_amount" DECIMAL(10,2) NOT NULL,
    "booking_status" "BookingStatus" NOT NULL DEFAULT 'en attente',
    "booking_delivery_method" "DeliveryMethod" NOT NULL,
    "booking_delivery_street" VARCHAR(255),
    "booking_delivery_city" VARCHAR(100),
    "booking_delivery_zip" VARCHAR(10),
    "booking_delivery_country" VARCHAR(100) DEFAULT 'France',
    "booking_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "booking_updated_at" TIMESTAMP(3),

    CONSTRAINT "bookings_pkey" PRIMARY KEY ("booking_id")
);

-- CreateTable
CREATE TABLE "booking_products" (
    "bp_id" SERIAL NOT NULL,
    "bp_booking_id" INTEGER NOT NULL,
    "bp_product_id" INTEGER NOT NULL,
    "bp_quantity" INTEGER NOT NULL,
    "bp_price_snapshot" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "booking_products_pkey" PRIMARY KEY ("bp_id")
);

-- CreateTable
CREATE TABLE "payments" (
    "payments_id" SERIAL NOT NULL,
    "payments_booking_id" INTEGER NOT NULL,
    "payments_amount" DECIMAL(10,2) NOT NULL,
    "payments_method" "PaymentMethod" NOT NULL,
    "payments_status" "PaymentStatus" NOT NULL DEFAULT 'en attente',
    "payments_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "payments_updated_at" TIMESTAMP(3),

    CONSTRAINT "payments_pkey" PRIMARY KEY ("payments_id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "review_id" SERIAL NOT NULL,
    "review_booking_id" INTEGER NOT NULL,
    "review_user_id" INTEGER NOT NULL,
    "review_product_id" INTEGER NOT NULL,
    "review_rating" SMALLINT NOT NULL,
    "review_comment" TEXT,
    "review_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "review_updated_at" TIMESTAMP(3),

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("review_id")
);

-- CreateTable
CREATE TABLE "carts" (
    "carts_id" SERIAL NOT NULL,
    "carts_user_id" INTEGER NOT NULL,
    "carts_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "carts_updated_at" TIMESTAMP(3),

    CONSTRAINT "carts_pkey" PRIMARY KEY ("carts_id")
);

-- CreateTable
CREATE TABLE "cart_items" (
    "cart_item_id" SERIAL NOT NULL,
    "cart_item_cart_id" INTEGER NOT NULL,
    "cart_item_product_id" INTEGER NOT NULL,
    "cart_item_quantity" INTEGER NOT NULL,
    "cart_item_start_date" DATE NOT NULL,
    "cart_item_end_date" DATE NOT NULL,
    "cart_item_price_snapshot" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "cart_items_pkey" PRIMARY KEY ("cart_item_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_user_email_key" ON "users"("user_email");

-- CreateIndex
CREATE UNIQUE INDEX "payments_payments_booking_id_key" ON "payments"("payments_booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "reviews_review_booking_id_key" ON "reviews"("review_booking_id");

-- CreateIndex
CREATE UNIQUE INDEX "carts_carts_user_id_key" ON "carts"("carts_user_id");

-- AddForeignKey
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_image_products_id_fkey" FOREIGN KEY ("image_products_id") REFERENCES "products"("products_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_booking_user_id_fkey" FOREIGN KEY ("booking_user_id") REFERENCES "users"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_products" ADD CONSTRAINT "booking_products_bp_booking_id_fkey" FOREIGN KEY ("bp_booking_id") REFERENCES "bookings"("booking_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking_products" ADD CONSTRAINT "booking_products_bp_product_id_fkey" FOREIGN KEY ("bp_product_id") REFERENCES "products"("products_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_payments_booking_id_fkey" FOREIGN KEY ("payments_booking_id") REFERENCES "bookings"("booking_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_review_booking_id_fkey" FOREIGN KEY ("review_booking_id") REFERENCES "bookings"("booking_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_review_user_id_fkey" FOREIGN KEY ("review_user_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_review_product_id_fkey" FOREIGN KEY ("review_product_id") REFERENCES "products"("products_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "carts" ADD CONSTRAINT "carts_carts_user_id_fkey" FOREIGN KEY ("carts_user_id") REFERENCES "users"("user_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_cart_item_cart_id_fkey" FOREIGN KEY ("cart_item_cart_id") REFERENCES "carts"("carts_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_cart_item_product_id_fkey" FOREIGN KEY ("cart_item_product_id") REFERENCES "products"("products_id") ON DELETE CASCADE ON UPDATE CASCADE;
