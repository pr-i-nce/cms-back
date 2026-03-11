import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached, invalidateCache } from "../utils/cache.js";
import { z } from "zod";
import { env } from "../config/env.js";
export const groupsRouter = Router();
const createGroupSchema = z.object({
    name: z.string().min(2),
    description: z.string().optional().nullable(),
});
const updateGroupSchema = z.object({
    name: z.string().min(2).optional(),
    description: z.string().optional().nullable(),
});
const assignRolesSchema = z.object({
    roleIds: z.array(z.string().uuid()).default([]),
});
groupsRouter.get("/", requireAuth, requirePermission("READ_ALL"), async (_req, res) => {
    const groups = await cached("groups:list", env.cacheTtl.groupsMs, () => prisma.group.findMany());
    res.json(ok(groups, "OK", buildMeta()));
});
groupsRouter.get("/:id/roles", requireAuth, requirePermission("READ_ALL"), async (req, res) => {
    const id = req.params.id;
    const links = await prisma.groupRole.findMany({ where: { groupId: id } });
    res.json(ok({ roleIds: links.map((l) => l.roleId) }, "OK", buildMeta()));
});
groupsRouter.post("/", requireAuth, requirePermission("GROUP_CREATE"), async (req, res) => {
    const actor = req.userId || "system";
    const parsed = createGroupSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid group payload", buildMeta()));
        return;
    }
    const { name, description } = parsed.data;
    const now = new Date().toISOString();
    const group = await prisma.group.create({
        data: {
            name,
            description,
            createdBy: actor,
            createdAt: now,
            lastEditedBy: actor,
            lastEditedAt: now,
        },
    });
    invalidateCache("groups:");
    res.json(ok(group, "Created", buildMeta()));
});
groupsRouter.put("/:id", requireAuth, requirePermission("GROUP_UPDATE"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const parsed = updateGroupSchema.safeParse(req.body || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
        return;
    }
    const existing = await prisma.group.findUnique({ where: { id } });
    if (!existing) {
        res.status(404).json(fail("Not found", "404", "Group not found", buildMeta()));
        return;
    }
    const data = {};
    ["name", "description"].forEach((key) => {
        if (parsed.data[key] !== undefined)
            data[key] = parsed.data[key];
    });
    data.lastEditedBy = actor;
    data.lastEditedAt = new Date().toISOString();
    const group = await prisma.group.update({ where: { id }, data });
    invalidateCache("groups:");
    res.json(ok(group, "Updated", buildMeta()));
});
groupsRouter.put("/:id/roles", requireAuth, requirePermission("GROUP_ASSIGN_ROLES"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const parsed = assignRolesSchema.safeParse(req.body || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid role assignment payload", buildMeta()));
        return;
    }
    const group = await prisma.group.findUnique({ where: { id } });
    if (!group) {
        res.status(404).json(fail("Not found", "404", "Group not found", buildMeta()));
        return;
    }
    const roleIds = parsed.data.roleIds || [];
    await prisma.groupRole.deleteMany({ where: { groupId: id } });
    if (roleIds.length) {
        await prisma.groupRole.createMany({
            data: roleIds.map((roleId) => ({ groupId: id, roleId })),
        });
    }
    await prisma.group.update({
        where: { id },
        data: { lastEditedBy: actor, lastEditedAt: new Date().toISOString() },
    });
    invalidateCache("groups:");
    res.json(ok(null, "Updated", buildMeta()));
});
