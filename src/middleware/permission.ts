import { Response, NextFunction } from "express";
import { AuthedRequest } from "./auth.js";
import { fail } from "../utils/response.js";
import { resolvePermissions } from "../services/permissions.js";
import { prisma } from "../db/client.js";

const logPermissionEvent = async (payload: { userId?: string; permission: string; action: string; req: any }) => {
  try {
    const now = new Date().toISOString();
    const ip = payload.req.headers["x-forwarded-for"] || payload.req.ip || "unknown";
    const ua = payload.req.headers["user-agent"] || "unknown";
    await prisma.activity.create({
      data: {
        action: payload.action,
        details: `permission=${payload.permission} user=${payload.userId || "unknown"} path=${payload.req.originalUrl} ip=${ip} ua=${ua}`,
        time: now,
        type: "security",
      },
    });
  } catch {
    // ignore audit failures
  }
};

export const requirePermission = (permission: string) => {
  return async (req: AuthedRequest, res: Response, next: NextFunction) => {
    if (!req.userId) {
      res.status(401).json(fail("SESSION_EXPIRED", "401", "Missing user"));
      return;
    }
    try {
      const permissions = await resolvePermissions(req.userId);
      if (!permissions.includes(permission)) {
        void logPermissionEvent({ userId: req.userId, permission, action: "PERMISSION_DENIED", req });
        res.status(403).json(fail("FORBIDDEN", "403", "Permission denied"));
        return;
      }
      next();
    } catch (err) {
      void logPermissionEvent({ userId: req.userId, permission, action: "PERMISSION_CHECK_FAILED", req });
      res.status(500).json(fail("Server error", "INTERNAL_ERROR", "Permission check failed"));
    }
  };
};

export const requireAnyPermission = (permissions: string[]) => {
  return async (req: AuthedRequest, res: Response, next: NextFunction) => {
    if (!req.userId) {
      res.status(401).json(fail("SESSION_EXPIRED", "401", "Missing user"));
      return;
    }
    try {
      const userPermissions = await resolvePermissions(req.userId);
      const allowed = permissions.some((permission) => userPermissions.includes(permission));
      if (!allowed) {
        void logPermissionEvent({ userId: req.userId, permission: permissions.join("|"), action: "PERMISSION_DENIED", req });
        res.status(403).json(fail("FORBIDDEN", "403", "Permission denied"));
        return;
      }
      next();
    } catch {
      void logPermissionEvent({ userId: req.userId, permission: permissions.join("|"), action: "PERMISSION_CHECK_FAILED", req });
      res.status(500).json(fail("Server error", "INTERNAL_ERROR", "Permission check failed"));
    }
  };
};
