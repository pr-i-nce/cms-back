import { env } from "../config/env.js";
const MAX_EVENTS = env.metrics.slowMaxEvents;
const events = [];
export const recordSlow = (event) => {
    events.push(event);
    if (events.length > MAX_EVENTS) {
        events.shift();
    }
};
export const listSlow = () => [...events];
