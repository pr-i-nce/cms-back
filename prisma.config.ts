import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  datasource: {
    // Client generation does not connect to a database. Keep CI builds working
    // when production credentials are intentionally unavailable; migration
    // commands still need DATABASE_URL set to the real database.
    url: process.env.DATABASE_URL ?? "postgresql://build:build@127.0.0.1:5432/build_db",
  },
});
