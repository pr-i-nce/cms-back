import { randomUUID } from "crypto";
import type { ApiMeta } from "./response.js";

export const buildMeta = (durationMs?: number, pagination?: unknown): ApiMeta => ({
  requestId: randomUUID(),
  timestamp: new Date().toISOString(),
  durationMs,
  pagination: pagination ?? null,
});
