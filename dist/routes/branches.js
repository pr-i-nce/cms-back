import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { z } from "zod";
import { env } from "../config/env.js";
import { Prisma } from "@prisma/client";
import { listQuerySchema, parseSort } from "../utils/query.js";
export const branchesRouter = Router();
const createBranchSchema = z.object({
    name: z.string().min(2),
    location: z.string().optional().nullable(),
    address: z.string().optional().nullable(),
    phone: z.string().optional().nullable(),
    email: z.string().email().optional().nullable(),
});
const updateBranchSchema = z.object({
    name: z.string().min(2).optional(),
    location: z.string().optional().nullable(),
    address: z.string().optional().nullable(),
    phone: z.string().optional().nullable(),
    email: z.string().email().optional().nullable(),
    status: z.enum(["Active", "Inactive"]).optional().nullable(),
});
const assignPastorSchema = z.object({
    memberId: z.string().uuid(),
    role: z.string().optional().nullable(),
}).superRefine((data, ctx) => {
    if (data.role && !env.pastorRoles.includes(data.role)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: "Invalid pastor role" });
    }
});
const buildPagination = (page, pageSize, total) => ({
    page,
    pageSize,
    total,
    totalPages: Math.max(1, Math.ceil(total / pageSize)),
});
branchesRouter.get("/", requireAuth, requirePermission("BRANCH_UPDATE"), async (req, res) => {
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
    const offset = (page - 1) * pageSize;
    const where = [];
    const params = [];
    if (status) {
        params.push(status);
        where.push(`status = $${params.length}`);
    }
    if (q) {
        params.push(`%${q}%`);
        where.push(`name ILIKE $${params.length}`);
    }
    const orderBy = parseSort(sort, ["name", "status", "created_at", "createdAt"], "name");
    if (!orderBy) {
        res.status(400).json(fail("Invalid request", "400", "Invalid sort parameter", buildMeta()));
        return;
    }
    const whereSql = where.length ? `where ${where.join(" and ")}` : "";
    const totalResult = await prisma.$queryRawUnsafe(`select count(*)::bigint as count from branches ${whereSql}`, ...params);
    const total = Number(totalResult[0]?.count ?? 0);
    const orderKey = Object.keys(orderBy)[0];
    const orderDir = orderBy[orderKey];
    const orderSql = orderKey === "createdAt" ? "created_at" : orderKey;
    const rows = await prisma.$queryRawUnsafe(`select b.*, coalesce(count(bp.branch_id),0)::int as "pastorsCount"
       from branches b
       left join branch_pastors bp on bp.branch_id = b.id
       ${whereSql}
       group by b.id
       order by b.${orderSql} ${orderDir}
       limit $${params.length + 1} offset $${params.length + 2}`, ...params, pageSize, offset);
    res.json(ok(rows, "OK", buildMeta(undefined, buildPagination(page, pageSize, total))));
});
branchesRouter.get("/pastors", requireAuth, requirePermission("BRANCH_UPDATE"), async (_req, res) => {
    const rows = await prisma.$queryRawUnsafe(`select bp.branch_id as "branchId", b.name as "branchName", bp.role,
              m.id as "memberId", m.name, m.phone, m.email, m.role as "memberRole"
       from branch_pastors bp
       join branches b on b.id = bp.branch_id
       join members m on m.id = bp.member_id
       order by b.name asc, m.name asc`);
    const data = rows.map((row) => ({
        branchId: row.branchId,
        branchName: row.branchName,
        role: row.role,
        member: {
            id: row.memberId,
            name: row.name,
            phone: row.phone,
            email: row.email,
            role: row.memberRole,
        },
    }));
    res.json(ok(data, "OK", buildMeta()));
});
branchesRouter.post("/", requireAuth, requirePermission("BRANCH_CREATE"), async (req, res) => {
    const actor = req.userId || "system";
    const parsed = createBranchSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid branch payload", buildMeta()));
        return;
    }
    const now = new Date().toISOString();
    const row = await prisma.$queryRaw `
      insert into branches (name, location, address, phone, email, status, created_by, created_at, last_edited_by, last_edited_at)
      values (${parsed.data.name}, ${parsed.data.location}, ${parsed.data.address}, ${parsed.data.phone}, ${parsed.data.email}, 'Active', ${actor}, ${now}, ${actor}, ${now})
      returning *`;
    res.json(ok(row[0], "Created", buildMeta()));
});
branchesRouter.get("/:id", requireAuth, requirePermission("BRANCH_UPDATE"), async (req, res) => {
    const id = req.params.id;
    const branchRows = await prisma.$queryRaw `select * from branches where id = ${id} limit 1`;
    const branch = branchRows[0];
    if (!branch) {
        res.status(404).json(fail("Not found", "404", "Branch not found", buildMeta()));
        return;
    }
    const pastorRows = await prisma.$queryRaw `
      select bp.member_id as "memberId", bp.role,
             m.id, m.name, m.phone, m.email, m.role as "memberRole"
      from branch_pastors bp
      join members m on m.id = bp.member_id
      where bp.branch_id = ${id}
      order by m.name asc`;
    const pastors = pastorRows.map((row) => ({
        memberId: row.memberId,
        role: row.role,
        member: {
            id: row.id,
            name: row.name,
            phone: row.phone,
            email: row.email,
            role: row.memberRole,
        },
    }));
    res.json(ok({ branch, pastors }, "OK", buildMeta()));
});
branchesRouter.put("/:id", requireAuth, requirePermission("BRANCH_UPDATE"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const parsed = updateBranchSchema.safeParse(req.body || {});
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid update payload", buildMeta()));
        return;
    }
    const now = new Date().toISOString();
    const fields = ["name", "location", "address", "phone", "email", "status"];
    const updates = [];
    fields.forEach((key) => {
        const value = parsed.data[key];
        if (value !== undefined) {
            updates.push(Prisma.sql `${Prisma.raw(key)} = ${value}`);
        }
    });
    updates.push(Prisma.sql `last_edited_by = ${actor}`);
    updates.push(Prisma.sql `last_edited_at = ${now}`);
    if (!updates.length) {
        res.status(400).json(fail("Invalid request", "400", "No fields to update", buildMeta()));
        return;
    }
    const row = await prisma.$queryRaw `
      update branches set ${Prisma.join(updates, ", ")} where id = ${id} returning *`;
    if (!row[0]) {
        res.status(404).json(fail("Not found", "404", "Branch not found", buildMeta()));
        return;
    }
    res.json(ok(row[0], "Updated", buildMeta()));
});
branchesRouter.post("/:id/deactivate", requireAuth, requirePermission("BRANCH_DEACTIVATE"), async (req, res) => {
    const actor = req.userId || "system";
    const id = req.params.id;
    const now = new Date().toISOString();
    const row = await prisma.$queryRaw `
      update branches set status = 'Inactive', last_edited_by = ${actor}, last_edited_at = ${now} where id = ${id} returning *`;
    if (!row[0]) {
        res.status(404).json(fail("Not found", "404", "Branch not found", buildMeta()));
        return;
    }
    res.json(ok(row[0], "Deactivated", buildMeta()));
});
branchesRouter.get("/:id/pastors", requireAuth, requirePermission("BRANCH_UPDATE"), async (req, res) => {
    const id = req.params.id;
    const rows = await prisma.$queryRaw `
      select bp.member_id as "memberId", bp.role,
             m.id, m.name, m.phone, m.email, m.role as "memberRole"
      from branch_pastors bp
      join members m on m.id = bp.member_id
      where bp.branch_id = ${id}
      order by m.name asc`;
    const data = rows.map((row) => ({
        memberId: row.memberId,
        role: row.role,
        member: {
            id: row.id,
            name: row.name,
            phone: row.phone,
            email: row.email,
            role: row.memberRole,
        },
    }));
    res.json(ok(data, "OK", buildMeta()));
});
branchesRouter.post("/:id/pastors", requireAuth, requirePermission("BRANCH_PASTOR_ADD"), async (req, res) => {
    const id = req.params.id;
    const parsed = assignPastorSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json(fail("Invalid request", "400", "Invalid pastor assignment payload", buildMeta()));
        return;
    }
    const { memberId, role } = parsed.data;
    const row = await prisma.$queryRaw `
      insert into branch_pastors (branch_id, member_id, role)
      values (${id}, ${memberId}, ${role})
      on conflict (branch_id, member_id) do update set role = excluded.role
      returning *`;
    res.json(ok(row[0], "Created", buildMeta()));
});
branchesRouter.delete("/:id/pastors/:memberId", requireAuth, requirePermission("BRANCH_PASTOR_REMOVE"), async (req, res) => {
    const { id, memberId } = req.params;
    await prisma.$executeRaw `delete from branch_pastors where branch_id = ${id} and member_id = ${memberId}`;
    res.json(ok(null, "Removed", buildMeta()));
});
