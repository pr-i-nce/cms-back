-- Core lookup and filter indexes
create index if not exists idx_members_status on members (status);
create index if not exists idx_members_date_joined on members (date_joined);
create index if not exists idx_members_email on members (email);
create index if not exists idx_members_phone on members (phone);

create index if not exists idx_departments_status on departments (status);
create index if not exists idx_committees_status on committees (status);

create index if not exists idx_sms_records_status on sms_records (status);
create index if not exists idx_sms_records_date on sms_records (date);
create index if not exists idx_sms_records_recipient_type on sms_records (recipient_type);

create index if not exists idx_activities_time on activities (time);

-- Join/relationship indexes
create index if not exists idx_department_members_department_id on department_members (department_id);
create index if not exists idx_department_members_member_id on department_members (member_id);

create index if not exists idx_committee_members_committee_id on committee_members (committee_id);
create index if not exists idx_committee_members_member_id on committee_members (member_id);

create index if not exists idx_user_groups_user_id on user_groups (user_id);
create index if not exists idx_user_groups_group_id on user_groups (group_id);

create index if not exists idx_group_roles_group_id on group_roles (group_id);
create index if not exists idx_group_roles_role_id on group_roles (role_id);

create index if not exists idx_role_permissions_role_id on role_permissions (role_id);
create index if not exists idx_role_permissions_permission_id on role_permissions (permission_id);

create index if not exists idx_users_email_lower on users (lower(email));

-- Unique member identifiers (case-insensitive email, exact phone)
create unique index if not exists idx_members_email_unique on members (lower(email)) where email is not null;
create unique index if not exists idx_members_phone_unique on members (phone) where phone is not null;
