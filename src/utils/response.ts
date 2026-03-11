export type ApiError = { code: string; details: string } | null;
export type ApiMeta = { requestId?: string; timestamp?: string; durationMs?: number; pagination?: unknown } | null;

export const ok = <T>(data: T, message = "OK", meta: ApiMeta = null) => ({
  success: true,
  message,
  data,
  error: null,
  meta,
});

export const fail = (message: string, code = "ERROR", details = "Unexpected error", meta: ApiMeta = null) => ({
  success: false,
  message,
  data: null,
  error: { code, details },
  meta,
});
