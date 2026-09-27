import { prisma } from "../src/db/client.js";

type SeedMember = {
  name: string;
  phone: string;
  department: string;
  gender: string;
  role?: string;
};

const createdBy = "church_member_import";
const nowIso = () => new Date().toISOString();
const today = () => nowIso().slice(0, 10);

const cleanPhone = (value: string) => value.replace(/[\s._-]/g, "").trim();

const looksLikeUuid = (value?: string | null) =>
  !!value && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);

const looksLikeIsoDate = (value?: string | null) =>
  !!value && /^\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z)?$/.test(value);

const normalizePhoneKey = (value: string) => {
  const digits = value.replace(/[^\d+]/g, "");
  const plain = digits.startsWith("+") ? digits.slice(1) : digits;
  if (/^254\d{9}$/.test(plain)) return plain;
  if (/^0\d{9}$/.test(plain)) return `254${plain.slice(1)}`;
  if (/^7\d{8}$/.test(plain)) return `254${plain}`;
  if (/^1\d{8}$/.test(plain)) return `254${plain}`;
  return plain;
};

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

const findMemberByPhoneVariants = async (phone: string) => {
  const variants = Array.from(
    new Set([
      phone,
      normalizePhoneKey(phone),
      phone.startsWith("+") ? phone.slice(1) : phone,
      phone.startsWith("0") ? `254${phone.slice(1)}` : phone,
      phone.startsWith("254") ? `0${phone.slice(3)}` : phone,
    ]),
  ).filter(Boolean);

  if (!variants.length) return null;

  const member = await prisma.member.findFirst({
    where: {
      OR: variants.map((variant) => ({ phone: variant })),
    },
  });
  return member;
};

const isMalformedMember = (member: { name?: string | null; phone?: string | null }) =>
  looksLikeUuid(member.name) ||
  looksLikeIsoDate(member.name) ||
  looksLikeUuid(member.phone) ||
  looksLikeIsoDate(member.phone) ||
  !member.name ||
  !member.phone;

