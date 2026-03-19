import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached, invalidateCache } from "../utils/cache.js";
import { z } from "zod";
import { env } from "../config/env.js";
import { listQuerySchema, parseSort } from "../utils/query.js";

export const departmentsRouter = Router();

const DEPARTMENT_ROLES = env.departmentRoles;

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

const resolveDepartmentScope = async (userId: string) => {
  const isLeader = await isLeaderUser(userId);
  if (!isLeader) {
    return null;
  }
  const headRoles = env.departmentHeadRoles;
  const assignments = await prisma.departmentMember.findMany({
    where: {
      memberId: userId,
      ...(headRoles.length ? { role: { in: headRoles } } : {}),
    },
  });
  return Array.from(new Set(assignments.map((a) => a.departmentId)));
};

const ensureDepartmentScope = async (userId: string, departmentId: string) => {
  const scope = await resolveDepartmentScope(userId);
  if (scope === null) return true;
  return scope.includes(departmentId);
};

const createDepartmentSchema = z.object({
  name: z.string().min(2),
  description: z.string().optional().nullable(),
});

const updateDepartmentSchema = z.object({
  name: z.string().min(2).optional(),
  description: z.string().optional().nullable(),
  leader: z.string().optional().nullable(),
  status: z.enum(["Active", "Inactive"]).optional().nullable(),
});

const assignDepartmentMemberSchema = z.object({
  memberId: z.string().uuid(),
  role: z.string().optional().nullable(),
}).superRefine((data, ctx) => {
  if (data.role && !DEPARTMENT_ROLES.includes(data.role)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Invalid department role" });
  }
});

const buildPagination = (page: number, pageSize: number, total: number) => ({
  page,
  pageSize,
  total,
  totalPages: Math.max(1, Math.ceil(total / pageSize)),
});

const normalize = (value?: string | null) => (value || "").trim().toLowerCase();

departmentsRouter.get(
  "/",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
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
      const scope = await resolveDepartmentScope(req.userId);
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
      prisma.department.count({ where }),
      prisma.department.findMany({
        where,
        orderBy,
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);

    const counts = await prisma.departmentMember.groupBy({
      by: ["departmentId"],
      _count: { departmentId: true },
    });
    const countMap = new Map(counts.map((c) => [c.departmentId, c._count.departmentId]));
    const withCounts = items.map((dept) => ({
      ...dept,
      membersCount: countMap.get(dept.id) ?? 0,
    }));

    res.json(ok(withCounts, "OK", buildMeta(undefined, buildPagination(page, pageSize, total))));
  }
);

departmentsRouter.get(
  "/roles",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (_req, res) => {
    const roles = await cached("departments:roles", env.cacheTtl.departmentRolesMs, async () => DEPARTMENT_ROLES);
    res.json(ok(roles, "OK", buildMeta()));
  }
);

departmentsRouter.get(
  "/heads",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (req, res) => {
    const headRoles = env.departmentHeadRoles;
    if (!headRoles.length) {
      res.json(ok([], "OK", buildMeta()));
      return;
    }
    const scope = req.userId ? await resolveDepartmentScope(req.userId) : null;
    const headRoleSet = new Set(headRoles.map((r) => normalize(r)));
    const assignments = await prisma.departmentMember.findMany({
      where: scope ? { departmentId: { in: scope } } : {},
    });
    const filteredAssignments = assignments.filter((a) => headRoleSet.has(normalize(a.role)));
    const departmentIds = Array.from(new Set(filteredAssignments.map((a) => a.departmentId)));
    const memberIds = Array.from(new Set(filteredAssignments.map((a) => a.memberId)));
    const [departments, members, memberHeads] = await Promise.all([
      prisma.department.findMany({ where: departmentIds.length ? { id: { in: departmentIds } } : undefined }),
      prisma.member.findMany({ where: memberIds.length ? { id: { in: memberIds } } : undefined }),
      prisma.member.findMany({
        where: {
          department: { not: null },
          OR: headRoles.map((role) => ({ role: { equals: role, mode: "insensitive" } })),
        },
      }),
    ]);
    const deptById = new Map(departments.map((d) => [d.id, d]));
    const deptByName = new Map(
      departments.map((d) => [normalize(d.name), d]).filter(([name]) => name)
    );
    const memberById = new Map(members.map((m) => [m.id, m]));
    const rows: any[] = [];
    const seen = new Set<string>();
    filteredAssignments.forEach((a) => {
      const dept = deptById.get(a.departmentId);
      const member = memberById.get(a.memberId);
      if (!dept || !member) return;
      const key = `${dept.id}:${member.id}`;
      if (seen.has(key)) return;
      seen.add(key);
      rows.push({
        departmentId: dept.id,
        departmentName: dept.name,
        memberId: member.id,
        memberName: member.name,
        role: a.role,
      });
    });
    memberHeads.forEach((member) => {
      const dept = deptByName.get(normalize(member.department));
      if (!dept) return;
      if (scope && !scope.includes(dept.id)) return;
      const key = `${dept.id}:${member.id}`;
      if (seen.has(key)) return;
      seen.add(key);
      rows.push({
        departmentId: dept.id,
        departmentName: dept.name,
        memberId: member.id,
        memberName: member.name,
        role: member.role,
      });
    });
    rows.sort((a, b) => (a.departmentName || "").localeCompare(b.departmentName || ""));
    res.json(ok(rows, "OK", buildMeta()));
  }
);

