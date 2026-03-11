import bcrypt from "bcryptjs";
import { prisma } from "../src/db/client.js";

const nowIso = () => new Date().toISOString();
const createdBy = "seed_test_users";

const normalize = (value?: string | null) => (value || "").trim().toLowerCase();

const ensureDepartment = async (name: string, description: string) => {
  const existing = await prisma.department.findFirst({
    where: { name: { equals: name, mode: "insensitive" } },
  });
  if (existing) return existing;
  return prisma.department.create({
    data: {
      name,
      description,
      status: "Active",
      membersCount: 0,
      createdBy,
      createdAt: nowIso(),
      lastEditedBy: createdBy,
      lastEditedAt: nowIso(),
    },
  });
};

const ensureCommittee = async (name: string, description: string) => {
  const existing = await prisma.committee.findFirst({
    where: { name: { equals: name, mode: "insensitive" } },
  });
  if (existing) return existing;
  return prisma.committee.create({
    data: {
      name,
      description,
      status: "Active",
      createdBy,
      createdAt: nowIso(),
      lastEditedBy: createdBy,
      lastEditedAt: nowIso(),
    },
  });
};

const ensureMember = async (payload: { name: string; email: string; phone: string; gender?: string; role?: string }) => {
  const existing = await prisma.member.findFirst({
    where: { email: { equals: payload.email, mode: "insensitive" } },
  });
  if (existing) return existing;
  return prisma.member.create({
    data: {
      name: payload.name,
      email: payload.email,
      phone: payload.phone,
      gender: payload.gender || "Other",
      role: payload.role || "Member",
      status: "Active",
      dateJoined: nowIso().slice(0, 10),
      createdBy,
      createdAt: nowIso(),
      lastEditedBy: createdBy,
      lastEditedAt: nowIso(),
    },
  });
};

const ensureDepartmentMember = async (departmentId: string, memberId: string, role: string) => {
  const existing = await prisma.departmentMember.findFirst({
    where: { departmentId, memberId, role },
  });
  if (existing) return existing;
  return prisma.departmentMember.create({
    data: { departmentId, memberId, role },
  });
};

const ensureCommitteeMember = async (committeeId: string, memberId: string, role: string) => {
  const existing = await prisma.committeeMember.findFirst({
    where: { committeeId, memberId, role },
  });
  if (existing) return existing;
  return prisma.committeeMember.create({
    data: { committeeId, memberId, role },
  });
};

const buildGroupPermissions = async () => {
  const [groups, roles, permissions, groupRoles, rolePermissions] = await Promise.all([
    prisma.group.findMany(),
    prisma.role.findMany(),
    prisma.permission.findMany(),
    prisma.groupRole.findMany(),
    prisma.rolePermission.findMany(),
  ]);
  const permById = new Map(permissions.map((p) => [p.id, p.name || ""]));
  const roleById = new Map(roles.map((r) => [r.id, r.name || ""]));

  const rolePerms = new Map<string, Set<string>>();
  rolePermissions.forEach((rp) => {
    const name = permById.get(rp.permissionId) || "";
    if (!rolePerms.has(rp.roleId)) rolePerms.set(rp.roleId, new Set());
    rolePerms.get(rp.roleId)!.add(name);
  });

  const groupPerms = new Map<string, Set<string>>();
  const groupRoleMap = new Map<string, Set<string>>();
  groupRoles.forEach((gr) => {
    if (!groupRoleMap.has(gr.groupId)) groupRoleMap.set(gr.groupId, new Set());
    groupRoleMap.get(gr.groupId)!.add(gr.roleId);
    const roleSet = rolePerms.get(gr.roleId) || new Set();
    if (!groupPerms.has(gr.groupId)) groupPerms.set(gr.groupId, new Set());
    const target = groupPerms.get(gr.groupId)!;
    roleSet.forEach((perm) => target.add(perm));
  });

  return { groups, roles, permissions, roleById, permById, rolePerms, groupPerms, groupRoleMap };
};

const findGroupByName = (groups: { id: string; name: string | null }[], needle: string) => {
  const n = needle.toLowerCase();
  return groups.find((g) => (g.name || "").toLowerCase().includes(n)) || null;
};

