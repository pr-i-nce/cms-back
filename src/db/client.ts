import { PrismaClient } from "../generated/prisma/client.js";
import { PrismaPg } from "@prisma/adapter-pg";
import { env } from "../config/env.js";
import { recordDatabaseQuery } from "../metrics/requestContext.js";

const adapter = new PrismaPg({
  connectionString: env.databaseUrl,
  max: 5,
  connectionTimeoutMillis: 10_000,
});

export const prisma = new PrismaClient({
  adapter,
  // Only elapsed query duration is captured; SQL text and bound values are omitted.
  log: [{ emit: "event", level: "query" }],
});

prisma.$on("query", (event) => recordDatabaseQuery(event.duration));
