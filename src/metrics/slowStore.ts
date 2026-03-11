import { env } from "../config/env.js";

type SlowEvent = {
  method: string;
  path: string;
  status: number;
  durationMs: number;
  timestamp: string;
};

const MAX_EVENTS = env.metrics.slowMaxEvents;
const events: SlowEvent[] = [];

export const recordSlow = (event: SlowEvent) => {
  events.push(event);
  if (events.length > MAX_EVENTS) {
    events.shift();
  }
};

export const listSlow = () => [...events];
