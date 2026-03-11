create table if not exists refresh_tokens (
  id text primary key default gen_random_uuid()::text,
  user_id text not null references users(id) on delete cascade,
  token_hash text not null,
  created_at text,
  expires_at text,
  revoked_at text,
  replaced_by text,
  last_used_at text
);

create unique index if not exists idx_refresh_tokens_hash on refresh_tokens (token_hash);
create index if not exists idx_refresh_tokens_user on refresh_tokens (user_id);
