import { env } from "../config/env.js";

type SlowEvent = {
  environment?: string;
  method: string;
  path: string;
  status: number;
  durationMs: number;
  databaseDurationMs?: number;
  databaseQueryCount?: number;
  appDurationMs?: number;
  timestamp: string;
};

const MAX_EVENTS = Math.max(1, Math.floor(env.metrics.slowMaxEvents));
const events: SlowEvent[] = [];
let oldestEventIndex = 0;

export const recordSlow = (event: SlowEvent) => {
  if (events.length < MAX_EVENTS) {
    events.push(event);
    return;
  }
  events[oldestEventIndex] = event;
  oldestEventIndex = (oldestEventIndex + 1) % MAX_EVENTS;
};

export const listSlow = () => events.length < MAX_EVENTS
  ? [...events]
  : [...events.slice(oldestEventIndex), ...events.slice(0, oldestEventIndex)];
