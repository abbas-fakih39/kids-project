-- AlterTable
ALTER TABLE "users" ADD COLUMN     "user_notif_promo" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "user_notif_push" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "user_notif_transactional" BOOLEAN NOT NULL DEFAULT true;
