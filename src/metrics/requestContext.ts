import { AsyncLocalStorage } from "node:async_hooks";

export type RequestPerformance = {
  databaseDurationMs: number;
  databaseQueryCount: number;
};

const requestPerformance = new AsyncLocalStorage<RequestPerformance>();

export const runWithRequestPerformance = <T>(context: RequestPerformance, callback: () => T) =>
  requestPerformance.run(context, callback);

export const recordDatabaseQuery = (durationMs: number) => {
  const context = requestPerformance.getStore();
  if (!context || !Number.isFinite(durationMs) || durationMs < 0) return;
  context.databaseDurationMs += durationMs;
  context.databaseQueryCount += 1;
};
