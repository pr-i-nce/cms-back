import { prisma } from "../db/client.js";
import { env } from "../config/env.js";
import https from "https";

export type SmsSendRequest = {
  recipientType: string;
  recipientId?: string;
  recipientIds?: string[];
  recipientCategory?: string;
  customNumber?: string;
  greeting?: string;
  message: string;
  personalize?: boolean;
  sendMode?: string;
  timeToSend?: string;
};

type SmsPayload = { mobile: string; message: string };

type CelcomResult = {
  success: boolean;
  code?: string;
  message?: string;
  rawResponse?: string;
};

export const listSms = async (page: number, pageSize: number, q?: string, status?: string) => {
  const where: any = {};
  if (status) where.status = status;
  if (q) {
    where.OR = [
      { message: { contains: q, mode: "insensitive" } },
      { recipients: { contains: q, mode: "insensitive" } },
    ];
  }
  const [total, items] = await Promise.all([
    prisma.smsRecord.count({ where }),
    prisma.smsRecord.findMany({
      where,
      orderBy: { date: "desc" },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
  ]);
  return { total, items };
};

export const templates = () => ([
  { label: "Service reminder", body: "Sunday service starts at 9am. Join us in person or online." },
  { label: "Prayer night", body: "Prayer meeting tonight at 7pm. We would love to see you." },
  { label: "Youth camp", body: "Youth camp registration is now open. Sign up this week." },
]);

export const segments = async () => {
  const members = await prisma.member.findMany();
  const departments = await prisma.department.findMany();
  const assignments = await prisma.departmentMember.findMany();

  const youthDeptIds = new Set(
    departments.filter((d) => (d.name || "").toLowerCase().includes("youth")).map((d) => d.id)
  );
  const youthMemberIds = new Set(
    assignments.filter((a) => youthDeptIds.has(a.departmentId)).map((a) => a.memberId)
  );
  const leaderMemberIds = new Set(
    assignments.filter((a) => {
      const role = (a.role || "").toLowerCase();
      return role.includes("leader") || role.includes("coordinator") || role.includes("chair");
    }).map((a) => a.memberId)
  );

  let latestJoinMonth = "0000-00";
  members.forEach((m) => {
    if (m.dateJoined && m.dateJoined.length >= 7) {
      const month = m.dateJoined.slice(0, 7);
      if (month > latestJoinMonth) latestJoinMonth = month;
    }
  });
  const newMemberIds = new Set(
    members.filter((m) => m.dateJoined?.startsWith(latestJoinMonth)).map((m) => m.id)
  );
  const allMemberIds = new Set(members.map((m) => m.id));

  const toSegment = (key: string, label: string, ids: Set<string>) => ({
    key,
    label,
    count: ids.size,
    memberIds: Array.from(ids).sort(),
  });

  return [
    toSegment("youth", "Youth Members", youthMemberIds),
    toSegment("leaders", "Leaders", leaderMemberIds),
    toSegment("new", "New Members", newMemberIds),
    toSegment("all", "All Members", allMemberIds),
  ];
};

type Recipient = { id?: string; name?: string | null; phone?: string | null };

const normalizePhone = (value?: string | null) => (value ? value.replace(/\s+/g, "").trim() : null);

const isLeaderUser = async (userId: string) => {
  const groups = await prisma.userGroup.findMany({ where: { userId } });
  if (!groups.length) return false;
  const groupIds = groups.map((g) => g.groupId);
  const groupRows = await prisma.group.findMany({ where: { id: { in: groupIds } } });
  return groupRows.some((g) => (g.name || "").toLowerCase().includes("leader"));
};

const resolveLeaderScopes = async (userId: string) => {
  const deptRoles = env.departmentHeadRoles;
  const committeeRoles = env.committeeChairRoles;
  const [deptAssignments, committeeAssignments] = await Promise.all([
    prisma.departmentMember.findMany({
      where: {
        memberId: userId,
        ...(deptRoles.length ? { role: { in: deptRoles } } : {}),
      },
    }),
    prisma.committeeMember.findMany({
      where: {
        memberId: userId,
        ...(committeeRoles.length ? { role: { in: committeeRoles } } : {}),
      },
    }),
  ]);
  return {
    departmentIds: Array.from(new Set(deptAssignments.map((a) => a.departmentId))),
    committeeIds: Array.from(new Set(committeeAssignments.map((a) => a.committeeId))),
  };
};

const resolveRecipients = async (request: SmsSendRequest, senderId?: string): Promise<Recipient[]> => {
  const dedupe = <T extends Recipient>(items: T[]) => {
    const seen = new Set<string>();
    return items.filter((item) => {
      if (!item.id) return false;
      if (seen.has(item.id)) return false;
      seen.add(item.id);
      return true;
    });
  };
  if (senderId && (await isLeaderUser(senderId))) {
    const { departmentIds, committeeIds } = await resolveLeaderScopes(senderId);
    if (request.recipientType === "department") {
      if (!request.recipientId || !departmentIds.includes(request.recipientId)) return [];
    } else if (request.recipientType === "committee") {
      if (!request.recipientId || !committeeIds.includes(request.recipientId)) return [];
    } else {
      return [];
    }
  }

  if (request.recipientType === "individual" && request.recipientId) {
    const member = await prisma.member.findUnique({ where: { id: request.recipientId } });
    return member ? [member] : [];
  }
  if (request.recipientType === "selected" && request.recipientIds?.length) {
    const members = await prisma.member.findMany({ where: { id: { in: request.recipientIds } } });
    return dedupe(members);
  }
  if (request.recipientType === "department" && request.recipientId) {
    const department = await prisma.department.findUnique({ where: { id: request.recipientId } });
    const assignments = await prisma.departmentMember.findMany({ where: { departmentId: request.recipientId } });
    const memberIds = assignments.map((a) => a.memberId);
    const [assignedMembers, deptMembers] = await Promise.all([
      memberIds.length ? prisma.member.findMany({ where: { id: { in: memberIds } } }) : Promise.resolve([]),
      department?.name
        ? prisma.member.findMany({ where: { department: { equals: department.name, mode: "insensitive" } } })
        : Promise.resolve([]),
    ]);
    return dedupe([...assignedMembers, ...deptMembers]);
  }
  if (request.recipientType === "committee" && request.recipientId) {
    const assignments = await prisma.committeeMember.findMany({ where: { committeeId: request.recipientId } });
    const memberIds = assignments.map((a) => a.memberId);
    if (!memberIds.length) return [];
    const members = await prisma.member.findMany({ where: { id: { in: memberIds } } });
    return dedupe(members);
  }
  if (request.recipientType === "category" && request.recipientCategory) {
    const segs = await segments();
    const match = segs.find((s) => s.key === request.recipientCategory);
    if (!match?.memberIds?.length) return [];
    const members = await prisma.member.findMany({ where: { id: { in: match.memberIds } } });
    return dedupe(members);
  }
  if (request.recipientType === "pastors") {
    if (request.recipientIds?.length) {
      const members = await prisma.member.findMany({ where: { id: { in: request.recipientIds } } });
      return dedupe(members);
    }
    const roles = env.pastorRoles;
    const members = await prisma.member.findMany({ where: { role: { in: roles } } });
    return dedupe(members);
  }
  if (request.recipientType === "all") {
    const members = await prisma.member.findMany({ where: { status: "Active" } });
    return dedupe(members);
  }
  return [];
};

const personalizeMessage = (base: string, name?: string | null, personalize?: boolean, greeting?: string | null) => {
  if (!personalize || !name) return base;
  const firstName = name.split(" ")[0] || name;
  const prefix = (greeting || "").trim();
  if (prefix) {
    if (prefix.includes("{name}")) return `${prefix.replaceAll("{name}", firstName)}!\n${base}`.trim();
    return `${prefix} ${firstName}.\n${base}`.trim();
  }
  if (base.includes("{name}")) return base.replaceAll("{name}", firstName);
  return `Hi ${firstName}, ${base}`;
};

const buildPayloads = (request: SmsSendRequest, recipients: Recipient[]) => {
  const payloads: SmsPayload[] = [];
  if (request.recipientType === "custom" && request.customNumber) {
    const numbers = request.customNumber.split(/[\s,]+/).map((n) => n.trim()).filter(Boolean);
    const seen = new Set<string>();
    numbers.forEach((n) => {
      const normalized = normalizePhone(n);
      if (!normalized) return;
      if (seen.has(normalized)) return;
      seen.add(normalized);
      payloads.push({ mobile: normalized, message: request.message });
    });
    return payloads;
  }
  const seen = new Set<string>();
    recipients.forEach((member) => {
      const phone = normalizePhone(member.phone);
      if (!phone) return;
      if (seen.has(phone)) return;
      seen.add(phone);
      payloads.push({
        mobile: phone,
        message: personalizeMessage(request.message, member.name, request.personalize, request.greeting),
      });
    });
  return payloads;
};

const postJson = async (url: string, body: any) => {
  const payload = JSON.stringify(body);
  return new Promise<any>((resolve) => {
    try {
      const target = new URL(url);
      const req = https.request(
        {
          protocol: target.protocol,
          hostname: target.hostname,
          port: target.port || 443,
          path: `${target.pathname}${target.search}`,
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(payload),
          },
          agent: new https.Agent({ rejectUnauthorized: false }),
        },
        (res) => {
          let data = "";
          res.on("data", (chunk) => {
            data += chunk;
          });
          res.on("end", () => {
            try {
              resolve(JSON.parse(data));
            } catch {
              resolve({ raw: data });
            }
          });
        }
      );
      req.on("error", (err) => resolve({ error: err instanceof Error ? err.message : "Fetch failed" }));
      req.write(payload);
      req.end();
    } catch (err) {
      resolve({ error: err instanceof Error ? err.message : "Fetch failed" });
    }
  });
};

const parseCelcomResponse = (response: any): CelcomResult => {
  const rawResponse = JSON.stringify(response);
  if (response?.responses && Array.isArray(response.responses) && response.responses.length) {
    return parseCelcomResponse(response.responses[0]);
  }
  const code = response?.["response-code"] ?? response?.responseCode ?? response?.["respose-code"];
  const message = response?.["response-description"] ?? response?.responseDescription ?? response?.["respose-description"];
  const success = code === 200 || code === "200" || message === "OK";
  return { success, code: code?.toString(), message: message?.toString(), rawResponse };
};

const MAX_BULK_RECIPIENTS = 100;

const combineCelcomResults = (results: CelcomResult[]): CelcomResult => {
  const failed = results.find((r) => !r.success);
  return {
    success: !failed,
    code: failed?.code ?? "200",
    message: failed?.message ?? "OK",
    rawResponse: JSON.stringify(
      results.map((r) => ({
        success: r.success,
        code: r.code,
        message: r.message,
        rawResponse: r.rawResponse,
      }))
    ),
  };
};

const sendToCelcom = async (payloads: SmsPayload[], mode: string, timeToSend?: string): Promise<CelcomResult> => {
  if (!payloads.length) return { success: false, code: "NO_RECIPIENTS", message: "No recipients" };

  const resolvedMode = mode === "auto" ? (payloads.length > 1 ? "bulk" : "single") : mode;

  if (resolvedMode === "scheduled") {
    const results: CelcomResult[] = [];
    for (const payload of payloads) {
      const body = {
        apikey: env.celcom.apiKey,
        partnerID: env.celcom.partnerId,
        mobile: payload.mobile,
        message: payload.message,
        shortcode: env.celcom.shortcode,
        pass_type: env.celcom.passType,
        timeToSend,
      };
      const resp = await postJson(`${env.celcom.baseUrl}/sendsms/`, body);
      results.push(parseCelcomResponse(resp));
    }
    return results.find((r) => !r.success) || results[0];
  }

  if (resolvedMode === "bulk" && payloads.length > MAX_BULK_RECIPIENTS) {
    const batches: SmsPayload[][] = [];
    for (let i = 0; i < payloads.length; i += MAX_BULK_RECIPIENTS) {
      batches.push(payloads.slice(i, i + MAX_BULK_RECIPIENTS));
    }
    const results: CelcomResult[] = [];
    for (const batch of batches) {
      results.push(await sendToCelcom(batch, "bulk", timeToSend));
    }
    return combineCelcomResults(results);
  }

  if (resolvedMode === "single" || payloads.length === 1) {
    const payload = payloads[0];
    const body = {
      apikey: env.celcom.apiKey,
      partnerID: env.celcom.partnerId,
      mobile: payload.mobile,
      message: payload.message,
      shortcode: env.celcom.shortcode,
      pass_type: env.celcom.passType,
    };
    const resp = await postJson(`${env.celcom.baseUrl}/sendsms/`, body);
    return parseCelcomResponse(resp);
  }

  if (resolvedMode === "bulk") {
    const smslist = payloads.map((p, idx) => ({
      partnerID: env.celcom.partnerId,
      apikey: env.celcom.apiKey,
      pass_type: env.celcom.passType,
      clientsmsid: Date.now() + idx,
      mobile: p.mobile,
      message: p.message,
      shortcode: env.celcom.shortcode,
    }));
    const resp = await postJson(`${env.celcom.baseUrl}/sendbulk/`, { count: smslist.length, smslist });
    return parseCelcomResponse(resp);
  }

  const fallback = payloads.map((p) => p.mobile).join(",");
  const body = {
    apikey: env.celcom.apiKey,
    partnerID: env.celcom.partnerId,
    mobile: fallback,
    message: payloads[0].message,
    shortcode: env.celcom.shortcode,
    pass_type: env.celcom.passType,
  };
  const resp = await postJson(`${env.celcom.baseUrl}/sendsms/`, body);
  return parseCelcomResponse(resp);
};

export const sendSms = async (request: SmsSendRequest, senderId: string) => {
  if (!request?.message) throw new Error("Message is required");
  const recipients = await resolveRecipients(request, senderId);
  if (!recipients.length && !request.customNumber) throw new Error("No recipients found");
  const payloads = buildPayloads(request, recipients);
  if (payloads.length > env.sms.maxRecipients) {
    throw new Error(`Too many recipients (max ${env.sms.maxRecipients})`);
  }
  const mode = request.sendMode || (payloads.length > 1 ? "bulk" : "single");
  const now = new Date().toISOString();
  const record = await prisma.smsRecord.create({
    data: {
      message: request.message,
      recipientType: request.recipientType,
      recipients: payloads.map((p) => p.mobile).join(","),
      recipientCount: payloads.length,
      date: now,
      status: "Pending",
      providerStatus: "PENDING",
      providerCode: null,
      providerMessage: null,
      providerResponse: null,
      createdBy: senderId,
      createdAt: now,
      lastEditedBy: senderId,
      lastEditedAt: now,
      sentBy: senderId,
    },
  });
  void sendToCelcom(payloads, mode, request.timeToSend)
    .then((result) =>
      prisma.smsRecord.update({
        where: { id: record.id },
        data: {
          status: result.success ? "Sent" : "Failed",
          providerStatus: result.success ? "SUCCESS" : "FAILED",
          providerCode: result.code,
          providerMessage: result.message,
          providerResponse: result.rawResponse,
          lastEditedBy: senderId,
          lastEditedAt: new Date().toISOString(),
        },
      })
    )
    .catch((err) =>
      prisma.smsRecord.update({
        where: { id: record.id },
        data: {
          status: "Failed",
          providerStatus: "FAILED",
          providerCode: "NETWORK_ERROR",
          providerMessage: err instanceof Error ? err.message : "Celcom request failed",
          lastEditedBy: senderId,
          lastEditedAt: new Date().toISOString(),
        },
      })
    );
  return record;
};

export const getBalance = async () => {
  const body = { partnerID: env.celcom.partnerId, apikey: env.celcom.apiKey };
  return postJson(`${env.celcom.baseUrl}/getbalance/`, body);
};

export const getDeliveryReport = async (messageId: string) => {
  const body = { partnerID: env.celcom.partnerId, apikey: env.celcom.apiKey, messageID: messageId };
  return postJson(`${env.celcom.baseUrl}/getdlr/`, body);
};
