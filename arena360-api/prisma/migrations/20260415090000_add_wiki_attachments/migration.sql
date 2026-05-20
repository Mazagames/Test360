ALTER TYPE "FileScopeType" ADD VALUE IF NOT EXISTS 'WIKI';

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
