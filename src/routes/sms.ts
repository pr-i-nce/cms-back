import { Router } from "express";
import { requireAuth, AuthedRequest } from "../middleware/auth.js";
import { requirePermission } from "../middleware/permission.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { getBalance, getDeliveryReport, listSms, segments, sendSms, templates } from "../services/sms.js";
import { cached, invalidateCache } from "../utils/cache.js";
import rateLimit from "express-rate-limit";
import { z } from "zod";
import { env } from "../config/env.js";
import { listQuerySchema } from "../utils/query.js";

export const smsRouter = Router();

const recipientTypeEnum = z.enum([
  "individual",
  "selected",
  "department",
  "committee",
  "category",
  "pastors",
  "all",
  "custom",
]);
const categoryEnum = z.enum(["youth", "leaders", "new", "all"]);

const sendSchema = z.object({
  recipientType: recipientTypeEnum,
  recipientId: z.string().uuid().optional(),
  recipientIds: z.array(z.string().uuid()).optional(),
  recipientCategory: categoryEnum.optional(),
  customNumber: z.string().max(500).optional(),
  greeting: z.string().max(120).optional(),
  message: z.string().min(1).max(env.sms.messageMaxLength),
  personalize: z.boolean().optional(),
  sendMode: z.enum(["auto", "single", "bulk", "scheduled"]).optional(),
  timeToSend: z.string().optional(),
}).superRefine((data, ctx) => {
  const needsId = ["individual", "department", "committee"];
  if (needsId.includes(data.recipientType) && !data.recipientId) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "recipientId is required for this recipientType" });
  }
  
  if (data.recipientType === "selected" && (!data.recipientIds || data.recipientIds.length === 0)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "recipientIds is required for selected recipients" });
  }
  if (data.recipientType === "category" && !data.recipientCategory) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "recipientCategory is required for category recipients" });
  }
  if (data.recipientType === "custom" && !data.customNumber) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "customNumber is required for custom recipients" });
  }
  if (data.sendMode === "scheduled" && !data.timeToSend) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "timeToSend is required for scheduled messages" });
  }
  if (data.customNumber && !/^[0-9+\s,]+$/.test(data.customNumber)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "customNumber has invalid characters" });
  }
  if (data.timeToSend && !/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}/.test(data.timeToSend)) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "timeToSend must be in YYYY-MM-DD HH:MM format" });
  }
});

const dlrSchema = z.object({
  messageId: z.string().min(1),
});

const smsSendLimiter = rateLimit({
  windowMs: env.smsRateLimit.windowMs,
  max: env.smsRateLimit.max,
  standardHeaders: true,
  legacyHeaders: false,
});

smsRouter.use("/send", smsSendLimiter);

const buildPagination = (page: number, pageSize: number, total: number) => ({
  page,
  pageSize,
  total,
  totalPages: Math.max(1, Math.ceil(total / pageSize)),
});

const toSmsDto = (record: any) => ({
  id: record.id,
  message: record.message,
  recipients: record.recipients,
  recipientCount: record.recipientCount || 0,
  date: record.date,
  status: record.status || "Pending",
  recipientType: record.recipientType,
  providerStatus: record.providerStatus,
  providerCode: record.providerCode,
  providerMessage: record.providerMessage,
  providerResponse: record.providerResponse,
  audit: {
    createdBy: record.createdBy,
    createdAt: record.createdAt,
    lastEditedBy: record.lastEditedBy,
    lastEditedAt: record.lastEditedAt,
    sentBy: record.sentBy,
  },
});

smsRouter.get(
  "/",
  requireAuth,
  requirePermission("SMS_VIEW"),
  async (req, res) => {
    const parsed = listQuerySchema.safeParse(req.query || {});
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid query params", buildMeta()));
      return;
    }
    const { page, pageSize, q, status } = parsed.data;
    let normalizedStatus: string | undefined = status || undefined;
    if (normalizedStatus) {
      const allowed = ["Sent", "Failed", "Pending"];
      const match = allowed.find((item) => item.toLowerCase() === normalizedStatus!.toLowerCase());
      if (!match) {
        res.status(400).json(fail("Invalid request", "400", "Invalid status filter", buildMeta()));
        return;
      }
      normalizedStatus = match;
    }

    const result = await listSms(page, pageSize, q || undefined, normalizedStatus);
    const items = result.items.map(toSmsDto);
    res.json(ok(items, "OK", buildMeta(undefined, buildPagination(page, pageSize, result.total))));
  }
);

smsRouter.get(
  "/templates",
  requireAuth,
  requirePermission("SMS_SEND"),
  (_req, res) => {
    const data = cached("sms:templates", env.cacheTtl.smsTemplatesMs, async () => templates());
    Promise.resolve(data).then((result) => res.json(ok(result, "OK", buildMeta())));
  }
);

smsRouter.get(
  "/segments",
  requireAuth,
  requirePermission("SMS_SEND"),
  async (_req, res) => {
    const data = await cached("sms:segments", env.cacheTtl.smsSegmentsMs, () => segments());
    res.json(ok(data, "OK", buildMeta()));
  }
);

smsRouter.post(
  "/send",
  requireAuth,
  requirePermission("SMS_SEND"),
  async (req: AuthedRequest, res) => {
    const parsed = sendSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "Invalid SMS payload", buildMeta()));
      return;
    }
    try {
      const record = await sendSms(parsed.data, req.userId || "system");
      invalidateCache("sms:");
      invalidateCache("reports:");
      res.json(ok(toSmsDto(record), "OK", buildMeta()));
    } catch (err) {
      res.status(400).json(fail("Invalid request", "400", err instanceof Error ? err.message : "Send failed", buildMeta()));
    }
  }
);

smsRouter.post(
  "/balance",
  requireAuth,
  requirePermission("SMS_VIEW"),
  async (_req, res) => {
    const result = await getBalance();
    const credit =
      result?.credit ??
      result?.balance ??
      result?.response?.credit ??
      result?.response?.balance ??
      result?.data?.credit ??
      result?.data?.balance ??
      null;
    res.json(ok({ credit, raw: result }, "OK", buildMeta()));
  }
);

smsRouter.post(
  "/dlr",
  requireAuth,
  requirePermission("SMS_VIEW"),
  async (req, res) => {
    const parsed = dlrSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json(fail("Invalid request", "400", "messageId is required", buildMeta()));
      return;
    }
    const result = await getDeliveryReport(parsed.data.messageId);
    res.json(ok(result, "OK", buildMeta()));
  }
);
