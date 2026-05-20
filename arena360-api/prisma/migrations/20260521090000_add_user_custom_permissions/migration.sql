-- Add missing column used by Prisma schema
ALTER TABLE "User"
ADD COLUMN IF NOT EXISTS "customPermissions" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