departmentsRouter.post(
  "/",
  requireAuth,
  requirePermission("DEPARTMENT_CREATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const parsed = createDepartmentSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid department payload", buildMeta()));
      return;
    }
    const { name, description } = parsed.data;
    const now = new Date().toISOString();
    const dept = await prisma.department.create({
      data: {
        name,
        description,
        status: "Active",
        membersCount: 0,
        createdBy: actor,
        createdAt: now,
        lastEditedBy: actor,
        lastEditedAt: now,
      },
    });
    invalidateCache("departments:");
    res.json(ok(dept, "Created", buildMeta()));
  }
);

departmentsRouter.get(
  "/:id",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (req, res) => {
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    const department = await prisma.department.findUnique({ where: { id } });
    if (!department) {
      res.status(404).json(fail("Not found", "404", "Department not found", buildMeta()));
      return;
    }
    const members = await prisma.departmentMember.findMany({ where: { departmentId: id } });
    res.json(ok({ department, members }, "OK", buildMeta()));
  }
);

departmentsRouter.put(
  "/:id",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    const parsed = updateDepartmentSchema.safeParse(req.body || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
      return;
    }
    const department = await prisma.department.findUnique({ where: { id } });
    if (!department) {
      res.status(404).json(fail("Not found", "404", "Department not found", buildMeta()));
      return;
    }
    const data: any = {};
    ["name", "description", "leader", "status"].forEach((key) => {
      if ((parsed.data as any)[key] !== undefined) data[key] = (parsed.data as any)[key];
    });
    data.lastEditedBy = actor;
    data.lastEditedAt = new Date().toISOString();
    const updated = await prisma.department.update({ where: { id }, data });
    invalidateCache("departments:");
    res.json(ok(updated, "Updated", buildMeta()));
  }
);

departmentsRouter.post(
  "/:id/deactivate",
  requireAuth,
  requirePermission("DEPARTMENT_DEACTIVATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    const department = await prisma.department.findUnique({ where: { id } });
    if (!department) {
      res.status(404).json(fail("Not found", "404", "Department not found", buildMeta()));
      return;
    }
    const updated = await prisma.department.update({
      where: { id },
      data: { status: "Inactive", lastEditedBy: actor, lastEditedAt: new Date().toISOString() },
    });
    invalidateCache("departments:");
    res.json(ok(updated, "Deactivated", buildMeta()));
  }
);

departmentsRouter.get(
  "/:id/members",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (req, res) => {
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    const department = await prisma.department.findUnique({ where: { id } });
    if (!department) {
      res.status(404).json(fail("Not found", "404", "Department not found", buildMeta()));
      return;
    }
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
      return;
    }
    const { page, pageSize } = parsed.data;
    const q = normalize(parsed.data.q);
    const role = normalize(parsed.data.role);

    const assignments = await prisma.departmentMember.findMany({ where: { departmentId: id } });
    const memberIds = assignments.map((a) => a.memberId);
    const [assignedMembers, deptMembers] = await Promise.all([
      memberIds.length ? prisma.member.findMany({ where: { id: { in: memberIds } } }) : Promise.resolve([]),
      department.name
        ? prisma.member.findMany({
          where: { department: { equals: department.name, mode: "insensitive" } },
        })
        : Promise.resolve([]),
    ]);
    const memberById = new Map(assignedMembers.map((m) => [m.id, m]));

    const rows: any[] = [];
    const seen = new Set<string>();
    assignments.forEach((a) => {
      const member = memberById.get(a.memberId);
      if (!member) return;
      const resolvedRole = normalize(a.role);
      if (role && resolvedRole !== role) return;
      if (q && !normalize(member.name).includes(q)) return;
      if (seen.has(member.id)) return;
      seen.add(member.id);
      rows.push({ memberId: a.memberId, role: a.role, member });
    });
    deptMembers.forEach((member) => {
      if (seen.has(member.id)) return;
      const resolvedRole = normalize(member.role);
      if (role && resolvedRole !== role) return;
      if (q && !normalize(member.name).includes(q)) return;
      seen.add(member.id);
      rows.push({ memberId: member.id, role: member.role, member });
    });

    const from = Math.min(rows.length, (page - 1) * pageSize);
    const to = Math.min(rows.length, from + pageSize);
    const pageRows = rows.slice(from, to);
    res.json(ok(pageRows, "OK", buildMeta(undefined, buildPagination(page, pageSize, rows.length))));
  }
);

