import { PrismaClient } from "../generated/prisma/client.js";
import { PrismaPg } from "@prisma/adapter-pg";
import { env } from "../config/env.js";

const adapter = new PrismaPg({
  connectionString: env.databaseUrl,
  max: 5,
  connectionTimeoutMillis: 10_000,
});

export const prisma = new PrismaClient({ adapter });
