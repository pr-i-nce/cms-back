import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requireAnyPermission, requirePermission } from "../middleware/permission.js";
import { z } from "zod";
import { env } from "../config/env.js";
import { listQuerySchema, parseSort } from "../utils/query.js";

export const membersRouter = Router();

const createMemberSchema = z.object({
  name: z.string().min(2),
  phone: z.string().optional().nullable(),
  email: z.string().email().optional().nullable(),
  gender: z.string().optional().nullable(),
  status: z.enum(["Active", "Inactive"]).optional().nullable(),
});

const updateMemberSchema = z.object({
  name: z.string().min(2).optional(),
  phone: z.string().optional().nullable(),
  email: z.string().email().optional().nullable(),
  gender: z.string().optional().nullable(),
  status: z.enum(["Active", "Inactive"]).optional().nullable(),
});

const buildPagination = (page: number, pageSize: number, total: number) => ({
  page,
  pageSize,
  total,
  totalPages: Math.max(1, Math.ceil(total / pageSize)),
});

const normalizeEmail = (value?: string | null) => (value ? value.trim().toLowerCase() : null);
const normalizePhone = (value?: string | null) => (value ? value.replace(/\s+/g, "").trim() : null);

const findDuplicateMember = async (email?: string | null, phone?: string | null, excludeId?: string) => {
  const or: any[] = [];
  const emailValue = normalizeEmail(email);
  const phoneValue = normalizePhone(phone);
  if (emailValue) {
    or.push({ email: { equals: emailValue, mode: "insensitive" } });
  }
  if (phoneValue) or.push({ phone: phoneValue });
  if (!or.length) return null;
  const where: any = { OR: or };
  if (excludeId) where.NOT = { id: excludeId };
  return prisma.member.findFirst({ where });
};

membersRouter.get(
  "/",
  requireAuth,
  requirePermission("READ_ALL"),
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
    if (q) {
      where.OR = [
        { name: { contains: q, mode: "insensitive" } },
        { email: { contains: q, mode: "insensitive" } },
        { phone: { contains: q, mode: "insensitive" } },
      ];
    }

    const orderBy = parseSort(sort, ["name", "email", "phone", "status", "dateJoined", "createdAt"], "name");
    if (!orderBy) {
      res.status(400).json(fail("Invalid request", "400", "Invalid sort parameter", buildMeta()));
      return;
    }

    const [total, items] = await Promise.all([
      prisma.member.count({ where }),
      prisma.member.findMany({
        where,
        orderBy,
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);

    res.json(ok(items, "OK", buildMeta(undefined, buildPagination(page, pageSize, total))));
  }
);

membersRouter.get(
  "/lookup",
  requireAuth,
  requireAnyPermission(["DEPT_MEMBER_ADD", "COMMITTEE_MEMBER_ADD"]),
  async (req, res) => {
    const q = String(req.query.q || "").trim();
    if (q.length < 2) {
      res.status(400).json(fail("Invalid request", "400", "Search query must be at least 2 characters", buildMeta()));
      return;
    }
    const items = await prisma.member.findMany({
      where: {
        OR: [
          { name: { contains: q, mode: "insensitive" } },
          { email: { contains: q, mode: "insensitive" } },
          { phone: { contains: q, mode: "insensitive" } },
        ],
      },
      orderBy: { name: "asc" },
      take: 25,
    });
    const data = items.map((m) => ({ id: m.id, name: m.name, email: m.email, phone: m.phone }));
    res.json(ok(data, "OK", buildMeta()));
  }
);

membersRouter.post(
  "/",
  requireAuth,
  requirePermission("MEMBER_CREATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const parsed = createMemberSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid member payload", buildMeta()));
      return;
    }
    const { name, phone, email, gender, status } = parsed.data;
    const normalizedEmail = normalizeEmail(email);
    const normalizedPhone = normalizePhone(phone);
    const duplicate = await findDuplicateMember(normalizedEmail, normalizedPhone);
    if (duplicate) {
      res.status(409).json(fail("Conflict", "409", "Member with the same email or phone already exists", buildMeta()));
      return;
    }
    const now = new Date();
    const member = await prisma.member.create({
      data: {
        name,
        phone: normalizedPhone,
        email: normalizedEmail,
        gender,
        status: status || "Active",
        dateJoined: now.toISOString().slice(0, 10),
        createdBy: actor,
        createdAt: now.toISOString(),
        lastEditedBy: actor,
        lastEditedAt: now.toISOString(),
      },
    });
    res.json(ok(member, "Created", buildMeta()));
  }
);

membersRouter.get(
  "/pastors",
  requireAuth,
  requirePermission("READ_ALL"),
  async (_req, res) => {
    const roles = env.pastorRoles;
    if (!roles.length) {
      res.json(ok([], "OK", buildMeta()));
      return;
    }
    const pastors = await prisma.member.findMany({
      where: { role: { in: roles } },
      orderBy: { name: "asc" },
    });
    res.json(ok(pastors, "OK", buildMeta()));
  }
);

membersRouter.get(
  "/:id",
  requireAuth,
  requirePermission("READ_ALL"),
  async (req, res) => {
    const id = req.params.id;
    const member = await prisma.member.findUnique({ where: { id } });
    if (!member) {
      res.status(404).json(fail("Not found", "404", "Member not found", buildMeta()));
      return;
    }
    const [departments, committees] = await Promise.all([
      prisma.departmentMember.findMany({ where: { memberId: id } }),
      prisma.committeeMember.findMany({ where: { memberId: id } }),
    ]);
    res.json(ok({ member, departments, committees }, "OK", buildMeta()));
  }
);

membersRouter.put(
  "/:id",
  requireAuth,
  requirePermission("MEMBER_UPDATE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    const parsed = updateMemberSchema.safeParse(req.body || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
      return;
    }
    const existing = await prisma.member.findUnique({ where: { id } });
    if (!existing) {
      res.status(404).json(fail("Not found", "404", "Member not found", buildMeta()));
      return;
    }
    const normalizedEmail = normalizeEmail(parsed.data.email ?? null);
    const normalizedPhone = normalizePhone(parsed.data.phone ?? null);
    const duplicate = await findDuplicateMember(normalizedEmail, normalizedPhone, id);
    if (duplicate) {
      res.status(409).json(fail("Conflict", "409", "Member with the same email or phone already exists", buildMeta()));
      return;
    }
    const data: any = {};
    ["name", "phone", "email", "gender", "status"].forEach((key) => {
      if ((parsed.data as any)[key] !== undefined) data[key] = (parsed.data as any)[key];
    });
    if (data.email !== undefined) data.email = normalizedEmail;
    if (data.phone !== undefined) data.phone = normalizedPhone;
    data.lastEditedBy = actor;
    data.lastEditedAt = new Date().toISOString();
    const member = await prisma.member.update({ where: { id }, data });
    res.json(ok(member, "Updated", buildMeta()));
  }
);

membersRouter.delete(
  "/:id",
  requireAuth,
  requirePermission("MEMBER_DELETE"),
  async (req, res) => {
    const actor = (req as any).userId || "system";
    const id = req.params.id;
    const existing = await prisma.member.findUnique({ where: { id } });
    if (!existing) {
      res.status(404).json(fail("Not found", "404", "Member not found", buildMeta()));
      return;
    }
    await prisma.member.update({
      where: { id },
      data: {
        status: "Inactive",
        lastEditedBy: actor,
        lastEditedAt: new Date().toISOString(),
      },
    });
    res.json(ok(null, "Deactivated", buildMeta()));
  }
);