const seedRows: SeedMember[] = [
  { name: "Elijah Mulwa", phone: "0712943368", department: "Men's Fellowship", gender: "Male" },
  { name: "Mumo Kasamba", phone: "0723115777", department: "Men's Fellowship", gender: "Male" },
  { name: "Dancun Muasya", phone: "0757136769", department: "Men's Fellowship", gender: "Male" },
  { name: "Josphat Kitheka", phone: "0727613773", department: "Men's Fellowship", gender: "Male" },
  { name: "Sammy Syomane", phone: "0714266715", department: "Men's Fellowship", gender: "Male" },
  { name: "Daniel Mumo", phone: "0700608575", department: "Men's Fellowship", gender: "Male" },
  { name: "Paul Nzioki", phone: "0721464052", department: "Men's Fellowship", gender: "Male" },
  { name: "Raphael Musyoka", phone: "0706109196", department: "Men's Fellowship", gender: "Male" },
  { name: "Zebedayo Kisilu", phone: "0702773987", department: "Men's Fellowship", gender: "Male" },
  { name: "Mellick Kasyoka", phone: "0707840518", department: "Women's Fellowship", gender: "Female" },
  { name: "Henny Ngina", phone: "0708402153", department: "Women's Fellowship", gender: "Female" },
  { name: "Caroline Jelimo", phone: "0706389943", department: "Women's Fellowship", gender: "Female" },
  { name: "Hellen Mumbe Zakayo", phone: "0725357971", department: "Women's Fellowship", gender: "Female" },
  { name: "Rose Sam", phone: "0741291683", department: "Women's Fellowship", gender: "Female" },
  { name: "Mirriam Mutungi", phone: "0703233465", department: "Women's Fellowship", gender: "Female" },
  { name: "Catherine Kelvin", phone: "0725845973", department: "Women's Fellowship", gender: "Female" },
  { name: "Christine Mutia", phone: "0796488472", department: "Women's Fellowship", gender: "Female" },
  { name: "Noreen Mumo", phone: "0712062834", department: "Women's Fellowship", gender: "Female" },
  { name: "Josphine Erastus", phone: "0725053072", department: "Women's Fellowship", gender: "Female" },
  { name: "Catherine Katee", phone: "0729225648", department: "Women's Fellowship", gender: "Female" },
  { name: "Peace Kiatu", phone: "0727884863", department: "Women's Fellowship", gender: "Female" },
  { name: "Esther James", phone: "0720791036", department: "Women's Fellowship", gender: "Female" },
  { name: "Veronica Kimwele", phone: "0708647570", department: "Women's Fellowship", gender: "Female" },
  { name: "Esther Mueni", phone: "0711308616", department: "Women's Fellowship", gender: "Female" },
  { name: "Irene Kambua", phone: "0719278933", department: "Women's Fellowship", gender: "Female" },
  { name: "Nancy Alex", phone: "0715793849", department: "Women's Fellowship", gender: "Female" },
  { name: "Edith Sheddie", phone: "0791776487", department: "Women's Fellowship", gender: "Female" },
  { name: "Mercy Mwendwa", phone: "0795053151", department: "Youth Ministry", gender: "Other" },
  { name: "Victor Musembi", phone: "0706712444", department: "Youth Ministry", gender: "Other" },
  { name: "Gracia Mwikali", phone: "0745583214", department: "Youth Ministry", gender: "Other" },
  { name: "Judith Melick", phone: "0719273903", department: "Youth Ministry", gender: "Other" },
  { name: "Sharon Mueni", phone: "0741927114", department: "Youth Ministry", gender: "Other" },
  { name: "Stacy Murugi", phone: "0792928822", department: "Youth Ministry", gender: "Other" },
  { name: "Dorica Musyoka", phone: "0742355075", department: "Youth Ministry", gender: "Other" },
  { name: "Angeline Soi", phone: "0115706565", department: "Youth Ministry", gender: "Other" },
  { name: "Jeniffer Kiio", phone: "0798378138", department: "Youth Ministry", gender: "Other" },
  { name: "Peter Nyaga", phone: "0111392629", department: "Youth Ministry", gender: "Other" },
  { name: "Joshua Ndavuta", phone: "0722822281", department: "Youth Ministry", gender: "Other" },
  { name: "Annah Kavinya", phone: "0704510420", department: "Youth Ministry", gender: "Other" },
  { name: "Trizah Ndanu", phone: "0746738091", department: "Youth Ministry", gender: "Other" },
  { name: "Martin Maluki", phone: "0715103399", department: "Youth Ministry", gender: "Other" },
  { name: "Zakayo", phone: "0797866595", department: "Youth Ministry", gender: "Other" },
  { name: "Judy", phone: "0793398294", department: "Youth Ministry", gender: "Other" },
  { name: "Grace", phone: "0757574894", department: "Youth Ministry", gender: "Other" },
  { name: "Dorah Mwikya", phone: "0742100501", department: "Youth Ministry", gender: "Other" },
  { name: "Zoeivy Wahito", phone: "0791352622", department: "Youth Ministry", gender: "Other" },
  { name: "Caroline Mutiso", phone: "0710404875", department: "Youth Ministry", gender: "Other" },
  { name: "Joel", phone: "+254741361204", department: "Youth Ministry", gender: "Other" },
  { name: "David Caesar", phone: "+254708927082", department: "Youth Ministry", gender: "Other" },
  { name: "Purity Mung'athia", phone: "+254732247445", department: "Youth Ministry", gender: "Other" },
  { name: "Elijah Mumo", phone: "+254794278323", department: "Youth Ministry", gender: "Other" },
  { name: "Mueni Maxsembo", phone: "+254722205014", department: "Youth Ministry", gender: "Other" },
  { name: "Bernard Musembei", phone: "0705221559", department: "Youth Ministry", gender: "Other" },
  { name: "Elizabeth Musili", phone: "0726531526", department: "Youth Ministry", gender: "Other" },
  { name: "Anita Muema", phone: "0757173973", department: "Youth Ministry", gender: "Other" },
  { name: "Lilian Mwendwa", phone: "0700134876", department: "Youth Ministry", gender: "Other" },
  { name: "Jackline Wavinya", phone: "0748458405", department: "Youth Ministry", gender: "Other" },
  { name: "Morris Mulonzya", phone: "0719102194", department: "Youth Ministry", gender: "Other" },
  { name: "Rose Maingi", phone: "+254743790075", department: "Youth Ministry", gender: "Other" },
  { name: "Stanley Maingi", phone: "+254704629893", department: "Youth Ministry", gender: "Other" },
];

