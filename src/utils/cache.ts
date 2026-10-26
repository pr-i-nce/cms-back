type CacheEntry<T> = { expiresAt: number; value: T };

const cache = new Map<string, CacheEntry<unknown>>();
const inFlight = new Map<string, Promise<unknown>>();
const MAX_CACHE_ENTRIES = 250;
let cacheEpoch = 0;

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
  if (existing !== null) return existing;
  const requestEpoch = cacheEpoch;
  const flightKey = `${requestEpoch}:${key}`;
  const pending = inFlight.get(flightKey);
  if (pending) return pending as Promise<T>;

  const load = Promise.resolve().then(loader).then((value) => {
    if (requestEpoch === cacheEpoch) {
      setCached(key, value, ttlMs);
      while (cache.size > MAX_CACHE_ENTRIES) cache.delete(cache.keys().next().value as string);
    }
    return value;
  }).finally(() => {
    inFlight.delete(flightKey);
  });
  inFlight.set(flightKey, load);
  return load;
};

export const invalidateCache = (keyPrefix?: string) => {
  cacheEpoch += 1;
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