const pickGroupByPermissions = (
  groups: { id: string; name: string | null }[],
  groupPerms: Map<string, Set<string>>,
  required: string[],
  preferredName?: string,
) => {
  const requiredSet = new Set(required.map((p) => p.toUpperCase()));
  const matchesRequired = groups.filter((g) => {
    const perms = groupPerms.get(g.id) || new Set();
    for (const req of requiredSet) {
      if (![...perms].some((p) => (p || "").toUpperCase() === req)) return false;
    }
    return true;
  });
  if (preferredName) {
    const preferred = matchesRequired.find((g) => (g.name || "").toLowerCase().includes(preferredName.toLowerCase()));
    if (preferred) return preferred;
  }
  if (matchesRequired.length) {
    return matchesRequired.sort((a, b) => (groupPerms.get(b.id)?.size || 0) - (groupPerms.get(a.id)?.size || 0))[0];
  }
  return null;
};

const pickRoleCover = (roles: { id: string; name: string | null }[], rolePerms: Map<string, Set<string>>, required: string[]) => {
  const remaining = new Set(required.map((p) => p.toUpperCase()));
  const selected: string[] = [];
  while (remaining.size) {
    let bestRole: string | null = null;
    let bestCover = 0;
    roles.forEach((role) => {
      const perms = rolePerms.get(role.id) || new Set();
      const cover = [...perms].filter((p) => remaining.has((p || "").toUpperCase())).length;
      if (cover > bestCover) {
        bestCover = cover;
        bestRole = role.id;
      }
    });
    if (!bestRole || bestCover === 0) break;
    selected.push(bestRole);
    const perms = rolePerms.get(bestRole) || new Set();
    perms.forEach((p) => remaining.delete((p || "").toUpperCase()));
  }
  return { roleIds: selected, missing: Array.from(remaining.values()) };
};

const ensureGroup = async (name: string, description: string) => {
  const existing = await prisma.group.findFirst({
    where: { name: { equals: name, mode: "insensitive" } },
  });
  if (existing) return existing;
  return prisma.group.create({
    data: {
      name,
      description,
      createdBy,
      createdAt: nowIso(),
      lastEditedBy: createdBy,
      lastEditedAt: nowIso(),
    },
  });
};

const ensureGroupRoles = async (groupId: string, roleIds: string[]) => {
  for (const roleId of roleIds) {
    const existing = await prisma.groupRole.findFirst({ where: { groupId, roleId } });
    if (!existing) {
      await prisma.groupRole.create({ data: { groupId, roleId } });
    }
  }
};

const ensureSystemUser = async (payload: {
  id?: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  password: string;
  status?: string;
}) => {
  const existing = await prisma.systemUser.findFirst({
    where: { email: { equals: payload.email, mode: "insensitive" } },
  });
  if (existing) return { user: existing, created: false };
  const passwordHash = await bcrypt.hash(payload.password, 10);
  const user = await prisma.systemUser.create({
    data: {
      id: payload.id,
      name: payload.name,
      email: payload.email,
      phone: payload.phone,
      role: payload.role,
      status: payload.status || "Active",
      passwordHash,
      createdBy,
      createdAt: nowIso(),
      lastEditedBy: createdBy,
      lastEditedAt: nowIso(),
    },
  });
  return { user, created: true };
};

const ensureUserGroups = async (userId: string, groupIds: string[]) => {
  for (const groupId of groupIds) {
    const existing = await prisma.userGroup.findFirst({ where: { userId, groupId } });
    if (!existing) {
      await prisma.userGroup.create({ data: { userId, groupId } });
    }
  }
};

