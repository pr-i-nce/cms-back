import "express-async-errors";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import morgan from "morgan";
import compression from "compression";
import cookieParser from "cookie-parser";
import { env } from "./config/env.js";
import { ok } from "./utils/response.js";
import { listSlow, recordSlow } from "./metrics/slowStore.js";
import { getLatencyStats, listLatency, recordLatency } from "./metrics/latencyStore.js";
import { prisma } from "./db/client.js";
import { Prisma } from "./generated/prisma/client.js";
import { requireAuth } from "./middleware/auth.js";
import { requirePermission } from "./middleware/permission.js";
import { z } from "zod";
import { authRouter } from "./routes/auth.js";
import { membersRouter } from "./routes/members.js";
import { usersRouter } from "./routes/users.js";
import { groupsRouter } from "./routes/groups.js";
import { rolesRouter } from "./routes/roles.js";
import { permissionsRouter } from "./routes/permissions.js";
import { departmentsRouter } from "./routes/departments.js";
import { committeesRouter } from "./routes/committees.js";
import { activitiesRouter } from "./routes/activities.js";
import { reportsRouter } from "./routes/reports.js";
import { smsRouter } from "./routes/sms.js";
import { branchesRouter } from "./routes/branches.js";
import { fail } from "./utils/response.js";
import { listQuerySchema } from "./utils/query.js";
import { runWithRequestPerformance } from "./metrics/requestContext.js";
import { addLatencyIssue, drainLatencyIssueBuckets, restoreLatencyIssueBuckets } from "./metrics/issueBuffer.js";

const app = express();
const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

app.disable("x-powered-by");
app.set("trust proxy", 1);
app.use(express.json({ limit: env.jsonBodyLimit }));
app.use(cookieParser());
app.use(compression());
app.use(
  cors({
    origin: env.corsOrigins,
    credentials: true,
    methods: env.corsMethods,
    allowedHeaders: env.corsAllowedHeaders,
    maxAge: 600,
  })
);
app.use(
  helmet({
    contentSecurityPolicy: env.security.enableCsp
      ? {
          directives: {
            defaultSrc: ["'none'"],
            baseUri: ["'none'"],
            formAction: ["'none'"],
            frameAncestors: ["'none'"],
            imgSrc: ["'self'", "data:"],
            styleSrc: ["'self'"],
            scriptSrc: ["'self'"],
          },
        }
      : false,
    hsts: env.hsts.enabled
      ? {
          maxAge: env.hsts.maxAge,
          includeSubDomains: env.hsts.includeSubDomains,
          preload: env.hsts.preload,
        }
      : false,
    referrerPolicy: { policy: "strict-origin-when-cross-origin" },
  })
);
app.use(
  rateLimit({
    windowMs: env.rateLimit.windowMs,
    max: env.rateLimit.max,
    standardHeaders: true,
    legacyHeaders: false,
  })
);
app.use(morgan("combined"));

app.use((req, res, next) => {
  res.on("finish", () => {
    if (!["POST", "PUT", "PATCH", "DELETE"].includes(req.method)) return;
    if (!req.originalUrl.startsWith("/api")) return;
    const userId = (req as any).userId;
    if (!userId) return;
    const now = new Date().toISOString();
    const ip = req.headers["x-forwarded-for"] || req.ip || "unknown";
    const ua = req.headers["user-agent"] || "unknown";
    void prisma.activity.create({
      data: {
        action: `${req.method} ${req.originalUrl}`,
        details: `status=${res.statusCode} ip=${ip} ua=${ua}`,
        time: now,
        type: "audit",
      },
    }).catch(() => {});
  });
  next();
});

const validateUuidParam = (paramName: string) => (value: string, res: express.Response, next: express.NextFunction) => {
  if (!uuidRegex.test(String(value))) {
    res.status(400).json(fail("Invalid request", "400", `Invalid ${paramName} format`));
    return;
  }
  next();
};

app.param("id", (req, res, next, value) => validateUuidParam("id")(value, res, next));
app.param("memberId", (req, res, next, value) => validateUuidParam("memberId")(value, res, next));

const uiLatencySchema = z.object({
  items: z.array(z.object({
    path: z.string().min(1).max(300).startsWith("/"),
    durationMs: z.number().int().min(0).max(60_000),
    timestamp: z.string().min(1).max(40),
  })).min(1).max(50),
});

