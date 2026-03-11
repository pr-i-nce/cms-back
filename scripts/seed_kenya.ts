import { prisma } from "../src/db/client.js";
import bcrypt from "bcryptjs";

const nowIso = () => new Date().toISOString();

const departments = [
  { name: "Worship & Choir", description: "Praise and worship ministry", status: "Active" },
  { name: "Youth Ministry", description: "Youth discipleship and mentorship", status: "Active" },
  { name: "Ushering", description: "Hospitality and seating", status: "Active" },
  { name: "Media & Audio", description: "Sound, projection, livestream", status: "Active" },
  { name: "Children's Ministry", description: "Kids church and teaching", status: "Active" },
  { name: "Prayer & Intercession", description: "Prayer team", status: "Active" },
  { name: "Evangelism & Outreach", description: "Community outreach", status: "Active" },
  { name: "Men's Fellowship", description: "Men's ministry", status: "Active" },
  { name: "Women's Fellowship", description: "Women's ministry", status: "Active" },
  { name: "Hospitality", description: "Visitor care and refreshments", status: "Active" },
];

const committees = [
  { name: "Finance Committee", description: "Budget and stewardship", status: "Active" },
  { name: "Pastoral Care Committee", description: "Member care and follow-up", status: "Active" },
  { name: "Building & Projects Committee", description: "Facilities and projects", status: "Active" },
  { name: "Missions Committee", description: "Missions and partnerships", status: "Active" },
  { name: "Education & Discipleship Committee", description: "Training and discipleship", status: "Active" },
];

