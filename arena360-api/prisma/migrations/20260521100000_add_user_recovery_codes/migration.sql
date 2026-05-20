-- Add missing recovery codes column used by Prisma schema
ALTER TABLE "User"
ADD COLUMN IF NOT EXISTS "recoveryCodes" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

