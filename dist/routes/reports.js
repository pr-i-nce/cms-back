import { Router } from "express";
import { prisma } from "../db/client.js";
import { ok } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { requireAuth } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { cached } from "../utils/cache.js";
import { env } from "../config/env.js";
export const reportsRouter = Router();
reportsRouter.get("/summary", requireAuth, requirePermission("READ_ALL"), async (_req, res) => {
    const data = await cached("reports:summary", env.cacheTtl.reportsMs, async () => {
        const membershipRows = await prisma.$queryRaw `select substring(date_joined,1,7) as month, count(*)::int as count from members where date_joined is not null group by month order by month`;
        let cumulative = 0;
        const membershipTrend = membershipRows.map((row) => {
            cumulative += Number(row.count);
            return { month: row.month, members: cumulative, newMembers: Number(row.count) };
        });
        const deptCounts = await prisma.$queryRaw `select department_id, count(*)::int as count from department_members group by department_id`;
        const departments = await prisma.department.findMany();
        const deptMap = new Map(deptCounts.map((r) => [r.department_id, r.count]));
        const departmentDistribution = departments
            .map((d) => ({ department: d.name, count: deptMap.get(d.id) ?? 0 }))
            .sort((a, b) => String(a.department).localeCompare(String(b.department)));
        const smsRows = await prisma.$queryRaw `select substring(date,1,7) as month, status, count(*)::int as count from sms_records where date is not null group by month, status order by month`;
        const deliveredByMonth = {};
        const failedByMonth = {};
        const months = new Set();
        smsRows.forEach((row) => {
            months.add(row.month);
            const status = String(row.status || "");
            if (status.toLowerCase() === "delivered" || status.toLowerCase() === "sent") {
                deliveredByMonth[row.month] = (deliveredByMonth[row.month] || 0) + Number(row.count);
            }
            else if (status.toLowerCase() === "failed") {
                failedByMonth[row.month] = (failedByMonth[row.month] || 0) + Number(row.count);
            }
        });
        const smsActivity = Array.from(months).map((month) => {
            const delivered = deliveredByMonth[month] || 0;
            const failed = failedByMonth[month] || 0;
            return { month, delivered, failed, count: delivered + failed };
        });
        return { membershipTrend, departmentDistribution, smsActivity };
    });
    res.json(ok(data, "OK", buildMeta()));
});
reportsRouter.get("/dashboard", requireAuth, requirePermission("READ_ALL"), async (_req, res) => {
    const data = await cached("reports:dashboard", env.cacheTtl.reportsMs, async () => {
        const totalMembers = await prisma.member.count();
        const activeMembers = await prisma.member.count({ where: { status: "Active" } });
        const latestMonthRow = await prisma.$queryRaw `select max(substring(date_joined,1,7)) as month from members`;
        const latestMonth = latestMonthRow[0]?.month || null;
        const newMembers = latestMonth
            ? await prisma.member.count({ where: { dateJoined: { startsWith: latestMonth } } })
            : 0;
        const totalDepartments = await prisma.department.count();
        const deptCounts = await prisma.$queryRaw `select department_id, count(*)::int as count from department_members group by department_id`;
        const departments = await prisma.department.findMany();
        const deptMap = new Map(deptCounts.map((r) => [r.department_id, r.count]));
        const topDepartments = departments
            .map((d) => ({ id: d.id, name: d.name, count: deptMap.get(d.id) ?? 0 }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 3);
        const smsByStatus = await prisma.$queryRaw `select status, count(*)::int as count from sms_records group by status`;
        const smsMap = new Map(smsByStatus.map((r) => [String(r.status || "").toLowerCase(), Number(r.count)]));
        const smsDelivered = (smsMap.get("delivered") || 0) + (smsMap.get("sent") || 0);
        const smsFailed = smsMap.get("failed") || 0;
        const smsTotal = Array.from(smsMap.values()).reduce((sum, v) => sum + v, 0);
        const smsDeliveryRate = smsTotal ? Math.round((smsDelivered * 100) / smsTotal) : 0;
        const latestSms = await prisma.smsRecord.findFirst({ orderBy: { date: "desc" } });
        const recentActivities = await prisma.activity.findMany({ orderBy: { time: "desc" }, take: 10 });
        return {
            totalMembers,
            activeMembers,
            newMembers,
            newMembersMonth: latestMonth,
            totalDepartments,
            topDepartments,
            smsTotal,
            smsDelivered,
            smsFailed,
            smsDeliveryRate,
            latestSms,
            recentActivities,
        };
    });
    res.json(ok(data, "OK", buildMeta()));
});
reportsRouter.get("/dashboard-full", requireAuth, requirePermission("READ_ALL"), async (_req, res) => {
    const data = await cached("reports:dashboard:full", env.cacheTtl.reportsMs, async () => {
        const membershipRows = await prisma.$queryRaw `select substring(date_joined,1,7) as month, count(*)::int as count from members where date_joined is not null group by month order by month`;
        let cumulative = 0;
        const membershipTrend = membershipRows.map((row) => {
            cumulative += Number(row.count);
            return { month: row.month, members: cumulative, newMembers: Number(row.count) };
        });
        const deptCounts = await prisma.$queryRaw `select department_id, count(*)::int as count from department_members group by department_id`;
        const departments = await prisma.department.findMany();
        const deptMap = new Map(deptCounts.map((r) => [r.department_id, r.count]));
        const departmentDistribution = departments
            .map((d) => ({ department: d.name, count: deptMap.get(d.id) ?? 0 }))
            .sort((a, b) => String(a.department).localeCompare(String(b.department)));
        const smsRows = await prisma.$queryRaw `select substring(date,1,7) as month, status, count(*)::int as count from sms_records where date is not null group by month, status order by month`;
        const deliveredByMonth = {};
        const failedByMonth = {};
        const months = new Set();
        smsRows.forEach((row) => {
            months.add(row.month);
            const status = String(row.status || "");
            if (status.toLowerCase() === "delivered" || status.toLowerCase() === "sent") {
                deliveredByMonth[row.month] = (deliveredByMonth[row.month] || 0) + Number(row.count);
            }
            else if (status.toLowerCase() === "failed") {
                failedByMonth[row.month] = (failedByMonth[row.month] || 0) + Number(row.count);
            }
        });
        const smsActivity = Array.from(months).map((month) => {
            const delivered = deliveredByMonth[month] || 0;
            const failed = failedByMonth[month] || 0;
            return { month, delivered, failed, count: delivered + failed };
        });
        const totalMembers = await prisma.member.count();
        const activeMembers = await prisma.member.count({ where: { status: "Active" } });
        const latestMonthRow = await prisma.$queryRaw `select max(substring(date_joined,1,7)) as month from members`;
        const latestMonth = latestMonthRow[0]?.month || null;
        const newMembers = latestMonth
            ? await prisma.member.count({ where: { dateJoined: { startsWith: latestMonth } } })
            : 0;
        const totalDepartments = await prisma.department.count();
        const topDepartments = departments
            .map((d) => ({ id: d.id, name: d.name, count: deptMap.get(d.id) ?? 0 }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 3);
        const smsByStatus = await prisma.$queryRaw `select status, count(*)::int as count from sms_records group by status`;
        const smsMap = new Map(smsByStatus.map((r) => [String(r.status || "").toLowerCase(), Number(r.count)]));
        const smsDelivered = (smsMap.get("delivered") || 0) + (smsMap.get("sent") || 0);
        const smsFailed = smsMap.get("failed") || 0;
        const smsTotal = Array.from(smsMap.values()).reduce((sum, v) => sum + v, 0);
        const smsDeliveryRate = smsTotal ? Math.round((smsDelivered * 100) / smsTotal) : 0;
        const latestSms = await prisma.smsRecord.findFirst({ orderBy: { date: "desc" } });
        const recentActivities = await prisma.activity.findMany({ orderBy: { time: "desc" }, take: 10 });
        return {
            totalMembers,
            activeMembers,
            newMembers,
            newMembersMonth: latestMonth,
            totalDepartments,
            topDepartments,
            smsTotal,
            smsDelivered,
            smsFailed,
            smsDeliveryRate,
            latestSms,
            recentActivities,
            membershipTrend,
            departmentDistribution,
            smsActivity,
        };
    });
    res.json(ok(data, "OK", buildMeta()));
});
