# Database migration rollout

The `20260927090000_relational_integrity` migration is required before deploying the backend generated from the updated Prisma schema.

1. Back up the target database.
2. Run `npm run db:migrate:status` from `cms-back` to confirm the target and migration state.
3. Run `npm run db:migrate:deploy` from `cms-back`.
4. Regenerate Prisma Client and deploy the backend.

The migration promotes legacy member department values into primary department assignments, adds foreign keys and duplicate-prevention constraints, and links leader accounts to members. It aborts without deleting data if it finds ambiguous/missing department references, orphaned links, or duplicate normalized contact details. Resolve any reported rows and retry. This migration has not been run against a database as part of the code changes.