const run = async () => {
  const dept = await ensureDepartment("QA Outreach Department", "QA seeded department");
  const committee = await ensureCommittee("QA Finance Committee", "QA seeded committee");

  const leaderMember = await ensureMember({
    name: "Amina Wafula",
    email: "amina.wafula@qa.local",
    phone: "+254700111001",
    gender: "Female",
    role: "Member",
  });
  const chairMember = await ensureMember({
    name: "Kibet Cheruiyot",
    email: "kibet.cheruiyot@qa.local",
    phone: "+254700111002",
    gender: "Male",
    role: "Member",
  });
  const normalMember = await ensureMember({
    name: "Joyce Wambui",
    email: "joyce.wambui@qa.local",
    phone: "+254700111003",
    gender: "Female",
    role: "Member",
  });
  const deptMember = await ensureMember({
    name: "Martin Kipruto",
    email: "martin.kipruto@qa.local",
    phone: "+254700111004",
    gender: "Male",
    role: "Member",
  });

  await ensureDepartmentMember(dept.id, leaderMember.id, "Leader");
  await ensureDepartmentMember(dept.id, deptMember.id, "Member");
  await ensureCommitteeMember(committee.id, chairMember.id, "Chair");

  const { groups, roles, rolePerms, groupPerms } = await buildGroupPermissions();

  const leaderGroup = findGroupByName(groups, "leader");
  const superGroup = findGroupByName(groups, "super");
  const adminGroup = groups.find((g) => {
    const name = (g.name || "").toLowerCase();
    return name.includes("admin") && !name.includes("super");
  }) || null;

  let resolvedLeaderGroup = leaderGroup;
  const requiredLeaderPerms = ["DEPARTMENT_UPDATE", "COMMITTEE_UPDATE", "SMS_SEND"];
  if (!resolvedLeaderGroup || !pickGroupByPermissions(groups, groupPerms, requiredLeaderPerms, "leader")) {
    const qaLeaderGroup = await ensureGroup("QA Leaders", "QA leader group with scoped access");
    const cover = pickRoleCover(roles, rolePerms, requiredLeaderPerms);
    if (cover.roleIds.length) {
      await ensureGroupRoles(qaLeaderGroup.id, cover.roleIds);
    }
    resolvedLeaderGroup = qaLeaderGroup;
    if (cover.missing.length) {
      console.warn(`Leader group missing permissions: ${cover.missing.join(", ")}`);
    }
  }

  const resolvedSuperGroup = superGroup || pickGroupByPermissions(groups, groupPerms, ["READ_ALL"], "super");
  const resolvedAdminGroup = adminGroup || pickGroupByPermissions(groups, groupPerms, ["READ_ALL"], "admin");

  const superUser = await ensureSystemUser({
    name: "Njoki Karambu",
    email: "qa.superadmin@church.local",
    phone: "+254700900001",
    role: "Super Admin",
    password: "QaSuper123!",
  });
  if (resolvedSuperGroup) {
    await ensureUserGroups(superUser.user.id, [resolvedSuperGroup.id]);
  } else {
    console.warn("No Super Admin group found; super admin user has no group.");
  }

  const adminUser = await ensureSystemUser({
    name: "Peter Kamau",
    email: "qa.admin@church.local",
    phone: "+254700900002",
    role: "Admin",
    password: "QaAdmin123!",
  });
  if (resolvedAdminGroup) {
    await ensureUserGroups(adminUser.user.id, [resolvedAdminGroup.id]);
  } else {
    console.warn("No Admin group found; admin user has no group.");
  }

  const leaderUser = await ensureSystemUser({
    id: leaderMember.id,
    name: leaderMember.name || "Leader",
    email: normalize(leaderMember.email) || "qa.leader@church.local",
    phone: leaderMember.phone || "+254700900003",
    role: "Leader",
    password: "QaLeader123!",
  });
  if (resolvedLeaderGroup) {
    await ensureUserGroups(leaderUser.user.id, [resolvedLeaderGroup.id]);
  } else {
    console.warn("No Leader group found; leader user has no group.");
  }

  await ensureSystemUser({
    name: "Kevin Ouma",
    email: "qa.nogroup@church.local",
    phone: "+254700900004",
    role: "Member",
    password: "QaNoGroup123!",
  });

  console.log("Seed complete.");
  console.log("Test users:");
  console.log("Super Admin -> qa.superadmin@church.local / QaSuper123!");
  console.log("Admin -> qa.admin@church.local / QaAdmin123!");
  console.log("Leader ->", leaderUser.user.email, "/ QaLeader123!");
  console.log("No-group -> qa.nogroup@church.local / QaNoGroup123!");
  console.log("Leader member ID:", leaderMember.id);
  console.log("Chair member ID:", chairMember.id);
  console.log("Normal member ID:", normalMember.id);
  console.log("QA Department ID:", dept.id);
  console.log("QA Committee ID:", committee.id);
};

run()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
