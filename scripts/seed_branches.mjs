import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const nowIso = () => new Date().toISOString();

const branches = [
  { name: "PCC Main Campus", location: "Nairobi", address: "Kasarani", phone: "+254700000010", email: "main@church.local" },
  { name: "PCC Westlands", location: "Nairobi", address: "Westlands", phone: "+254700000011", email: "westlands@church.local" },
  { name: "PCC Thika", location: "Thika", address: "Thika Road", phone: "+254700000012", email: "thika@church.local" },
];

const assignments = [
  { branch: "PCC Main Campus", pastorName: "Rev. John Otieno", role: "Senior Pastor" },
  { branch: "PCC Westlands", pastorName: "Grace Wanjiku", role: "Associate Pastor" },
  { branch: "PCC Thika", pastorName: "Samuel Kiplagat", role: "Youth Pastor" },
];

const run = async () => {
  const existingResult = await prisma.$queryRaw`select count(*)::bigint as count from branches`;
  const existing = Number(existingResult[0]?.count ?? 0);
  if (existing > 0) {
    console.log("Branches already seeded.");
    return;
  }

  const now = nowIso();
  const createdBy = "system";
  for (const b of branches) {
    await prisma.$executeRaw`
      insert into branches (name, location, address, phone, email, status, created_by, created_at, last_edited_by, last_edited_at)
      values (${b.name}, ${b.location}, ${b.address}, ${b.phone}, ${b.email}, 'Active', ${createdBy}, ${now}, ${createdBy}, ${now})
    `;
  }

  const branchList = await prisma.$queryRaw`select id, name from branches`;
  const memberList = await prisma.$queryRaw`select id, name from members`;
  const branchByName = new Map(branchList.map((b) => [b.name, b]));
  const memberByName = new Map(memberList.map((m) => [m.name, m]));

  const data = assignments
    .map((a) => {
      const branch = branchByName.get(a.branch);
      const member = memberByName.get(a.pastorName);
      if (!branch || !member) return null;
      return { branchId: branch.id, memberId: member.id, role: a.role };
    })
    .filter(Boolean);

  for (const item of data) {
    await prisma.$executeRaw`
      insert into branch_pastors (branch_id, member_id, role)
      values (${item.branchId}, ${item.memberId}, ${item.role})
      on conflict (branch_id, member_id) do update set role = excluded.role
    `;
  }
  console.log("Branch seed complete.");
};

run()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
