const cache = new Map();
export const getCached = (key) => {
    const entry = cache.get(key);
    if (!entry)
        return null;
    if (entry.expiresAt <= Date.now()) {
        cache.delete(key);
        return null;
    }
    return entry.value;
};
export const setCached = (key, value, ttlMs) => {
    cache.set(key, { value, expiresAt: Date.now() + ttlMs });
};
export const cached = async (key, ttlMs, loader) => {
    const existing = getCached(key);
    if (existing)
        return existing;
    const value = await loader();
    setCached(key, value, ttlMs);
    return value;
};
export const invalidateCache = (keyPrefix) => {
    if (!keyPrefix) {
        cache.clear();
        return;
    }
    for (const key of cache.keys()) {
        if (key.startsWith(keyPrefix)) {
            cache.delete(key);
        }
    }
};
