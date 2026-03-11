import { z } from "zod";
import { env } from "../config/env.js";

export const listQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(env.pagination.maxPageSize).default(env.pagination.defaultPageSize),
  q: z.string().max(120).optional().default(""),
  status: z.string().max(30).optional().default(""),
  role: z.string().max(50).optional().default(""),
  sort: z.string().max(50).optional().default(""),
});

export const parseSort = (sort: string, allowed: string[], defaultField: string) => {
  if (!sort) return { [defaultField]: "asc" as const };
  const parts = sort.split(",");
  const field = parts[0]?.trim();
  const direction = (parts[1] || "asc").toLowerCase();
  if (!field || !allowed.includes(field)) return null;
  if (direction !== "asc" && direction !== "desc") return null;
  return { [field]: direction as "asc" | "desc" };
};
