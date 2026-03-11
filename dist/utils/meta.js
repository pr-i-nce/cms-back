import { randomUUID } from "crypto";
export const buildMeta = (durationMs, pagination) => ({
    requestId: randomUUID(),
    timestamp: new Date().toISOString(),
    durationMs,
    pagination: pagination ?? null,
});
