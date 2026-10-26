export type LatencyIssueSample = {
  source: "backend" | "ui";
  environment: string;
  method: string;
  path: string;
  status: number;
  durationMs: number;
  databaseDurationMs: number;
  databaseQueryCount: number;
  appDurationMs: number;
  timestamp: string;
};

export type LatencyIssueBucket = {
  key: string;
  source: LatencyIssueSample["source"];
  environment: string;
  method: string;
  path: string;
  status: number;
  sampleCount: number;
  durationTotalMs: number;
  databaseDurationTotalMs: number;
  databaseQueryTotal: number;
  appDurationTotalMs: number;
  maxDurationMs: number;
  timestamp: string;
};

const MAX_BUCKETS = 500;
const WINDOW_MS = 60_000;
const buckets = new Map<string, LatencyIssueBucket>();

const makeKey = (sample: LatencyIssueSample, timestamp: Date) => [
  Math.floor(timestamp.getTime() / WINDOW_MS), sample.source, sample.environment,
  sample.method, sample.path, sample.status,
].join(":");

const merge = (target: LatencyIssueBucket, incoming: LatencyIssueBucket) => {
  const previousCount = target.sampleCount;
  const nextCount = previousCount + incoming.sampleCount;
  target.durationTotalMs += incoming.durationTotalMs;
  target.databaseDurationTotalMs += incoming.databaseDurationTotalMs;
  target.databaseQueryTotal += incoming.databaseQueryTotal;
  target.appDurationTotalMs += incoming.appDurationTotalMs;
  target.maxDurationMs = Math.max(target.maxDurationMs, incoming.maxDurationMs);
  target.sampleCount = nextCount;
  if (incoming.status >= 500) target.status = incoming.status;
};

export const addLatencyIssue = (sample: LatencyIssueSample) => {
  const eventTime = new Date(sample.timestamp);
  if (Number.isNaN(eventTime.getTime())) return;
  const bucketStart = new Date(Math.floor(eventTime.getTime() / WINDOW_MS) * WINDOW_MS);
  const key = makeKey(sample, bucketStart);
  const existing = buckets.get(key);
  if (existing) {
    merge(existing, {
      key, source: sample.source, environment: sample.environment, method: sample.method,
      path: sample.path, status: sample.status, sampleCount: 1,
      durationTotalMs: sample.durationMs, databaseDurationTotalMs: sample.databaseDurationMs,
      databaseQueryTotal: sample.databaseQueryCount, appDurationTotalMs: sample.appDurationMs,
      maxDurationMs: sample.durationMs, timestamp: bucketStart.toISOString(),
    });
    return;
  }
  if (buckets.size >= MAX_BUCKETS) buckets.delete(buckets.keys().next().value as string);
  buckets.set(key, {
    key, source: sample.source, environment: sample.environment, method: sample.method,
    path: sample.path, status: sample.status, sampleCount: 1,
    durationTotalMs: sample.durationMs, databaseDurationTotalMs: sample.databaseDurationMs,
    databaseQueryTotal: sample.databaseQueryCount, appDurationTotalMs: sample.appDurationMs,
    maxDurationMs: sample.durationMs, timestamp: bucketStart.toISOString(),
  });
};

export const drainLatencyIssueBuckets = () => {
  const batch = [...buckets.values()];
  buckets.clear();
  return batch;
};

export const restoreLatencyIssueBuckets = (batch: LatencyIssueBucket[]) => {
  for (const bucket of batch) {
    const existing = buckets.get(bucket.key);
    if (existing) merge(existing, bucket);
    else {
      if (buckets.size >= MAX_BUCKETS) buckets.delete(buckets.keys().next().value as string);
      buckets.set(bucket.key, bucket);
    }
  }
};

export const getLatencyIssueBucketCount = () => buckets.size;
