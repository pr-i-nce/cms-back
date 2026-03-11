import { prisma } from "../db/client.js";
export const resolvePermissions = async (userId) => {
    const allPermissions = await prisma.permission.findMany();
    const allNames = allPermissions.map((p) => p.name || "").filter(Boolean);
    const userGroups = await prisma.userGroup.findMany({ where: { userId } });
    if (userGroups.length === 0)
        return [];
    const groupIds = userGroups.map((g) => g.groupId);
    const groups = await prisma.group.findMany({ where: { id: { in: groupIds } } });
    const names = groups.map((g) => (g.name || "").toLowerCase());
    const isSuperAdmin = names.some((name) => name.includes("super") && name.includes("admin"));
    if (isSuperAdmin)
        return allNames;
    const isAdmin = names.some((name) => name === "admin" || (name.includes("admin") && !name.includes("super")));
    if (isAdmin) {
        return allNames.filter((name) => !name.startsWith("BRANCH_") && !name.startsWith("USER_"));
    }
    const isLeader = names.some((name) => name.includes("leader"));
    if (isLeader) {
        return [
            "DEPARTMENT_UPDATE",
            "DEPARTMENT_DEACTIVATE",
            "DEPT_MEMBER_ADD",
            "DEPT_MEMBER_REMOVE",
            "COMMITTEE_UPDATE",
            "COMMITTEE_DEACTIVATE",
            "COMMITTEE_MEMBER_ADD",
            "COMMITTEE_MEMBER_REMOVE",
            "MEMBER_UPDATE",
            "SMS_SEND",
            "SMS_VIEW",
        ];
    }
    return [];
};