departmentsRouter.post(
  "/:id/members",
  requireAuth,
  requirePermission("DEPT_MEMBER_ADD"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    const parsed = assignDepartmentMemberSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid member assignment payload", buildMeta()));
      return;
    }
    const { memberId, role } = parsed.data;
    const department = await prisma.department.findUnique({ where: { id } });
    const member = await prisma.member.findUnique({ where: { id: memberId } });
    if (!department || !member) {
      res.status(404).json(fail("Not found", "404", "Department or member not found", buildMeta()));
      return;
    }
    const assignment = await prisma.departmentMember.create({
      data: {
        departmentId: id,
        memberId,
        role,
      },
    });
    invalidateCache("departments:");
    res.json(ok(assignment, "Created", buildMeta()));
  }
);

departmentsRouter.delete(
  "/:id/members/:memberId",
  requireAuth,
  requirePermission("DEPT_MEMBER_REMOVE"),
  async (req, res) => {
    const { id, memberId } = req.params;
    if (req.userId) {
      const allowed = await ensureDepartmentScope(req.userId, id);
      if (!allowed) {
        res.status(403).json(fail("FORBIDDEN", "403", "Department access denied", buildMeta()));
        return;
      }
    }
    await prisma.departmentMember.deleteMany({ where: { departmentId: id, memberId } });
    invalidateCache("departments:");
    res.json(ok(null, "Removed", buildMeta()));
  }
);

departmentsRouter.get(
  "/members/assignments",
  requireAuth,
  requirePermission("DEPARTMENT_UPDATE"),
  async (req, res) => {
    const scope = req.userId ? await resolveDepartmentScope(req.userId) : null;
    const page = Math.max(1, Number(req.query.page || 1));
    const pageSize = Math.max(1, Math.min(env.pagination.maxPageSize, Number(req.query.pageSize || env.pagination.defaultPageSize)));
    const q = String(req.query.q || "").trim().toLowerCase();

    const assignments = await prisma.departmentMember.findMany({
      where: scope ? { departmentId: { in: scope } } : {},
    });
    const [members, departments] = await Promise.all([
      prisma.member.findMany(),
      prisma.department.findMany(),
    ]);
    const memberById = new Map(members.map((m) => [m.id, m]));
    const deptById = new Map(departments.map((d) => [d.id, d]));
    const deptByName = new Map(
      departments.map((d) => [normalize(d.name), d]).filter(([name]) => name)
    );

    const rows: any[] = [];
    const seen = new Set<string>();
    assignments.forEach((a) => {
      const member = memberById.get(a.memberId);
      const department = deptById.get(a.departmentId);
      if (!member || !department) return;
      if (q && !(member.name || "").toLowerCase().includes(q)) return;
      const key = `${department.id}:${member.id}`;
      if (seen.has(key)) return;
      seen.add(key);
      rows.push({
        departmentId: department.id,
        departmentName: department.name,
        role: a.role,
        member,
      });
    });
    members.forEach((member) => {
      if (!member.department) return;
      const department = deptByName.get(normalize(member.department));
      if (!department) return;
      if (scope && !scope.includes(department.id)) return;
      if (q && !(member.name || "").toLowerCase().includes(q)) return;
      const key = `${department.id}:${member.id}`;
      if (seen.has(key)) return;
      seen.add(key);
      rows.push({
        departmentId: department.id,
        departmentName: department.name,
        role: member.role,
        member,
      });
    });

    const from = Math.min(rows.length, (page - 1) * pageSize);
    const to = Math.min(rows.length, from + pageSize);
    const pageRows = rows.slice(from, to);
    res.json(ok(pageRows, "OK", buildMeta(undefined, buildPagination(page, pageSize, rows.length))));
  }
);
