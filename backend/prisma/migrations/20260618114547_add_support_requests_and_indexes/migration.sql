-- CreateTable
CREATE TABLE "support_requests" (
    "support_id" SERIAL NOT NULL,
    "support_email" VARCHAR(255) NOT NULL,
    "support_prenom" VARCHAR(100) NOT NULL,
    "support_nom" VARCHAR(100) NOT NULL,
    "support_subject" VARCHAR(255),
    "support_message" TEXT NOT NULL,
    "support_order_ref" VARCHAR(50),
    "support_status" VARCHAR(20) NOT NULL DEFAULT 'open',
    "support_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "support_requests_pkey" PRIMARY KEY ("support_id")
);

-- CreateIndex
CREATE INDEX "bookings_booking_user_id_idx" ON "bookings"("booking_user_id");

-- CreateIndex
CREATE INDEX "products_products_category_products_status_idx" ON "products"("products_category", "products_status");
