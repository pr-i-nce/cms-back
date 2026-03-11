import { prisma } from "../db/client.js";
import { env } from "../config/env.js";
export const listSms = async (page, pageSize, q, status) => {
    const where = {};
    if (status)
        where.status = status;
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
    const youthDeptIds = new Set(departments.filter((d) => (d.name || "").toLowerCase().includes("youth")).map((d) => d.id));
    const youthMemberIds = new Set(assignments.filter((a) => youthDeptIds.has(a.departmentId)).map((a) => a.memberId));
    const leaderMemberIds = new Set(assignments.filter((a) => {
        const role = (a.role || "").toLowerCase();
        return role.includes("leader") || role.includes("coordinator") || role.includes("chair");
    }).map((a) => a.memberId));
    let latestJoinMonth = "0000-00";
    members.forEach((m) => {
        if (m.dateJoined && m.dateJoined.length >= 7) {
            const month = m.dateJoined.slice(0, 7);
            if (month > latestJoinMonth)
                latestJoinMonth = month;
        }
    });
    const newMemberIds = new Set(members.filter((m) => m.dateJoined?.startsWith(latestJoinMonth)).map((m) => m.id));
    const allMemberIds = new Set(members.map((m) => m.id));
    const toSegment = (key, label, ids) => ({
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
const normalizePhone = (value) => (value ? value.replace(/\s+/g, "").trim() : null);
const isLeaderUser = async (userId) => {
    const groups = await prisma.userGroup.findMany({ where: { userId } });
    if (!groups.length)
        return false;
    const groupIds = groups.map((g) => g.groupId);
    const groupRows = await prisma.group.findMany({ where: { id: { in: groupIds } } });
    return groupRows.some((g) => (g.name || "").toLowerCase().includes("leader"));
};
const resolveLeaderScopes = async (userId) => {
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
const resolveRecipients = async (request, senderId) => {
    const dedupe = (items) => {
        const seen = new Set();
        return items.filter((item) => {
            if (!item.id)
                return false;
            if (seen.has(item.id))
                return false;
            seen.add(item.id);
            return true;
        });
    };
    if (senderId && (await isLeaderUser(senderId))) {
        const { departmentIds, committeeIds } = await resolveLeaderScopes(senderId);
        if (request.recipientType === "department") {
            if (!request.recipientId || !departmentIds.includes(request.recipientId))
                return [];
        }
        else if (request.recipientType === "committee") {
            if (!request.recipientId || !committeeIds.includes(request.recipientId))
                return [];
        }
        else {
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
        const assignments = await prisma.departmentMember.findMany({ where: { departmentId: request.recipientId } });
        const memberIds = assignments.map((a) => a.memberId);
        if (!memberIds.length)
            return [];
        const members = await prisma.member.findMany({ where: { id: { in: memberIds } } });
        return dedupe(members);
    }
    if (request.recipientType === "committee" && request.recipientId) {
        const assignments = await prisma.committeeMember.findMany({ where: { committeeId: request.recipientId } });
        const memberIds = assignments.map((a) => a.memberId);
        if (!memberIds.length)
            return [];
        const members = await prisma.member.findMany({ where: { id: { in: memberIds } } });
        return dedupe(members);
    }
    if (request.recipientType === "category" && request.recipientCategory) {
        const segs = await segments();
        const match = segs.find((s) => s.key === request.recipientCategory);
        if (!match?.memberIds?.length)
            return [];
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
const personalizeMessage = (base, name, personalize) => {
    if (!personalize || !name)
        return base;
    const firstName = name.split(" ")[0] || name;
    if (base.includes("{name}"))
        return base.replaceAll("{name}", firstName);
    return `Hi ${firstName}, ${base}`;
};
const buildPayloads = (request, recipients) => {
    const payloads = [];
    if (request.recipientType === "custom" && request.customNumber) {
        const numbers = request.customNumber.split(/[\s,]+/).map((n) => n.trim()).filter(Boolean);
        const seen = new Set();
        numbers.forEach((n) => {
            const normalized = normalizePhone(n);
            if (!normalized)
                return;
            if (seen.has(normalized))
                return;
            seen.add(normalized);
            payloads.push({ mobile: normalized, message: request.message });
        });
        return payloads;
    }
    const seen = new Set();
    recipients.forEach((member) => {
        const phone = normalizePhone(member.phone);
        if (!phone)
            return;
        if (seen.has(phone))
            return;
        seen.add(phone);
        payloads.push({
            mobile: phone,
            message: personalizeMessage(request.message, member.name, request.personalize),
        });
    });
    return payloads;
};
const postJson = async (url, body) => {
    try {
        const res = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
        });
        const text = await res.text();
        try {
            return JSON.parse(text);
        }
        catch {
            return { raw: text };
        }
    }
    catch (err) {
        return { error: err instanceof Error ? err.message : "Fetch failed" };
    }
};
const parseCelcomResponse = (response) => {
    const rawResponse = JSON.stringify(response);
    if (response?.responses && Array.isArray(response.responses) && response.responses.length) {
        return parseCelcomResponse(response.responses[0]);
    }
    const code = response?.["response-code"] ?? response?.responseCode;
    const message = response?.["response-description"] ?? response?.responseDescription;
    const success = code === 200 || code === "200" || message === "OK";
    return { success, code: code?.toString(), message: message?.toString(), rawResponse };
};
const sendToCelcom = async (payloads, mode, timeToSend) => {
    if (!payloads.length)
        return { success: false, code: "NO_RECIPIENTS", message: "No recipients" };
    if (mode === "scheduled") {
        const results = [];
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
    if (mode === "single" || payloads.length === 1) {
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
};
export const sendSms = async (request, senderId) => {
    if (!request?.message)
        throw new Error("Message is required");
    const recipients = await resolveRecipients(request, senderId);
    if (!recipients.length && !request.customNumber)
        throw new Error("No recipients found");
    const payloads = buildPayloads(request, recipients);
    if (payloads.length > env.sms.maxRecipients) {
        throw new Error(`Too many recipients (max ${env.sms.maxRecipients})`);
    }
    const mode = request.sendMode || (payloads.length > 1 ? "bulk" : "single");
    let result;
    try {
        result = await sendToCelcom(payloads, mode, request.timeToSend);
    }
    catch (err) {
        result = {
            success: false,
            code: "NETWORK_ERROR",
            message: err instanceof Error ? err.message : "Celcom request failed",
        };
    }
    const now = new Date().toISOString();
    const record = await prisma.smsRecord.create({
        data: {
            message: request.message,
            recipientType: request.recipientType,
            recipients: payloads.map((p) => p.mobile).join(","),
            recipientCount: payloads.length,
            date: now,
            status: result.success ? "Sent" : "Failed",
            providerStatus: result.success ? "SUCCESS" : "FAILED",
            providerCode: result.code,
            providerMessage: result.message,
            providerResponse: result.rawResponse,
            createdBy: senderId,
            createdAt: now,
            lastEditedBy: senderId,
            lastEditedAt: now,
            sentBy: senderId,
        },
    });
    return record;
};
export const getBalance = async () => {
    const body = { partnerID: env.celcom.partnerId, apikey: env.celcom.apiKey };
    return postJson(`${env.celcom.baseUrl}/getbalance/`, body);
};
export const getDeliveryReport = async (messageId) => {
    const body = { partnerID: env.celcom.partnerId, apikey: env.celcom.apiKey, messageID: messageId };
    return postJson(`${env.celcom.baseUrl}/getdlr/`, body);
};
