import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requireAnyPermission, requirePermission } from "../middleware/permission.js";
import { cached, invalidateCache } from "../utils/cache.js";
import { z } from "zod";
import { env } from "../config/env.js";
import { listQuerySchema, parseSort } from "../utils/query.js";

export const committeesRouter = Router();

const COMMITTEE_ROLES = env.committeeRoles;

const isLeaderUser = async (userId: string) => {
  const user = await prisma.systemUser.findUnique({ where: { id: userId } });
  const role = (user?.role || "").toLowerCase();
  if (role === "leader") return true;
  const groups = await prisma.userGroup.findMany({ where: { userId } });
  if (!groups.length) return false;
  const groupIds = groups.map((g) => g.groupId);
  const groupRows = await prisma.group.findMany({ where: { id: { in: groupIds } } });
  return groupRows.some((g) => (g.name || "").toLowerCase().includes("leader"));
};

const resolveCommitteeScope = async (userId: string) => {
  const isLeader = await isLeaderUser(userId);
  if (!isLeader) return null;
  const chairRoles = env.committeeChairRoles;
  const assignments = await prisma.committeeMember.findMany({
    where: {
      memberId: userId,
      ...(chairRoles.length ? { role: { in: chairRoles } } : {}),
    },
  });
  return Array.from(new Set(assignments.map((a) => a.committeeId)));
};

const ensureCommitteeScope = async (userId: string, committeeId: string) => {
  const scope = await resolveCommitteeScope(userId);
  if (scope === null) return true;
  return scope.includes(committeeId);
};

const createCommitteeSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional().nullable(),
});

const updateCommitteeSchema = z.object({
  name: z.string().min(2).optional(),
  description: z.string().optional().nullable(),
  status: z.enum(["Active", "Inactive"]).optional().nullable(),
});

const assignCommitteeMemberSchema = z.object({
  memberId: z.string().uuid(),
  role: z.string().optional().nullable(),
}).superRefine((data, ctx) => {
  if (data.role && !COMMITTEE_ROLES.includes(data.role)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Invalid committee role" });
  }
});

const buildPagination = (page: number, pageSize: number, total: number) => ({
  page,
  pageSize,
  total,
  totalPages: Math.max(1, Math.ceil(total / pageSize)),
});

committeesRouter.get(
  "/",
  requireAuth,
  requireAnyPermission(["READ_ALL", "COMMITTEE_UPDATE"]),
  async (req, res) => {
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
      return;
    }
    const { page, pageSize, q, status, sort } = parsed.data;
    if (status && !["Active", "Inactive"].includes(status)) {
      res.status(400).json(fail("Invalid request", "400", "Invalid status filter", buildMeta()));
      return;
    }

    const where: any = {};
    if (status) where.status = status;
    if (q) where.name = { contains: q, mode: "insensitive" };
    if (req.userId) {
      const scope = await resolveCommitteeScope(req.userId);
      if (scope) {
        where.id = { in: scope };
      }
    }
    const orderBy = parseSort(sort, ["name", "status", "createdAt"], "name");
    if (!orderBy) {
      res.status(400).json(fail("Invalid request", "400", "Invalid sort parameter", buildMeta()));
      return;
    }

    const [total, items] = await Promise.all([
      prisma.committee.count({ where }),
      prisma.committee.findMany({
        where,
        orderBy,
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);
    res.json(ok(items, "OK", buildMeta(undefined, buildPagination(page, pageSize, total))));
  }
);

committeesRouter.get(
  "/roles",
  requireAuth,
  requireAnyPermission(["READ_ALL", "COMMITTEE_UPDATE"]),
  async (_req, res) => {
    const roles = await cached("committees:roles", env.cacheTtl.committeeRolesMs, async () => COMMITTEE_ROLES);
    res.json(ok(roles, "OK", buildMeta()));
  }
);

committeesRouter.get(
  "/chairs",
  requireAuth,
  requireAnyPermission(["READ_ALL", "COMMITTEE_UPDATE"]),
  async (req, res) => {
    const chairRoles = env.committeeChairRoles;
    if (!chairRoles.length) {
      res.json(ok([], "OK", buildMeta()));
      return;
    }
    const scope = req.userId ? await resolveCommitteeScope(req.userId) : null;
    const assignments = await prisma.committeeMember.findMany({
      where: {
        role: { in: chairRoles },
        ...(scope ? { committeeId: { in: scope } } : {}),
      },
    });
    if (!assignments.length) {
      res.json(ok([], "OK", buildMeta()));
      return;
    }
    const committeeIds = Array.from(new Set(assignments.map((a) => a.committeeId)));
    const memberIds = Array.from(new Set(assignments.map((a) => a.memberId)));
    const [committees, members] = await Promise.all([
      prisma.committee.findMany({ where: { id: { in: committeeIds } } }),
      prisma.member.findMany({ where: { id: { in: memberIds } } }),
    ]);
    const committeeById = new Map(committees.map((c) => [c.id, c]));
    const memberById = new Map(members.map((m) => [m.id, m]));
    const rows = assignments
      .map((a) => {
        const committee = committeeById.get(a.committeeId);
        const member = memberById.get(a.memberId);
        if (!committee || !member) return null;
        return {
          committeeId: committee.id,
          committeeName: committee.name,
          memberId: member.id,
          memberName: member.name,
          role: a.role,
        };
      })
      .filter(Boolean) as any[];
    rows.sort((a, b) => (a.committeeName || "").localeCompare(b.committeeName || ""));
    res.json(ok(rows, "OK", buildMeta()));
  }
);

committeesRouter.post(
  "/",
  requireAuth,
  requirePermission("COMMITTEE_CREATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const parsed = createCommitteeSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid committee payload", buildMeta()));
      return;
    }
    const { name, description } = parsed.data;
    const now = new Date().toISOString();
    const committee = await prisma.committee.create({
      data: {
        name,
        description,
        status: "Active",
        createdBy: actor,
        createdAt: now,
        lastEditedBy: actor,
        lastEditedAt: now,
      },
    });
    invalidateCache("committees:");
    res.json(ok(committee, "Created", buildMeta()));
  }
);

