insert into permissions (id, name, description, created_by, created_at, last_edited_by, last_edited_at)
select gen_random_uuid(), 'BRANCH_CREATE', 'Create branches', 'system', now()::text, 'system', now()::text
where not exists (select 1 from permissions where name = 'BRANCH_CREATE');

insert into permissions (id, name, description, created_by, created_at, last_edited_by, last_edited_at)
select gen_random_uuid(), 'BRANCH_UPDATE', 'Update branches', 'system', now()::text, 'system', now()::text
where not exists (select 1 from permissions where name = 'BRANCH_UPDATE');

insert into permissions (id, name, description, created_by, created_at, last_edited_by, last_edited_at)
select gen_random_uuid(), 'BRANCH_DEACTIVATE', 'Deactivate branches', 'system', now()::text, 'system', now()::text
where not exists (select 1 from permissions where name = 'BRANCH_DEACTIVATE');

insert into permissions (id, name, description, created_by, created_at, last_edited_by, last_edited_at)
select gen_random_uuid(), 'BRANCH_PASTOR_ADD', 'Assign pastors to branches', 'system', now()::text, 'system', now()::text
where not exists (select 1 from permissions where name = 'BRANCH_PASTOR_ADD');

insert into permissions (id, name, description, created_by, created_at, last_edited_by, last_edited_at)
select gen_random_uuid(), 'BRANCH_PASTOR_REMOVE', 'Remove pastors from branches', 'system', now()::text, 'system', now()::text
where not exists (select 1 from permissions where name = 'BRANCH_PASTOR_REMOVE');
