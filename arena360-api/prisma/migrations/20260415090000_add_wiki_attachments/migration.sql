ALTER TYPE "FileScopeType" ADD VALUE IF NOT EXISTS 'WIKI';

-- Wiki tables were added to the Prisma schema but were missing from migrations in some environments.
-- Ensure the required tables exist before referencing them from FileAsset.
CREATE TABLE IF NOT EXISTS "WikiPage" (
    "id" TEXT NOT NULL,
    "orgId" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "authorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "WikiPage_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "WikiPageVersion" (
    "id" TEXT NOT NULL,
    "pageId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "authorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WikiPageVersion_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "WikiPage_orgId_slug_key" ON "WikiPage"("orgId", "slug");
CREATE INDEX IF NOT EXISTS "WikiPage_orgId_idx" ON "WikiPage"("orgId");

CREATE INDEX IF NOT EXISTS "WikiPageVersion_pageId_idx" ON "WikiPageVersion"("pageId");
CREATE INDEX IF NOT EXISTS "WikiPageVersion_createdAt_idx" ON "WikiPageVersion"("createdAt");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'WikiPage_orgId_fkey'
  ) THEN
    ALTER TABLE "WikiPage"
    ADD CONSTRAINT "WikiPage_orgId_fkey"
    FOREIGN KEY ("orgId") REFERENCES "Org"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'WikiPageVersion_pageId_fkey'
  ) THEN
    ALTER TABLE "WikiPageVersion"
    ADD CONSTRAINT "WikiPageVersion_pageId_fkey"
    FOREIGN KEY ("pageId") REFERENCES "WikiPage"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

ALTER TABLE "FileAsset"
ADD COLUMN IF NOT EXISTS "wikiPageId" TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'FileAsset_wikiPageId_fkey'
  ) THEN
    ALTER TABLE "FileAsset"
    ADD CONSTRAINT "FileAsset_wikiPageId_fkey"
    FOREIGN KEY ("wikiPageId") REFERENCES "WikiPage"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS "FileAsset_wikiPageId_idx" ON "FileAsset"("wikiPageId");