app.use((req, res, next) => {
  const performance = { databaseDurationMs: 0, databaseQueryCount: 0 };
  const start = process.hrtime.bigint();
  runWithRequestPerformance(performance, () => {
    res.on("finish", () => {
      const durationMs = Math.round(Number(process.hrtime.bigint() - start) / 1_000_000);
      const databaseDurationMs = Math.round(performance.databaseDurationMs);
      // Prisma query durations are cumulative. Concurrent queries may make this sum
      // exceed wall time, so app time is a bounded estimate rather than a partition.
      const appDurationMs = Math.max(0, durationMs - Math.min(durationMs, databaseDurationMs));
      const routePath = req.originalUrl.split("?", 1)[0]
        .replace(/[0-9a-f]{8}-[0-9a-f-]{27,}/gi, ":id")
        .slice(0, 300);
      const event = {
        environment: env.nodeEnv,
        method: req.method,
        path: routePath,
        status: res.statusCode,
        durationMs,
        databaseDurationMs,
        databaseQueryCount: performance.databaseQueryCount,
        appDurationMs,
        timestamp: new Date().toISOString(),
      };
      recordLatency(event);
      if (durationMs >= env.metrics.slowThresholdMs) {
        recordSlow(event);
      }
      if (req.path.startsWith("/api/metrics") || req.path === "/health" || req.path === "/api/health") {
        return;
      }
      if (durationMs < env.metrics.latencyPersistThresholdMs && res.statusCode < 500) {
        return;
      }
      addLatencyIssue({ source: "backend", ...event });
    });
    next();
  });
});

let latencyFlushInProgress = false;
const flushLatencyIssueBatch = async () => {
  if (latencyFlushInProgress) return;
  const batch = drainLatencyIssueBuckets();
  if (!batch.length) return;
  latencyFlushInProgress = true;
  try {
    const values = batch.map((item) => Prisma.sql`(
      gen_random_uuid(), ${item.source}, ${item.environment}, ${item.method}, ${item.path}, ${item.status},
      ${Math.round(item.durationTotalMs / item.sampleCount)},
      ${Math.round(item.databaseDurationTotalMs / item.sampleCount)},
      ${Math.round(item.databaseQueryTotal / item.sampleCount)},
      ${Math.round(item.appDurationTotalMs / item.sampleCount)},
      ${item.sampleCount}, ${item.maxDurationMs}, ${item.timestamp}
    )`);
    await prisma.$executeRaw(Prisma.sql`
      insert into latency_logs (
        id, source, environment, method, path, status, duration_ms,
        database_duration_ms, database_query_count, app_duration_ms,
        sample_count, max_duration_ms, timestamp
      ) values ${Prisma.join(values)}
    `);
  } catch {
    // Telemetry is best-effort. Keep the bounded batch for a later retry.
    restoreLatencyIssueBuckets(batch);
  } finally {
    latencyFlushInProgress = false;
  }
};

const latencyFlushTimer = setInterval(() => void flushLatencyIssueBatch(), 60_000);
latencyFlushTimer.unref();

app.get("/health", (_req, res) => {
  res.json(ok({ status: "ok" }));
});
app.get("/api/health", (_req, res) => {
  res.json(ok({ status: "ok" }));
});

app.use("/api/auth", authRouter);
app.use("/api/members", membersRouter);
app.use("/api/users", usersRouter);
app.use("/api/groups", groupsRouter);
app.use("/api/roles", rolesRouter);
app.use("/api/permissions", permissionsRouter);
app.use("/api/departments", departmentsRouter);
app.use("/api/committees", committeesRouter);
app.use("/api/activities", activitiesRouter);
app.use("/api/reports", reportsRouter);
app.use("/api/sms", smsRouter);
app.use("/api/branches", branchesRouter);

