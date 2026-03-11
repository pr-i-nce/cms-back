import { Router } from "express";
import bcrypt from "bcryptjs";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { z } from "zod";
import { env } from "../config/env.js";
import { listQuerySchema, parseSort } from "../utils/query.js";
import { resolvePermissions } from "../services/permissions.js";
export const usersRouter = Router();
const sanitizeUser = (user) => {
    if (!user)
        return user;
    const { passwordHash, ...rest } = user;
    return rest;
};
const passwordSchema = z.string()
    .min(8)
    .regex(/[a-z]/, "Password must include a lowercase letter")
    .regex(/[A-Z]/, "Password must include an uppercase letter")
    .regex(/[0-9]/, "Password must include a number");
const createUserSchema = z.object({
    name: z.string().min(2).optional(),
    email: z.string().email().optional(),
    phone: z.string().optional().nullable(),
    role: z.string().optional().nullable(),
    status: z.enum(["Active", "Inactive"]).optional().nullable(),
    password: passwordSchema,
    memberId: z.string().uuid().optional(),
    groupIds: z.array(z.string().uuid()).default([]),
});
const updateUserSchema = z.object({
    name: z.string().min(2).optional(),
    email: z.string().email().optional(),
    phone: z.string().optional().nullable(),
    role: z.string().optional().nullable(),
    status: z.enum(["Active", "Inactive"]).optional().nullable(),
    password: passwordSchema.optional(),
    currentPassword: z.string().min(6).optional(),
});
const assignGroupsSchema = z.object({
    groupIds: z.array(z.string().uuid()).default([]),
});
const buildPagination = (page, pageSize, total) => ({
    page,
    pageSize,
    total,
    totalPages: Math.max(1, Math.ceil(total / pageSize)),
});
const normalizeEmail = (value) => (value ? value.trim().toLowerCase() : null);
usersRouter.get("/", requireAuth, requirePermission("USER_CREATE"), async (req, res) => {
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
        return;
    }
    const { page, pageSize, q, sort } = parsed.data;
    const where = {};
    if (q) {
        where.OR = [
            { name: { contains: q, mode: "insensitive" } },
            { email: { contains: q, mode: "insensitive" } },
        ];
    }
    const orderBy = parseSort(sort, ["name", "email", "status", "createdAt"], "name");
    if (!orderBy) {
        res.status(400).json(fail("Invalid request", "400", "Invalid sort parameter", buildMeta()));
        return;
    }
    const [total, items] = await Promise.all([
        prisma.systemUser.count({ where }),
        prisma.systemUser.findMany({
            where,
            orderBy,
            skip: (page - 1) * pageSize,
            take: pageSize,
        }),
    ]);
    res.json(ok(items.map(sanitizeUser), "OK", buildMeta(undefined, buildPagination(page, pageSize, total))));
});
usersRouter.post("/", requireAuth, requirePermission("USER_CREATE"), async (req, res) => {
    const actor = req.userId || "system";
    const parsed = createUserSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid user payload", buildMeta()));
        return;
    }
    const { name, email, phone, role, status, password, memberId, groupIds } = parsed.data;
    const normalizedEmail = normalizeEmail(email);
    const normalizedRole = (role || "").toLowerCase();
    if (!groupIds.length) {
        res.status(400).json(fail("Invalid request", "400", "User must be assigned to a group", buildMeta()));
        return;
    }
    const groupRows = await prisma.group.findMany({ where: { id: { in: groupIds } } });
    if (groupRows.length !== groupIds.length) {
        res.status(400).json(fail("Invalid request", "400", "Invalid group assignment", buildMeta()));
        return;
    }
    const groupNames = groupRows.map((g) => (g.name || "").toLowerCase());
    const hasLeaderGroup = groupNames.some((name) => name.includes("leader"));
    if (normalizedRole === "leader" || hasLeaderGroup) {
        if (!memberId) {
            res.status(400).json(fail("Invalid request", "400", "Leader users must be linked to a member", buildMeta()));
            return;
        }
        const member = await prisma.member.findUnique({ where: { id: memberId } });
        if (!member) {
            res.status(404).json(fail("Not found", "404", "Member not found", buildMeta()));
            return;
        }
        const hasDeptHead = await prisma.departmentMember.findFirst({
            where: { memberId, role: { in: env.departmentHeadRoles } },
        });
        const hasCommitteeChair = await prisma.committeeMember.findFirst({
            where: { memberId, role: { in: env.committeeChairRoles } },
        });
        if (!hasDeptHead && !hasCommitteeChair) {
            res.status(400).json(fail("Invalid request", "400", "Member is not a department head or committee chair", buildMeta()));
            return;
        }
        if (!member.email) {
            res.status(400).json(fail("Invalid request", "400", "Leader member must have an email to create a user account", buildMeta()));
            return;
        }
        const existingById = await prisma.systemUser.findUnique({ where: { id: memberId } });
        if (existingById) {
            res.status(409).json(fail("Conflict", "409", "User already exists for this leader", buildMeta()));
            return;
        }
        const existingByEmail = await prisma.systemUser.findFirst({
            where: {
                email: {
                    equals: normalizeEmail(member.email),
                    mode: "insensitive",
                },
            },
        });
        if (existingByEmail) {
            res.status(409).json(fail("Conflict", "409", "User with this email already exists", buildMeta()));
            return;
        }
    }
    else {
        if (!normalizedEmail) {
            res.status(400).json(fail("Invalid request", "400", "Email is required", buildMeta()));
            return;
        }
        const exists = await prisma.systemUser.findFirst({
            where: {
                email: {
                    equals: normalizedEmail,
                    mode: "insensitive",
                },
            },
        });
        if (exists) {
            res.status(400).json(fail("Email already exists", "400", "Email already exists", buildMeta()));
            return;
        }
    }
    const now = new Date().toISOString();
    const passwordHash = password ? await bcrypt.hash(password, 10) : null;
    if (normalizedRole === "leader" || hasLeaderGroup) {
        const member = await prisma.member.findUnique({ where: { id: memberId } });
        const user = await prisma.systemUser.create({
            data: {
                id: memberId,
                name: member?.name || name || "Leader",
                email: normalizeEmail(member?.email) || normalizedEmail,
                phone: member?.phone || phone,
                role: "Leader",
                status: status || "Active",
                passwordHash,
                createdBy: actor,
                createdAt: now,
                lastEditedBy: actor,
                lastEditedAt: now,
            },
        });
        await prisma.userGroup.createMany({
            data: groupIds.map((groupId) => ({
                userId: user.id,
                groupId,
            })),
        });
        res.json(ok(sanitizeUser(user), "Created", buildMeta()));
        return;
    }
    const user = await prisma.systemUser.create({
        data: {
            name,
            email: normalizedEmail,
            phone,
            role,
            status: status || "Active",
            passwordHash,
            createdBy: actor,
            createdAt: now,
            lastEditedBy: actor,
            lastEditedAt: now,
        },
    });
    await prisma.userGroup.createMany({
        data: groupIds.map((groupId) => ({
            userId: user.id,
            groupId,
        })),
    });
    res.json(ok(sanitizeUser(user), "Created", buildMeta()));
});
usersRouter.get("/:id", requireAuth, requirePermission("USER_CREATE"), async (req, res) => {
    const id = req.params.id;
    const user = await prisma.systemUser.findUnique({ where: { id } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    const normalizedRole = (user.role || "").toLowerCase();
    if (normalizedRole === "leader") {
        const hasDeptHead = await prisma.departmentMember.findFirst({
            where: { memberId: id, role: { in: env.departmentHeadRoles } },
        });
        const hasCommitteeChair = await prisma.committeeMember.findFirst({
            where: { memberId: id, role: { in: env.committeeChairRoles } },
        });
        if (!hasDeptHead && !hasCommitteeChair) {
            res.status(400).json(fail("Invalid request", "400", "User is not a department head or committee chair", buildMeta()));
            return;
        }
    }
    res.json(ok(sanitizeUser(user), "OK", buildMeta()));
});
usersRouter.get("/:id/groups", requireAuth, requirePermission("USER_CREATE"), async (req, res) => {
    const id = req.params.id;
    const links = await prisma.userGroup.findMany({ where: { userId: id } });
    res.json(ok({ groupIds: links.map((l) => l.groupId) }, "OK", buildMeta()));
});
usersRouter.put("/:id", requireAuth, requirePermission("USER_UPDATE"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const parsed = updateUserSchema.safeParse(req.body || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
        return;
    }
    const user = await prisma.systemUser.findUnique({ where: { id } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    if (parsed.data.email) {
        const normalizedEmail = normalizeEmail(parsed.data.email);
        const exists = await prisma.systemUser.findFirst({
            where: {
                email: {
                    equals: normalizedEmail,
                    mode: "insensitive",
                },
            },
        });
        if (exists && exists.id !== id) {
            res.status(400).json(fail("Email already exists", "400", "Email already exists", buildMeta()));
            return;
        }
    }
    const data = {};
    ["name", "email", "phone", "role", "status"].forEach((key) => {
        if (parsed.data[key] !== undefined)
            data[key] = parsed.data[key];
    });
    if (data.email !== undefined)
        data.email = normalizeEmail(data.email);
    if (parsed.data.password) {
        const isSelf = actor === id;
        if (parsed.data.currentPassword) {
            if (!user.passwordHash || !(await bcrypt.compare(parsed.data.currentPassword, user.passwordHash))) {
                res.status(400).json(fail("Invalid request", "400", "Current password is incorrect", buildMeta()));
                return;
            }
        }
        else if (isSelf) {
            res.status(400).json(fail("Invalid request", "400", "Current password is required", buildMeta()));
            return;
        }
        else {
            const actorPerms = await resolvePermissions(actor);
            if (!actorPerms.includes("USER_RESET_PASSWORD")) {
                res.status(403).json(fail("FORBIDDEN", "403", "Password change requires reset permission", buildMeta()));
                return;
            }
        }
        data.passwordHash = await bcrypt.hash(parsed.data.password, 10);
        const nowIso = new Date().toISOString();
        await prisma.$executeRaw `
        update refresh_tokens set revoked_at = ${nowIso}, last_used_at = ${nowIso}
        where user_id = ${id}
      `.catch(() => { });
    }
    data.lastEditedBy = actor;
    data.lastEditedAt = new Date().toISOString();
    const updated = await prisma.systemUser.update({ where: { id }, data });
    res.json(ok(sanitizeUser(updated), "Updated", buildMeta()));
});
usersRouter.post("/:id/deactivate", requireAuth, requirePermission("USER_DEACTIVATE"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const user = await prisma.systemUser.findUnique({ where: { id } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    const updated = await prisma.systemUser.update({
        where: { id },
        data: {
            status: "Inactive",
            lastEditedBy: actor,
            lastEditedAt: new Date().toISOString(),
        },
    });
    res.json(ok(sanitizeUser(updated), "Deactivated", buildMeta()));
});
usersRouter.post("/:id/reset-password", requireAuth, requirePermission("USER_RESET_PASSWORD"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const user = await prisma.systemUser.findUnique({ where: { id } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    const passwordHash = await bcrypt.hash("TempPassword123!", 10);
    await prisma.systemUser.update({
        where: { id },
        data: {
            passwordHash,
            lastEditedBy: actor,
            lastEditedAt: new Date().toISOString(),
        },
    });
    res.json(ok(null, "Reset sent", buildMeta()));
});
usersRouter.put("/:id/groups", requireAuth, requirePermission("USER_ASSIGN_GROUPS"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const parsed = assignGroupsSchema.safeParse(req.body || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid group assignment payload", buildMeta()));
        return;
    }
    const user = await prisma.systemUser.findUnique({ where: { id } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    const groupIds = parsed.data.groupIds || [];
    if (!groupIds.length) {
        res.status(400).json(fail("Invalid request", "400", "User must belong to at least one group", buildMeta()));
        return;
    }
    const groupRows = await prisma.group.findMany({ where: { id: { in: groupIds } } });
    if (groupRows.length !== groupIds.length) {
        res.status(400).json(fail("Invalid request", "400", "Invalid group assignment", buildMeta()));
        return;
    }
    const groupNames = groupRows.map((g) => (g.name || "").toLowerCase());
    const hasLeaderGroup = groupNames.some((name) => name.includes("leader"));
    if (hasLeaderGroup) {
        const hasDeptHead = await prisma.departmentMember.findFirst({
            where: { memberId: id, role: { in: env.departmentHeadRoles } },
        });
        const hasCommitteeChair = await prisma.committeeMember.findFirst({
            where: { memberId: id, role: { in: env.committeeChairRoles } },
        });
        if (!hasDeptHead && !hasCommitteeChair) {
            res.status(400).json(fail("Invalid request", "400", "User is not a department head or committee chair", buildMeta()));
            return;
        }
    }
    await prisma.userGroup.deleteMany({ where: { userId: id } });
    if (groupIds.length) {
        await prisma.userGroup.createMany({
            data: groupIds.map((groupId) => ({
                userId: id,
                groupId,
            })),
        });
    }
    await prisma.systemUser.update({
        where: { id },
        data: { lastEditedBy: actor, lastEditedAt: new Date().toISOString() },
    });
    res.json(ok(null, "Updated", buildMeta()));
});
