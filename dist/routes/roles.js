import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached } from "../utils/cache.js";
import { env } from "../config/env.js";
export const rolesRouter = Router();
rolesRouter.get("/", requireAuth, requirePermission("ROLE_VIEW"), async (_req, res) => {
    const roles = await cached("roles:list", env.cacheTtl.rolesMs, () => prisma.role.findMany());
    res.json(ok(roles, "OK", buildMeta()));
});
rolesRouter.get("/:id/permissions", requireAuth, requirePermission("ROLE_VIEW"), async (req, res) => {
    const id = req.params.id;
    const links = await prisma.rolePermission.findMany({ where: { roleId: id } });
    res.json(ok({ permissionIds: links.map((l) => l.permissionId) }, "OK", buildMeta()));
});
