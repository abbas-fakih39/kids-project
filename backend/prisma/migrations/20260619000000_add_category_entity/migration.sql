-- CreateTable
CREATE TABLE "categories" (
    "cat_id"    SERIAL NOT NULL,
    "cat_name"  VARCHAR(100) NOT NULL,
    "cat_slug"  VARCHAR(100) NOT NULL,
    "cat_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("cat_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "categories_cat_slug_key" ON "categories"("cat_slug");

-- AlterTable: add primary image URL and category FK to products
ALTER TABLE "products"
    ADD COLUMN "products_image_url"   VARCHAR(500),
    ADD COLUMN "products_category_id" INTEGER;

-- AddForeignKey
ALTER TABLE "products" ADD CONSTRAINT "products_products_category_id_fkey"
    FOREIGN KEY ("products_category_id")
    REFERENCES "categories"("cat_id")
    ON DELETE SET NULL ON UPDATE CASCADE;
