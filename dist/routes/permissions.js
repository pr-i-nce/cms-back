import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached } from "../utils/cache.js";
import { env } from "../config/env.js";
export const permissionsRouter = Router();
permissionsRouter.get("/", requireAuth, requirePermission("PERMISSION_VIEW"), async (_req, res) => {
    const permissions = await cached("permissions:list", env.cacheTtl.permissionsMs, () => prisma.permission.findMany());
    res.json(ok(permissions, "OK", buildMeta()));
});
