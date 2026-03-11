type CacheEntry<T> = { expiresAt: number; value: T };

const cache = new Map<string, CacheEntry<unknown>>();

export const getCached = <T>(key: string): T | null => {
  const entry = cache.get(key);
  if (!entry) return null;
  if (entry.expiresAt <= Date.now()) {
    cache.delete(key);
    return null;
  }
  return entry.value as T;
};

export const setCached = <T>(key: string, value: T, ttlMs: number) => {
  cache.set(key, { value, expiresAt: Date.now() + ttlMs });
};

export const cached = async <T>(key: string, ttlMs: number, loader: () => Promise<T>): Promise<T> => {
  const existing = getCached<T>(key);
  if (existing) return existing;
  const value = await loader();
  setCached(key, value, ttlMs);
  return value;
};

export const invalidateCache = (keyPrefix?: string) => {
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
