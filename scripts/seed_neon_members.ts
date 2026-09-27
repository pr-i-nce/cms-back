import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

type SeedMember = {
  name: string;
  phone: string;
  gender: string | null;
  department: string | null;
  role: string | null;
  status: string | null;
};

const backendDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const neonUrl = process.env.NEON_DATABASE_URL;
const apply = process.argv.includes("--apply");
const syncSchema = process.argv.includes("--sync-schema");

if (!neonUrl) {
  console.error("Set NEON_DATABASE_URL to the Neon PostgreSQL connection string.");
  process.exit(1);
}

let neonHost: string;
try {
  neonHost = new URL(neonUrl).hostname.toLowerCase();
} catch {
  console.error("NEON_DATABASE_URL is not a valid PostgreSQL URL.");
  process.exit(1);
}

if (!neonHost.endsWith(".neon.tech")) {
  console.error(`Refusing to use non-Neon host: ${neonHost}`);
  process.exit(1);
}

// Override cms-back/.env explicitly so a local DATABASE_URL can never be selected by mistake.
process.env.DATABASE_URL = neonUrl;

if (syncSchema) {
  const result = spawnSync(
    "npx",
    ["prisma", "db", "push", "--schema", "prisma/schema.prisma", "--skip-generate"],
    { cwd: backendDir, env: { ...process.env, DATABASE_URL: neonUrl }, stdio: "inherit" },
  );
  if (result.status !== 0) {
    console.error("Prisma schema sync did not complete; member seeding was stopped.");
    process.exit(result.status ?? 1);
  }
}

const members = JSON.parse(
  readFileSync(path.join(backendDir, "data", "neon_member_seed.json"), "utf8"),
) as SeedMember[];

const normalizePhoneKey = (phone: string) => {
  const digits = phone.replace(/\D/g, "");
  if (/^254[17]\d{8}$/.test(digits)) return digits;
  if (/^0[17]\d{8}$/.test(digits)) return `254${digits.slice(1)}`;
  if (/^[17]\d{8}$/.test(digits)) return `254${digits}`;
  return digits;
};

const normalizeName = (value: string) => value.trim().toLocaleLowerCase();

const run = async () => {
  const { prisma } = await import("../src/db/client.js");
  try {
    const current = await prisma.member.findMany({ select: { phone: true } });
    const currentPhones = new Set(
      current.map((member) => normalizePhoneKey(member.phone || "")).filter(Boolean),
    );
    const seen = new Set<string>();
    const pending: SeedMember[] = [];
    let skippedNoPhone = 0;
    let skippedRepeatInSeed = 0;

    for (const member of members) {
      const key = normalizePhoneKey(member.phone || "");
      if (!key) {
        skippedNoPhone += 1;
        continue;
      }
      if (seen.has(key)) {
        skippedRepeatInSeed += 1;
        continue;
      }
      seen.add(key);
      if (currentPhones.has(key)) continue;
      currentPhones.add(key);
      pending.push(member);
    }

    const byDepartment = new Map<string, number>();
    for (const member of pending) {
      const department = member.department || "(no department)";
      byDepartment.set(department, (byDepartment.get(department) || 0) + 1);
    }

    console.log(JSON.stringify({
      target: "Neon",
      mode: apply ? "apply" : "dry-run",
      existingMemberCount: current.length,
      sourceMemberCount: members.length,
      toAdd: pending.length,
      skippedExistingOrEarlierSource: members.length - pending.length - skippedNoPhone - skippedRepeatInSeed,
      skippedNoPhone,
      skippedRepeatInSeed,
      toAddByDepartment: Object.fromEntries(byDepartment),
    }, null, 2));

    if (!apply) {
      console.log("Dry run only. Pass --apply to write members and department assignments.");
      return;
    }

    const departments = new Map<string, { id: string }>();
    const now = new Date().toISOString();
    for (const member of pending) {
      const departmentName = member.department?.trim();
      let department: { id: string } | undefined;
      if (departmentName) {
        const departmentKey = normalizeName(departmentName);
        department = departments.get(departmentKey);
        if (!department) {
          department = (await prisma.department.findFirst({
            where: { name: { equals: departmentName, mode: "insensitive" } },
            select: { id: true },
          })) || undefined;
          if (!department) {
            department = await prisma.department.create({
              data: {
                name: departmentName,
                status: "Active",
                membersCount: 0,
                createdBy: "neon_member_seed",
                createdAt: now,
                lastEditedBy: "neon_member_seed",
                lastEditedAt: now,
              },
              select: { id: true },
            });
          }
          departments.set(departmentKey, department);
        }
      }

      const created = await prisma.member.create({
        data: {
          name: member.name.trim(),
          phone: member.phone.trim(),
          gender: member.gender,
          department: departmentName || null,
          role: member.role || "Member",
          status: member.status || "Active",
          createdBy: "neon_member_seed",
          createdAt: now,
          lastEditedBy: "neon_member_seed",
          lastEditedAt: now,
        },
        select: { id: true },
      });

      if (department) {
        await prisma.departmentMember.create({
          data: { departmentId: department.id, memberId: created.id, role: member.role || "Member" },
        });
      }
    }

    console.log(`Inserted ${pending.length} members and their department assignments.`);
  } finally {
    await prisma.$disconnect();
  }
};

run().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  if (message.includes("does not exist") || message.includes("P2021")) {
    console.error("Application tables are missing. Re-run with --sync-schema to create them first.");
  } else {
    console.error(message);
  }
  process.exit(1);
});
