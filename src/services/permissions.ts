import { prisma } from "../db/client.js";
import { env } from "../config/env.js";

export const resolvePermissions = async (userId: string): Promise<string[]> => {
  const allPermissions = await prisma.permission.findMany();
  const allNames = allPermissions.map((p) => p.name || "").filter(Boolean);

  const userGroups = await prisma.userGroup.findMany({ where: { userId } });
  if (userGroups.length === 0) return [];
  const groupIds = userGroups.map((g) => g.groupId);
  const groups = await prisma.group.findMany({ where: { id: { in: groupIds } } });
  const names = groups.map((g) => (g.name || "").toLowerCase());

  const isSuperAdmin = names.some((name) => name.includes("super") && name.includes("admin"));
  if (isSuperAdmin) return allNames;

  const groupRoles = await prisma.groupRole.findMany({ where: { groupId: { in: groupIds } } });
  const roleIds = Array.from(new Set(groupRoles.map((link) => link.roleId)));
  if (roleIds.length) {
    const rolePermissions = await prisma.rolePermission.findMany({
      where: { roleId: { in: roleIds } },
      include: { permission: true },
    });
    const configuredPermissions = Array.from(new Set(
      rolePermissions.map((link) => link.permission.name || "").filter(Boolean),
    ));
    return configuredPermissions;
  }

  // Keep the legacy leader baseline until all leader groups have explicit role grants.
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
