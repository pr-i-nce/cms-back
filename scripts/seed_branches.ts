import { prisma } from "../src/db/client.js";

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
  const existing = await prisma.branch.count();
  if (existing > 0) {
    console.log("Branches already seeded.");
    return;
  }

  const now = nowIso();
  const createdBy = "system";
  await prisma.branch.createMany({
    data: branches.map((b) => ({
      ...b,
      status: "Active",
      createdBy,
      createdAt: now,
      lastEditedBy: createdBy,
      lastEditedAt: now,
    })),
  });

  const branchList = await prisma.branch.findMany();
  const memberList = await prisma.member.findMany();
  const branchByName = new Map(branchList.map((b) => [b.name, b]));
  const memberByName = new Map(memberList.map((m) => [m.name, m]));

  const data = assignments
    .map((a) => {
      const branch = branchByName.get(a.branch);
      const member = memberByName.get(a.pastorName);
      if (!branch || !member) return null;
      return { branchId: branch.id, memberId: member.id, role: a.role };
    })
    .filter(Boolean) as { branchId: string; memberId: string; role?: string }[];

  if (data.length) {
    await prisma.branchPastor.createMany({ data, skipDuplicates: true });
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