const run = async () => {
  const departments = new Map<string, Awaited<ReturnType<typeof ensureDepartment>>>();
  for (const [name, description] of [
    ["Men's Fellowship", "Men's ministry"],
    ["Women's Fellowship", "Women's ministry"],
    ["Youth Ministry", "Youth discipleship and mentorship"],
  ] as const) {
    departments.set(name, await ensureDepartment(name, description));
  }

  const existingMembers = await prisma.member.findMany({ select: { id: true, phone: true } });
  const existingPhoneKeys = new Set(existingMembers.map((member) => normalizePhoneKey(member.phone || "")));
  const seenSeedKeys = new Set<string>();
  const now = nowIso();
  const skippedExisting: string[] = [];
  const skippedDuplicateInput: string[] = [];
  let imported = 0;

  for (const entry of seedRows) {
    const phone = cleanPhone(entry.phone);
    const phoneKey = normalizePhoneKey(phone);
    if (!phoneKey) {
      continue;
    }
    if (seenSeedKeys.has(phoneKey)) {
      skippedDuplicateInput.push(`${entry.name} (${phone})`);
      continue;
    }
    seenSeedKeys.add(phoneKey);

    const existingMember = existingPhoneKeys.has(phoneKey) ? await findMemberByPhoneVariants(phone) : null;
    const member = existingMember && !isMalformedMember(existingMember)
      ? await prisma.member.update({
          where: { id: existingMember.id },
          data: {
            department: entry.department,
            role: entry.role || existingMember.role || "Member",
            gender: existingMember.gender || entry.gender,
            status: existingMember.status || "Active",
            lastEditedBy: createdBy,
            lastEditedAt: now,
          },
        })
      : existingMember
        ? await prisma.member.update({
            where: { id: existingMember.id },
            data: {
              name: entry.name,
              phone,
              email: null,
              gender: entry.gender,
              department: entry.department,
              role: entry.role || "Member",
              status: "Active",
              dateJoined: today(),
              lastEditedBy: createdBy,
              lastEditedAt: now,
            },
          })
        : await prisma.member.create({
            data: {
              name: entry.name,
              phone,
              email: null,
              gender: entry.gender,
              department: entry.department,
              role: entry.role || "Member",
              status: "Active",
              dateJoined: today(),
              createdBy,
              createdAt: now,
              lastEditedBy: createdBy,
              lastEditedAt: now,
            },
          });

    if (existingMember && !isMalformedMember(existingMember)) {
      skippedExisting.push(`${entry.name} (${phone})`);
    }

    const department = departments.get(entry.department);
    if (!department) continue;
    const existingLink = await prisma.departmentMember.findFirst({
      where: { departmentId: department.id, memberId: member.id },
    });
    if (!existingLink) {
      await prisma.departmentMember.create({
        data: {
          departmentId: department.id,
          memberId: member.id,
          role: entry.role || "Member",
        },
      });
    }

    imported += 1;
  }

  console.log(
    JSON.stringify(
      {
        imported,
        uniqueInput: seenSeedKeys.size,
        skippedExisting: skippedExisting.length,
        skippedDuplicateInput: skippedDuplicateInput.length,
      },
      null,
      2,
    ),
  );
  if (skippedExisting.length) {
    console.log("Skipped existing phone numbers:");
    skippedExisting.forEach((row) => console.log(`- ${row}`));
  }
  if (skippedDuplicateInput.length) {
    console.log("Skipped duplicate rows in the provided list:");
    skippedDuplicateInput.forEach((row) => console.log(`- ${row}`));
  }
};

run()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
