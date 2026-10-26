# Database migration rollout

The Neon database was created from the legacy SQL schema, without Prisma migration history. `20260808000000_legacy_schema_baseline` records that existing schema for Prisma; it must be marked applied against the existing database and must not be executed there. The `20260927090000_relational_integrity` migration then adds the missing Prisma relationships and integrity constraints. `20261003090000_seed_rbac_baseline` installs the permission catalog, baseline roles, and groups.

For an already-created legacy database, mark the baseline as applied once, then apply subsequent migrations:

1. Confirm `DATABASE_URL` points to the intended database and take a backup.
2. Run `npx prisma migrate resolve --applied 20260808000000_legacy_schema_baseline` from `cms-back`.
3. Run `npm run db:migrate:deploy` from `cms-back`.
4. Regenerate Prisma Client and deploy the backend.

For an empty database, run `npm run db:migrate:deploy`; Prisma executes the baseline and then the later migrations in order.

The relational migration promotes the 199 existing member department assignments to primary assignments, adds foreign keys and duplicate-prevention constraints, and links leader accounts to members. It aborts without deleting data if it finds ambiguous/missing department references, orphaned links, or duplicate normalized contact details. Neon preflight found no such blockers; the migration and RBAC seed were applied on 2026-10-03. No member rows were removed.
The RBAC seed creates 31 permission records, three roles, and three groups. The initial Super Admin user is provisioned separately; do not put its password in a migration or source file.

`20261026135000_latency_breakdown` adds environment, Prisma query duration/count, sample count, peak duration, and estimated non-database duration to latency rows. It removes query strings and UUID route identifiers from historical latency paths and adds the source/timestamp index used by the latency report. Apply it with `npm run db:migrate:deploy` before deploying the backend build that writes the new columns. Historical rows retain null breakdown fields and appear as Legacy in Reports.

Latency persistence is intentionally limited to HTTP 5xx responses and requests at or above `LATENCY_PERSIST_THRESHOLD_MS` (default `500`). Backend issue samples are grouped by route, method, status, environment, and minute in a 500-bucket in-process buffer; a single batched database write runs at most once per minute. The batch stores average duration and database timings, peak duration, and sample count. Faster backend timings stay in the bounded in-process metrics window. The browser drops UI samples below the threshold before queueing or sending them, caps queued samples, and the ingest endpoint is authenticated, rate-limited, and validates payload size and paths. If overriding the backend threshold, set the same value in the frontend build as `VITE_LATENCY_PERSIST_THRESHOLD_MS`. SQL text, bound values, query strings, and UUID route identifiers are not recorded. Telemetry writes are best-effort and never delay the request that produced them. The application audit trail for actual record changes is separate and remains enabled.
