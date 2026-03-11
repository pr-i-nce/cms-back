import { fail } from "../utils/response.js";
import { verifyAccessToken } from "../utils/jwt.js";
import { prisma } from "../db/client.js";
import { env } from "../config/env.js";
const statusCache = new Map();
const getStatus = async (userId) => {
    const cached = statusCache.get(userId);
    if (cached && cached.expiresAt > Date.now())
        return cached.status;
    const user = await prisma.systemUser.findUnique({ where: { id: userId } });
    const status = user?.status || null;
    statusCache.set(userId, { status, expiresAt: Date.now() + env.auth.statusCacheMs });
    return status;
};
export const requireAuth = (req, res, next) => {
    const header = req.headers.authorization || "";
    const bearer = header.startsWith("Bearer ") ? header.slice(7) : "";
    const cookieToken = req.cookies?.access_token || "";
    const token = bearer || cookieToken;
    if (!token) {
        res.status(401).json(fail("SESSION_EXPIRED", "401", "Missing token"));
        return;
    }
    try {
        const payload = verifyAccessToken(token);
        req.userId = payload.sub;
        if (!["GET", "HEAD", "OPTIONS"].includes(req.method)) {
            const csrfHeader = String(req.headers["x-csrf-token"] || "");
            const csrfCookie = req.cookies?.csrf_token || "";
            if (!csrfHeader || csrfHeader !== payload.csrf) {
                res.status(403).json(fail("CSRF validation failed", "403", "Invalid CSRF token"));
                return;
            }
            if (csrfCookie && csrfCookie !== csrfHeader) {
                res.status(403).json(fail("CSRF validation failed", "403", "CSRF cookie mismatch"));
                return;
            }
        }
        getStatus(payload.sub)
            .then((status) => {
            if (status && status !== "Active") {
                res.status(403).json(fail("Account inactive", "403", "User account is inactive"));
                return;
            }
            next();
        })
            .catch(() => {
            res.status(401).json(fail("SESSION_EXPIRED", "401", "Invalid token"));
        });
    }
    catch {
        res.status(401).json(fail("SESSION_EXPIRED", "401", "Invalid token"));
    }
};
