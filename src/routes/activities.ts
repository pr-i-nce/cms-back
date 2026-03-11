import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached } from "../utils/cache.js";
import { env } from "../config/env.js";
import { listQuerySchema } from "../utils/query.js";

export const activitiesRouter = Router();

const buildPagination = (page: number, pageSize: number, total: number) => ({
  page,
  pageSize,
  total,
  totalPages: Math.max(1, Math.ceil(total / pageSize)),
});

activitiesRouter.get(
  "/",
  requireAuth,
  requirePermission("READ_ALL"),
  async (req, res) => {
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
      return;
    }
    const { page, pageSize, q } = parsed.data;

    const where: any = {};
    if (q) {
      where.OR = [
        { action: { contains: q, mode: "insensitive" } },
        { details: { contains: q, mode: "insensitive" } },
      ];
    }
    const cacheKey = `activities:${page}:${pageSize}:${q || ""}`;
    const result = await cached(cacheKey, env.cacheTtl.activitiesMs, async () => {
      const [total, items] = await Promise.all([
        prisma.activity.count({ where }),
        prisma.activity.findMany({
          where,
          orderBy: { time: "desc" },
          skip: (page - 1) * pageSize,
          take: pageSize,
        }),
      ]);
      return { total, items };
    });
    res.json(ok(result.items, "OK", buildMeta(undefined, buildPagination(page, pageSize, result.total))));
  }
);
