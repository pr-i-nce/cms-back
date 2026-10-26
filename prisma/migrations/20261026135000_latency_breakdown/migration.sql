ALTER TABLE "latency_logs"
  ADD COLUMN "environment" TEXT,
  ADD COLUMN "database_duration_ms" INTEGER,
  ADD COLUMN "database_query_count" INTEGER,
  ADD COLUMN "app_duration_ms" INTEGER,
  ADD COLUMN "sample_count" INTEGER,
  ADD COLUMN "max_duration_ms" INTEGER;

-- Older rows may contain search values or record UUIDs in the URL. Keep a safe route path.
UPDATE "latency_logs"
SET "path" = regexp_replace(
  split_part("path", '?', 1),
  '/[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}',
  '/:id',
  'gi'
)
WHERE "source" IN ('backend', 'ui')
  AND (position('?' in "path") > 0 OR "path" ~* '/[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}');

CREATE INDEX "latency_logs_source_timestamp_idx"
  ON "latency_logs"("source", "timestamp");
