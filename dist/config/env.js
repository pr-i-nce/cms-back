import "dotenv/config";
const num = (value, fallback) => {
    if (!value)
        return fallback;
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
};
const list = (value, fallback) => {
    if (!value)
        return fallback;
    return value
        .split(",")
        .map((entry) => entry.trim())
        .filter(Boolean);
};
export const env = {
    nodeEnv: process.env.NODE_ENV || "development",
    port: num(process.env.PORT, 8081),
    databaseUrl: process.env.DATABASE_URL || "",
    jwtAccessSecret: process.env.JWT_ACCESS_SECRET || "dev_access",
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || "dev_refresh",
    jwtAccessTtl: process.env.JWT_ACCESS_TTL || "2h",
    jwtRefreshTtl: process.env.JWT_REFRESH_TTL || "7d",
    corsOrigins: list(process.env.CORS_ORIGINS, ["http://localhost:8080", "http://localhost:5173"]),
    corsAllowedHeaders: list(process.env.CORS_ALLOWED_HEADERS, ["Content-Type", "Authorization", "X-CSRF-Token"]),
    corsMethods: list(process.env.CORS_METHODS, ["GET", "POST", "PUT", "DELETE", "OPTIONS"]),
    jsonBodyLimit: process.env.JSON_BODY_LIMIT || "2mb",
    hsts: {
        enabled: process.env.HSTS_ENABLED ? process.env.HSTS_ENABLED === "true" : (process.env.NODE_ENV === "production"),
        maxAge: num(process.env.HSTS_MAX_AGE, 15552000),
        includeSubDomains: process.env.HSTS_INCLUDE_SUBDOMAINS ? process.env.HSTS_INCLUDE_SUBDOMAINS === "true" : true,
        preload: process.env.HSTS_PRELOAD ? process.env.HSTS_PRELOAD === "true" : false,
    },
    security: {
        enableCsp: process.env.CSP_ENABLED ? process.env.CSP_ENABLED === "true" : true,
    },
    cookies: {
        secure: process.env.COOKIE_SECURE ? process.env.COOKIE_SECURE === "true" : (process.env.NODE_ENV === "production"),
        sameSite: (process.env.COOKIE_SAMESITE || "lax"),
    },
    rateLimit: {
        windowMs: num(process.env.RATE_LIMIT_WINDOW_MS, 60_000),
        max: num(process.env.RATE_LIMIT_MAX, 300),
    },
    authRateLimit: {
        windowMs: num(process.env.AUTH_RATE_LIMIT_WINDOW_MS, 60_000),
        max: num(process.env.AUTH_RATE_LIMIT_MAX, 10),
    },
    smsRateLimit: {
        windowMs: num(process.env.SMS_RATE_LIMIT_WINDOW_MS, 60_000),
        max: num(process.env.SMS_RATE_LIMIT_MAX, 30),
    },
    pagination: {
        defaultPageSize: num(process.env.DEFAULT_PAGE_SIZE, 20),
        maxPageSize: num(process.env.MAX_PAGE_SIZE, 500),
    },
    cacheTtl: {
        rolesMs: num(process.env.CACHE_TTL_ROLES_MS, 60_000),
        permissionsMs: num(process.env.CACHE_TTL_PERMISSIONS_MS, 60_000),
        groupsMs: num(process.env.CACHE_TTL_GROUPS_MS, 30_000),
        departmentRolesMs: num(process.env.CACHE_TTL_DEPARTMENT_ROLES_MS, 60_000),
        committeeRolesMs: num(process.env.CACHE_TTL_COMMITTEE_ROLES_MS, 60_000),
        reportsMs: num(process.env.CACHE_TTL_REPORTS_MS, 30_000),
        activitiesMs: num(process.env.CACHE_TTL_ACTIVITIES_MS, 15_000),
        smsTemplatesMs: num(process.env.CACHE_TTL_SMS_TEMPLATES_MS, 300_000),
        smsSegmentsMs: num(process.env.CACHE_TTL_SMS_SEGMENTS_MS, 30_000),
    },
    auth: {
        statusCacheMs: num(process.env.AUTH_STATUS_CACHE_MS, 60_000),
    },
    metrics: {
        slowThresholdMs: num(process.env.SLOW_REQUEST_THRESHOLD_MS, 150),
        slowMaxEvents: num(process.env.SLOW_REQUEST_MAX_EVENTS, 200),
        latencyMaxEvents: num(process.env.LATENCY_MAX_EVENTS, 2000),
    },
    sms: {
        messageMaxLength: num(process.env.SMS_MESSAGE_MAX_LENGTH, 500),
        maxRecipients: num(process.env.SMS_MAX_RECIPIENTS, 200),
    },
    departmentRoles: list(process.env.DEPARTMENT_ROLES, ["Leader", "Assistant Leader", "Member", "Coordinator", "Secretary"]),
    committeeRoles: list(process.env.COMMITTEE_ROLES, ["Chair", "Secretary", "Coordinator", "Member"]),
    departmentHeadRoles: list(process.env.DEPARTMENT_HEAD_ROLES, ["Leader", "Coordinator"]),
    committeeChairRoles: list(process.env.COMMITTEE_CHAIR_ROLES, ["Chair"]),
    pastorRoles: list(process.env.PASTOR_ROLES, ["Senior Pastor", "Associate Pastor", "Youth Pastor", "Pastor"]),
    superAdminRoles: list(process.env.SUPER_ADMIN_ROLES, ["Super Admin"]),
    celcom: {
        baseUrl: process.env.CELCOM_BASE_URL || "",
        partnerId: process.env.CELCOM_PARTNER_ID || "",
        apiKey: process.env.CELCOM_API_KEY || "",
        shortcode: process.env.CELCOM_SHORTCODE || "",
        passType: process.env.CELCOM_PASS_TYPE || "plain",
    },
};