committeesRouter.get(
  "/:id",
  requireAuth,
  requireAnyPermission(["READ_ALL", "COMMITTEE_UPDATE"]),
  async (req, res) => {
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    const committee = await prisma.committee.findUnique({ where: { id } });
    if (!committee) {
      res.status(404).json(fail("Not found", "404", "Committee not found", buildMeta()));
      return;
    }
    const members = await prisma.committeeMember.findMany({ where: { committeeId: id } });
    res.json(ok({ committee, members }, "OK", buildMeta()));
  }
);

committeesRouter.put(
  "/:id",
  requireAuth,
  requirePermission("COMMITTEE_UPDATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    const parsed = updateCommitteeSchema.safeParse(req.body || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
      return;
    }
    const committee = await prisma.committee.findUnique({ where: { id } });
    if (!committee) {
      res.status(404).json(fail("Not found", "404", "Committee not found", buildMeta()));
      return;
    }
    const data: any = {};
    ["name", "description", "status"].forEach((key) => {
      if ((parsed.data as any)[key] !== undefined) data[key] = (parsed.data as any)[key];
    });
    data.lastEditedBy = actor;
    data.lastEditedAt = new Date().toISOString();
    const updated = await prisma.committee.update({ where: { id }, data });
    invalidateCache("committees:");
    res.json(ok(updated, "Updated", buildMeta()));
  }
);

committeesRouter.post(
  "/:id/deactivate",
  requireAuth,
  requirePermission("COMMITTEE_DEACTIVATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    const committee = await prisma.committee.findUnique({ where: { id } });
    if (!committee) {
      res.status(404).json(fail("Not found", "404", "Committee not found", buildMeta()));
      return;
    }
    const updated = await prisma.committee.update({
      where: { id },
      data: { status: "Inactive", lastEditedBy: actor, lastEditedAt: new Date().toISOString() },
    });
    invalidateCache("committees:");
    res.json(ok(updated, "Deactivated", buildMeta()));
  }
);

committeesRouter.get(
  "/:id/members",
  requireAuth,
  requirePermission("COMMITTEE_UPDATE"),
  async (req, res) => {
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
      return;
    }
    const { page, pageSize } = parsed.data;
    const q = parsed.data.q.toLowerCase();
    const role = parsed.data.role.trim();

    const assignments = await prisma.committeeMember.findMany({ where: { committeeId: id } });
    const memberIds = assignments.map((a) => a.memberId);
    const members = memberIds.length
      ? await prisma.member.findMany({ where: { id: { in: memberIds } } })
      : [];
    const memberById = new Map(members.map((m) => [m.id, m]));

    const rows = assignments
      .filter((a) => !role || a.role === role)
      .map((a) => {
        const member = memberById.get(a.memberId);
        if (!member) return null;
        if (q && !(member.name || "").toLowerCase().includes(q)) return null;
        return { memberId: a.memberId, role: a.role, member };
      })
      .filter(Boolean) as any[];

    const from = Math.min(rows.length, (page - 1) * pageSize);
    const to = Math.min(rows.length, from + pageSize);
    const pageRows = rows.slice(from, to);
    res.json(ok(pageRows, "OK", buildMeta(undefined, buildPagination(page, pageSize, rows.length))));
  }
);

committeesRouter.post(
  "/:id/members",
  requireAuth,
  requirePermission("COMMITTEE_MEMBER_ADD"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    const parsed = assignCommitteeMemberSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid member assignment payload", buildMeta()));
      return;
    }
    const { memberId, role } = parsed.data;
    const committee = await prisma.committee.findUnique({ where: { id } });
    const member = await prisma.member.findUnique({ where: { id: memberId } });
    if (!committee || !member) {
      res.status(404).json(fail("Not found", "404", "Committee or member not found", buildMeta()));
      return;
    }
    const assignment = await prisma.committeeMember.create({
      data: {
        committeeId: id,
        memberId,
        role,
      },
    });
    invalidateCache("committees:");
    res.json(ok(assignment, "Created", buildMeta()));
  }
);

committeesRouter.delete(
  "/:id/members/:memberId",
  requireAuth,
  requirePermission("COMMITTEE_MEMBER_REMOVE"),
  async (req, res) => {
    const { id, memberId } = req.params;
    if (req.userId) {
      const allowed = await ensureCommitteeScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Committee access denied", buildMeta()));
        return;
      }
    }
    await prisma.committeeMember.deleteMany({ where: { committeeId: id, memberId } });
    invalidateCache("committees:");
    res.json(ok(null, "Removed", buildMeta()));
  }
);
