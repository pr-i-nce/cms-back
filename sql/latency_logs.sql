create table if not exists latency_logs (
  id uuid primary key default gen_random_uuid(),
  source text,
  method text,
  path text,
  status int,
  duration_ms int,
  timestamp text
);

create index if not exists idx_latency_logs_source on latency_logs (source);
create index if not exists idx_latency_logs_timestamp on latency_logs (timestamp);
create index if not exists idx_latency_logs_duration on latency_logs (duration_ms);
