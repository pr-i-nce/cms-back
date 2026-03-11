import { env } from "../config/env.js";

type LatencyEvent = {
  method: string;
  path: string;
  status: number;
  durationMs: number;
  timestamp: string;
};

const MAX_EVENTS = env.metrics.latencyMaxEvents;
const events: LatencyEvent[] = [];

export const recordLatency = (event: LatencyEvent) => {
  events.push(event);
  if (events.length > MAX_EVENTS) {
    events.shift();
  }
};

const percentile = (values: number[], p: number) => {
  if (!values.length) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const idx = Math.min(sorted.length - 1, Math.floor((p / 100) * sorted.length));
  return sorted[idx];
};

export const getLatencyStats = () => {
  const durations = events.map((e) => e.durationMs);
  const count = durations.length;
  const sum = durations.reduce((acc, v) => acc + v, 0);
  const avg = count ? Math.round(sum / count) : 0;
  const p50 = percentile(durations, 50);
  const p95 = percentile(durations, 95);
  const p99 = percentile(durations, 99);
  const max = count ? Math.max(...durations) : 0;
  return {
    count,
    avg,
    p50,
    p95,
    p99,
    max,
  };
};

export const listLatency = () => [...events];
