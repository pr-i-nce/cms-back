create table if not exists branches (
  id text primary key default gen_random_uuid()::text,
  name text,
  location text,
  address text,
  phone text,
  email text,
  status text,
  created_by text,
  created_at text,
  last_edited_by text,
  last_edited_at text,
  sent_by text
);

create table if not exists branch_pastors (
  id text primary key default gen_random_uuid()::text,
  branch_id text not null references branches(id) on delete cascade,
  member_id text not null references members(id) on delete cascade,
  role text
);

create unique index if not exists idx_branch_pastors_unique on branch_pastors (branch_id, member_id);
create index if not exists idx_branches_status on branches (status);
create index if not exists idx_branch_pastors_branch_id on branch_pastors (branch_id);
create index if not exists idx_branch_pastors_member_id on branch_pastors (member_id);
