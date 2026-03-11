import { Router } from "express";
import bcrypt from "bcryptjs";
import { prisma } from "../db/client.js";
import { ok, fail } from "../utils/response.js";
import { buildMeta } from "../utils/meta.js";
import { signAccessToken, signRefreshToken, verifyRefreshToken } from "../utils/jwt.js";
import { resolvePermissions } from "../services/permissions.js";
import { requireAuth } from "../middleware/auth.js";
import rateLimit from "express-rate-limit";
import { randomUUID, createHash } from "crypto";
import { z } from "zod";
import { env } from "../config/env.js";
export const authRouter = Router();
const authLimiter = rateLimit({
    windowMs: env.authRateLimit.windowMs,
    max: env.authRateLimit.max,
    standardHeaders: true,
    legacyHeaders: false,
});
authRouter.use(["/login", "/refresh"], authLimiter);
authRouter.use((_req, res, next) => {
    res.setHeader("Cache-Control", "no-store");
    res.setHeader("Pragma", "no-cache");
    next();
});
const accessCookieOptions = {
    httpOnly: true,
    secure: env.cookies.secure,
    sameSite: env.cookies.sameSite,
    maxAge: 2 * 60 * 60 * 1000,
    path: "/",
};
const refreshCookieOptions = {
    httpOnly: true,
    secure: env.cookies.secure,
    sameSite: env.cookies.sameSite,
    maxAge: 7 * 24 * 60 * 60 * 1000,
    path: "/api/auth/refresh",
};
const csrfCookieOptions = {
    httpOnly: false,
    secure: env.cookies.secure,
    sameSite: env.cookies.sameSite,
    maxAge: 2 * 60 * 60 * 1000,
    path: "/",
};
const sanitizeUser = (user) => {
    if (!user)
        return user;
    const { passwordHash, ...rest } = user;
    return rest;
};
const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(8),
});
const refreshSchema = z.object({
    refreshToken: z.string().min(10).optional(),
});
const loginAttempts = new Map();
const MAX_LOGIN_ATTEMPTS = 8;
const LOCK_WINDOW_MS = 15 * 60 * 1000;
const getLoginKey = (email, req) => {
    const ip = req.headers["x-forwarded-for"] || req.ip || "unknown";
    return `${String(email).toLowerCase()}|${ip}`;
};
const recordLoginFailure = (key) => {
    const entry = loginAttempts.get(key) || { count: 0, lockedUntil: 0 };
    const nextCount = entry.count + 1;
    const lockedUntil = nextCount >= MAX_LOGIN_ATTEMPTS ? Date.now() + LOCK_WINDOW_MS : entry.lockedUntil;
    loginAttempts.set(key, { count: nextCount, lockedUntil });
    return { count: nextCount, lockedUntil };
};
const clearLoginFailures = (key) => {
    loginAttempts.delete(key);
};
const logAuthEvent = async (payload) => {
    try {
        const now = new Date().toISOString();
        const ip = payload.req.headers["x-forwarded-for"] || payload.req.ip || "unknown";
        const ua = payload.req.headers["user-agent"] || "unknown";
        await prisma.activity.create({
            data: {
                action: payload.action,
                details: `${payload.success ? "SUCCESS" : "FAIL"}${payload.email ? ` email=${payload.email}` : ""}${payload.reason ? ` reason=${payload.reason}` : ""} ip=${ip} ua=${ua}`,
                time: now,
                type: "auth",
            },
        });
    }
    catch {
        // ignore audit logging failures
    }
};
const hashToken = (token) => createHash("sha256").update(token).digest("hex");
const refreshTtlMs = 7 * 24 * 60 * 60 * 1000;
authRouter.post("/login", async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        await logAuthEvent({ action: "LOGIN", success: false, reason: "INVALID_PAYLOAD", req });
        res.status(400).json(fail("Invalid request", "400", "Invalid login payload", buildMeta()));
        return;
    }
    const { email, password } = parsed.data;
    const normalizedEmail = email.trim();
    const attemptKey = getLoginKey(normalizedEmail, req);
    const attempt = loginAttempts.get(attemptKey);
    if (attempt && attempt.lockedUntil > Date.now()) {
        await logAuthEvent({ action: "LOGIN", success: false, reason: "LOCKED_OUT", email: normalizedEmail, req });
        res.status(429).json(fail("Too many attempts", "429", "Account temporarily locked. Try again later.", buildMeta()));
        return;
    }
    const user = await prisma.systemUser.findFirst({
        where: {
            email: {
                equals: normalizedEmail,
                mode: "insensitive",
            },
        },
    });
    if (!user || !user.passwordHash) {
        recordLoginFailure(attemptKey);
        await logAuthEvent({ action: "LOGIN", success: false, reason: "INVALID_CREDENTIALS", email, req });
        res.status(401).json(fail("Invalid credentials", "401", "Email or password incorrect", buildMeta()));
        return;
    }
    if (user.status && user.status !== "Active") {
        recordLoginFailure(attemptKey);
        await logAuthEvent({ action: "LOGIN", success: false, reason: "INACTIVE", email, req });
        res.status(403).json(fail("Account inactive", "403", "User account is inactive", buildMeta()));
        return;
    }
    const matches = await bcrypt.compare(password, user.passwordHash);
    if (!matches) {
        recordLoginFailure(attemptKey);
        await logAuthEvent({ action: "LOGIN", success: false, reason: "INVALID_CREDENTIALS", email, req });
        res.status(401).json(fail("Invalid credentials", "401", "Email or password incorrect", buildMeta()));
        return;
    }
    clearLoginFailures(attemptKey);
    const groups = await prisma.userGroup.findMany({ where: { userId: user.id } });
    if (!groups.length) {
        await logAuthEvent({ action: "LOGIN", success: false, reason: "NO_GROUP", email, req });
        res.status(403).json(fail("Forbidden", "403", "User has no group assigned", buildMeta()));
        return;
    }
    const csrfToken = randomUUID();
    const accessToken = signAccessToken(user.id, csrfToken);
    const refreshToken = signRefreshToken(user.id);
    const permissions = await resolvePermissions(user.id);
    const now = new Date().toISOString();
    const refreshHash = hashToken(refreshToken);
    await prisma.$executeRaw `
    insert into refresh_tokens (user_id, token_hash, created_at, expires_at)
    values (${user.id}, ${refreshHash}, ${now}, ${new Date(Date.now() + refreshTtlMs).toISOString()})
  `;
    res.cookie("access_token", accessToken, accessCookieOptions);
    res.cookie("refresh_token", refreshToken, refreshCookieOptions);
    res.cookie("csrf_token", csrfToken, csrfCookieOptions);
    res.json(ok({
        user: sanitizeUser(user),
        csrfToken,
        expiresIn: 7200,
        expiresAt: new Date(Date.now() + 7200 * 1000).toISOString(),
        permissions,
    }, "OK", buildMeta()));
    await logAuthEvent({ action: "LOGIN", success: true, email, req });
});
authRouter.post("/refresh", async (req, res) => {
    const parsed = refreshSchema.safeParse(req.body);
    if (!parsed.success) {
        await logAuthEvent({ action: "REFRESH", success: false, reason: "INVALID_PAYLOAD", req });
        res.status(400).json(fail("Invalid request", "400", "Refresh token required", buildMeta()));
        return;
    }
    const refreshToken = parsed.data.refreshToken || req.cookies?.refresh_token || "";
    if (!refreshToken) {
        await logAuthEvent({ action: "REFRESH", success: false, reason: "MISSING_TOKEN", req });
        res.status(400).json(fail("Invalid request", "400", "Refresh token required", buildMeta()));
        return;
    }
    try {
        const payload = verifyRefreshToken(refreshToken);
        const tokenHash = hashToken(refreshToken);
        const rows = await prisma.$queryRaw `
      select user_id, expires_at, revoked_at
      from refresh_tokens
      where token_hash = ${tokenHash}
      limit 1
    `;
        const row = rows[0];
        if (!row) {
            await logAuthEvent({ action: "REFRESH", success: false, reason: "TOKEN_NOT_FOUND", req });
            res.status(401).json(fail("Invalid token", "401", "Refresh token invalid", buildMeta()));
            return;
        }
        if (row.revoked_at) {
            const now = new Date().toISOString();
            await prisma.$executeRaw `
        update refresh_tokens set revoked_at = ${now}, last_used_at = ${now}
        where user_id = ${row.user_id}
      `;
            await logAuthEvent({ action: "REFRESH", success: false, reason: "TOKEN_REUSE_DETECTED", req });
            res.status(401).json(fail("Invalid token", "401", "Refresh token invalid", buildMeta()));
            return;
        }
        if (new Date(row.expires_at).getTime() <= Date.now()) {
            await logAuthEvent({ action: "REFRESH", success: false, reason: "TOKEN_EXPIRED", req });
            res.status(401).json(fail("Invalid token", "401", "Refresh token invalid", buildMeta()));
            return;
        }
        const csrfToken = randomUUID();
        const accessToken = signAccessToken(payload.sub, csrfToken);
        const newRefresh = signRefreshToken(payload.sub);
        const now = new Date().toISOString();
        const newHash = hashToken(newRefresh);
        await prisma.$transaction(async (tx) => {
            await tx.$executeRaw `
        update refresh_tokens
        set revoked_at = ${now}, replaced_by = ${newHash}, last_used_at = ${now}
        where token_hash = ${tokenHash}
      `;
            await tx.$executeRaw `
        insert into refresh_tokens (user_id, token_hash, created_at, expires_at)
        values (${payload.sub}, ${newHash}, ${now}, ${new Date(Date.now() + refreshTtlMs).toISOString()})
      `;
        });
        res.cookie("access_token", accessToken, accessCookieOptions);
        res.cookie("refresh_token", newRefresh, refreshCookieOptions);
        res.cookie("csrf_token", csrfToken, csrfCookieOptions);
        res.json(ok({
            csrfToken,
            expiresIn: 7200,
            expiresAt: new Date(Date.now() + 7200 * 1000).toISOString(),
        }, "OK", buildMeta()));
        await logAuthEvent({ action: "REFRESH", success: true, req });
    }
    catch {
        await logAuthEvent({ action: "REFRESH", success: false, reason: "INVALID_TOKEN", req });
        res.status(401).json(fail("Invalid token", "401", "Refresh token invalid", buildMeta()));
    }
});
authRouter.post("/logout", async (req, res) => {
    const refreshToken = req.cookies?.refresh_token;
    if (refreshToken) {
        const tokenHash = hashToken(refreshToken);
        const now = new Date().toISOString();
        await prisma.$executeRaw `
      update refresh_tokens set revoked_at = ${now}, last_used_at = ${now}
      where token_hash = ${tokenHash}
    `.catch(() => { });
    }
    res.clearCookie("access_token", { path: "/" });
    res.clearCookie("refresh_token", { path: "/api/auth/refresh" });
    res.clearCookie("csrf_token", { path: "/" });
    res.json(ok({ ok: true }, "OK", buildMeta()));
});
authRouter.get("/me", requireAuth, async (req, res) => {
    const userId = req.userId;
    const user = await prisma.systemUser.findUnique({ where: { id: userId } });
    if (!user) {
        res.status(404).json(fail("Not found", "404", "User not found", buildMeta()));
        return;
    }
    const permissions = await resolvePermissions(userId);
    const groups = await prisma.userGroup.findMany({ where: { userId } });
    res.json(ok({ user: sanitizeUser(user), permissions, groups }, "OK", buildMeta()));
});
