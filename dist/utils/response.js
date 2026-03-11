export const ok = (data, message = "OK", meta = null) => ({
    success: true,
    message,
    data,
    error: null,
    meta,
});
export const fail = (message, code = "ERROR", details = "Unexpected error", meta = null) => ({
    success: false,
    message,
    data: null,
    error: { code, details },
    meta,
});