const members = [
  { name: "Rev. John Otieno", phone: "0722001101", email: "john.otieno@church.local", gender: "Male", role: "Senior Pastor", status: "Active" },
  { name: "Grace Wanjiku", phone: "0722001102", email: "grace.wanjiku@church.local", gender: "Female", role: "Associate Pastor", status: "Active" },
  { name: "Peter Mwangi", phone: "0722001103", email: "peter.mwangi@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Mary Akinyi", phone: "0722001104", email: "mary.akinyi@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Joseph Kiptoo", phone: "0722001105", email: "joseph.kiptoo@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Anne Njeri", phone: "0722001106", email: "anne.njeri@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "David Ochieng", phone: "0722001107", email: "david.ochieng@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Sarah Chebet", phone: "0722001108", email: "sarah.chebet@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Brian Kimani", phone: "0722001109", email: "brian.kimani@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Lucy Mutiso", phone: "0722001110", email: "lucy.mutiso@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Samuel Kiplagat", phone: "0722001111", email: "samuel.kiplagat@church.local", gender: "Male", role: "Youth Pastor", status: "Active" },
  { name: "Esther Waithera", phone: "0722001112", email: "esther.waithera@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Paul Kariuki", phone: "0722001113", email: "paul.kariuki@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Jane Nyambura", phone: "0722001114", email: "jane.nyambura@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Daniel Mutua", phone: "0722001115", email: "daniel.mutua@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Faith Wairimu", phone: "0722001116", email: "faith.wairimu@church.local", gender: "Female", role: "Member", status: "Active" },
  { name: "Kevin Wamalwa", phone: "0722001117", email: "kevin.wamalwa@church.local", gender: "Male", role: "Member", status: "Active" },
  { name: "Rose Atieno", phone: "0722001118", email: "rose.atieno@church.local", gender: "Female", role: "Member", status: "Active" },
];

const users = [
  { name: "Admin Mwikali", email: "admin@church.local", phone: "+254700000001", role: "Super Admin", status: "Active", password: "Admin123!" },
  { name: "Pastor Otieno", email: "pastor@church.local", phone: "+254700000002", role: "Admin", status: "Active", password: "Pastor123!" },
  { name: "Ruth Wanjiru", email: "ruth.wanjiru@church.local", phone: "+254700000003", role: "Department Head", status: "Active", password: "Ruth123!" },
];

const run = async () => {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE
      users,
      members,
      departments,
      committees,
      department_members,
      committee_members,
      user_groups,
      activities,
      sms_records
    RESTART IDENTITY CASCADE;
  `);

  const now = nowIso();
  const createdBy = "system";

  await prisma.department.createMany({
    data: departments.map((d) => ({
      ...d,
      createdBy,
      createdAt: now,
      lastEditedBy: createdBy,
      lastEditedAt: now,
      membersCount: 0,
    })),
  });

  await prisma.committee.createMany({
    data: committees.map((c) => ({
      ...c,
      createdBy,
      createdAt: now,
      lastEditedBy: createdBy,
      lastEditedAt: now,
    })),
  });

  await prisma.member.createMany({
    data: members.map((m) => ({
      ...m,
      dateJoined: now.slice(0, 10),
      createdBy,
      createdAt: now,
      lastEditedBy: createdBy,
      lastEditedAt: now,
    })),
  });

  const deptList = await prisma.department.findMany();
  const committeeList = await prisma.committee.findMany();
  const memberList = await prisma.member.findMany();

  const byName = (list: any[], name: string) => list.find((item) => item.name === name);

  const assignments = [
    { member: "Peter Mwangi", department: "Worship & Choir", role: "Leader" },
    { member: "Mary Akinyi", department: "Children's Ministry", role: "Leader" },
    { member: "Joseph Kiptoo", department: "Media & Audio", role: "Coordinator" },
    { member: "Anne Njeri", department: "Hospitality", role: "Leader" },
    { member: "David Ochieng", department: "Ushering", role: "Leader" },
    { member: "Sarah Chebet", department: "Prayer & Intercession", role: "Leader" },
    { member: "Brian Kimani", department: "Evangelism & Outreach", role: "Coordinator" },
    { member: "Lucy Mutiso", department: "Women's Fellowship", role: "Leader" },
    { member: "Paul Kariuki", department: "Men's Fellowship", role: "Leader" },
    { member: "Esther Waithera", department: "Youth Ministry", role: "Member" },
    { member: "Samuel Kiplagat", department: "Youth Ministry", role: "Leader" },
    { member: "Kevin Wamalwa", department: "Media & Audio", role: "Member" },
    { member: "Rose Atieno", department: "Hospitality", role: "Member" },
    { member: "Faith Wairimu", department: "Prayer & Intercession", role: "Member" },
  ];

  const multiAssignments = [
    { member: "Peter Mwangi", department: "Media & Audio", role: "Member" },
    { member: "Mary Akinyi", department: "Hospitality", role: "Member" },
    { member: "David Ochieng", department: "Evangelism & Outreach", role: "Member" },
    { member: "Lucy Mutiso", department: "Prayer & Intercession", role: "Member" },
  ];

  await prisma.departmentMember.createMany({
    data: [...assignments, ...multiAssignments].map((a) => ({
      departmentId: byName(deptList, a.department)!.id,
      memberId: byName(memberList, a.member)!.id,
      role: a.role,
    })),
  });

  const committeeAssignments = [
    { member: "Peter Mwangi", committee: "Finance Committee", role: "Chair" },
    { member: "Mary Akinyi", committee: "Education & Discipleship Committee", role: "Chair" },
    { member: "Joseph Kiptoo", committee: "Building & Projects Committee", role: "Coordinator" },
    { member: "Anne Njeri", committee: "Pastoral Care Committee", role: "Secretary" },
    { member: "David Ochieng", committee: "Missions Committee", role: "Chair" },
    { member: "Sarah Chebet", committee: "Pastoral Care Committee", role: "Member" },
    { member: "Brian Kimani", committee: "Finance Committee", role: "Member" },
    { member: "Lucy Mutiso", committee: "Education & Discipleship Committee", role: "Member" },
  ];

  const committeeMultiAssignments = [
    { member: "Peter Mwangi", committee: "Building & Projects Committee", role: "Member" },
    { member: "Mary Akinyi", committee: "Pastoral Care Committee", role: "Member" },
    { member: "David Ochieng", committee: "Finance Committee", role: "Member" },
  ];

  await prisma.committeeMember.createMany({
    data: [...committeeAssignments, ...committeeMultiAssignments].map((a) => ({
      committeeId: byName(committeeList, a.committee)!.id,
      memberId: byName(memberList, a.member)!.id,
      role: a.role,
    })),
  });

  const userRows = await Promise.all(
    users.map(async (u) => ({
      name: u.name,
      email: u.email,
      phone: u.phone,
      role: u.role,
      status: u.status,
      passwordHash: await bcrypt.hash(u.password, 10),
      createdBy,
      createdAt: now,
      lastEditedBy: createdBy,
      lastEditedAt: now,
    }))
  );

  await prisma.systemUser.createMany({ data: userRows });
};

run()
  .then(() => {
    console.log("Seed complete.");
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
