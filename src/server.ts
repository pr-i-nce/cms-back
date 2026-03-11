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
import { Prisma } from "@prisma/client";
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
    path: z.string().min(1),
    durationMs: z.number().int().min(0),
    timestamp: z.string().min(1),
  })).min(1),
});

app.use((req, res, next) => {
  const start = process.hrtime.bigint();
  res.on("finish", () => {
    const durationMs = Number(process.hrtime.bigint() - start) / 1_000_000;
    const event = {
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      durationMs: Math.round(durationMs),
      timestamp: new Date().toISOString(),
    };
    recordLatency(event);
    if (durationMs >= env.metrics.slowThresholdMs) {
      recordSlow(event);
    }
    if (req.originalUrl.startsWith("/api/metrics") || req.originalUrl.startsWith("/health") || req.originalUrl.startsWith("/api/health")) {
      return;
    }
    void prisma.$executeRaw`
      insert into latency_logs (source, method, path, status, duration_ms, timestamp)
      values ('backend', ${event.method}, ${event.path}, ${event.status}, ${event.durationMs}, ${event.timestamp})
    `.catch(() => {});
  });
  next();
});

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
      select source, method, path, status, duration_ms as "durationMs", timestamp
      from latency_logs
      where source = 'backend'
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
  } catch {
    res.json(ok({ thresholdMs: env.metrics.slowThresholdMs, items: listLatency() }));
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
    select source, method, path, status, duration_ms as "durationMs", timestamp
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

app.post("/api/metrics/ui-latency", requireAuth, async (req, res) => {
  const parsed = uiLatencySchema.safeParse(req.body || {});
  if (!parsed.success) {
    res.status(400).json(fail("Invalid request", "400", "Invalid UI latency payload"));
    return;
  }
  const values = parsed.data.items.map((item) =>
    Prisma.sql`('ui', 'NAV', ${item.path}, 200, ${item.durationMs}, ${item.timestamp})`
  );
  if (!values.length) {
    res.json(ok({ stored: 0 }));
    return;
  }
  await prisma.$executeRaw(
    Prisma.sql`insert into latency_logs (source, method, path, status, duration_ms, timestamp) values ${Prisma.join(values)}`
  );
  res.json(ok({ stored: values.length }));
});

app.use((_req, res) => {
  res.status(404).json(fail("Not found", "404", "Route not found"));
});

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const message = err?.message || "Server error";
  res.status(500).json(fail("Server error", "INTERNAL_ERROR", message));
});

app.listen(env.port, "0.0.0.0", () => {
  console.log(`Node backend listening on ${env.port}`);
});