app.get("/api/metrics/slow-requests", requireAuth, requirePermission("READ_ALL"), (_req, res) => {
  res.json(ok(listSlow()));
});
app.get("/api/metrics/latency", requireAuth, requirePermission("READ_ALL"), (_req, res) => {
  res.json(ok(getLatencyStats()));
});
app.get("/api/metrics/requests", requireAuth, requirePermission("READ_ALL"), async (_req, res) => {
  const parsed = listQuerySchema.safeParse(_req.query || {});
  if (!parsed.success) {
    res.status(400).json(fail("Invalid request", "400", "Invalid query params"));
    return;
  }
  const { page, pageSize } = parsed.data;
  try {
    const totalResult = await prisma.$queryRaw<{ count: bigint }[]>`
      select count(*)::bigint as count from latency_logs where source = 'backend'
    `;
    const total = Number(totalResult[0]?.count ?? 0);
    const items = await prisma.$queryRaw<any[]>`
      select source, environment, method, path, status,
        duration_ms as "durationMs",
        database_duration_ms as "databaseDurationMs",
        database_query_count as "databaseQueryCount",
        app_duration_ms as "appDurationMs",
        sample_count as "sampleCount",
        max_duration_ms as "maxDurationMs",
        timestamp
      from latency_logs
      where source = 'backend'
      order by timestamp desc
      limit ${pageSize} offset ${(page - 1) * pageSize}
    `;
    res.json(ok({
      thresholdMs: env.metrics.slowThresholdMs,
      persistenceThresholdMs: env.metrics.latencyPersistThresholdMs,
      items,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.max(1, Math.ceil(total / pageSize)),
      },
    }));
  } catch {
    res.json(ok({
      thresholdMs: env.metrics.slowThresholdMs,
      persistenceThresholdMs: env.metrics.latencyPersistThresholdMs,
      items: listLatency(),
    }));
  }
});

app.get("/api/metrics/ui-latency", requireAuth, requirePermission("READ_ALL"), async (req, res) => {
  const parsed = listQuerySchema.safeParse(req.query || {});
  if (!parsed.success) {
    res.status(400).json(fail("Invalid request", "400", "Invalid query params"));
    return;
  }
  const { page, pageSize } = parsed.data;
  const totalResult = await prisma.$queryRaw<{ count: bigint }[]>`
    select count(*)::bigint as count from latency_logs where source = 'ui'
  `;
  const total = Number(totalResult[0]?.count ?? 0);
  const items = await prisma.$queryRaw<any[]>`
    select source, method, path, status, duration_ms as "durationMs",
      sample_count as "sampleCount", max_duration_ms as "maxDurationMs", timestamp
    from latency_logs
    where source = 'ui'
    order by timestamp desc
    limit ${pageSize} offset ${(page - 1) * pageSize}
  `;
  res.json(ok({
    thresholdMs: env.metrics.slowThresholdMs,
    items,
    pagination: {
      page,
      pageSize,
      total,
      totalPages: Math.max(1, Math.ceil(total / pageSize)),
    },
  }));
});

app.post("/api/metrics/ui-latency", requireAuth, rateLimit({
  windowMs: 60_000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
}), async (req, res) => {
  const parsed = uiLatencySchema.safeParse(req.body || {});
  if (!parsed.success) {
    res.status(400).json(fail("Invalid request", "400", "Invalid UI latency payload"));
    return;
  }
  const issueItems = parsed.data.items.filter((item) => item.durationMs >= env.metrics.latencyPersistThresholdMs);
  issueItems.forEach((item) => {
    const path = item.path.split("?", 1)[0].replace(/[0-9a-f]{8}-[0-9a-f-]{27,}/gi, ":id");
    addLatencyIssue({
      source: "ui", environment: env.nodeEnv, method: "NAV", path, status: 200,
      durationMs: item.durationMs, databaseDurationMs: 0, databaseQueryCount: 0,
      appDurationMs: item.durationMs, timestamp: item.timestamp,
    });
  });
  if (!issueItems.length) {
    res.status(202).json(ok({ stored: 0, skipped: parsed.data.items.length }, "No slow UI events to persist"));
    return;
  }
  res.status(202).json(ok({ queued: issueItems.length, stored: 0 }, "Slow UI events queued for batch persistence"));
});

app.use((_req, res) => {
  res.status(404).json(fail("Not found", "404", "Route not found"));
});

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  if (err instanceof Prisma.PrismaClientKnownRequestError && ["P2002", "P2003"].includes(err.code)) {
    res.status(409).json(fail("Conflict", "409", "This record conflicts with an existing relationship or unique value"));
    return;
  }
  console.error("Unhandled request error", err);
  res.status(500).json(fail("Server error", "INTERNAL_ERROR", "An unexpected error occurred"));
});

app.listen(env.port, "127.0.0.1", () => {
  console.log(`Node backend listening on ${env.port}`);
});
