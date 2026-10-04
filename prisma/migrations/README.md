# Database migration rollout

The Neon database was created from the legacy SQL schema, without Prisma migration history. `20260808000000_legacy_schema_baseline` records that existing schema for Prisma; it must be marked applied against the existing database and must not be executed there. The `20260927090000_relational_integrity` migration then adds the missing Prisma relationships and integrity constraints. `20261003090000_seed_rbac_baseline` installs the permission catalog, baseline roles, and groups.

For an already-created legacy database, mark the baseline as applied once, then apply subsequent migrations:

1. Confirm `DATABASE_URL` points to the intended database and take a backup.
2. Run `npx prisma migrate resolve --applied 20260808000000_legacy_schema_baseline` from `cms-back`.
3. Run `npm run db:migrate:deploy` from `cms-back`.
4. Regenerate Prisma Client and deploy the backend.

For an empty database, run `npm run db:migrate:deploy`; Prisma executes the baseline and then the later migrations in order.

The relational migration promotes the 199 existing member department assignments to primary assignments, adds foreign keys and duplicate-prevention constraints, and links leader accounts to members. It aborts without deleting data if it finds ambiguous/missing department references, orphaned links, or duplicate normalized contact details. Neon preflight found no such blockers; the migration and RBAC seed were applied on 2026-10-03. No member rows were removed.
ok
The RBAC seed creates 31 permission records, three roles, and three groups. The initial Super Admin user is provisioned separately; do not put its password in a migration or source file.
