-- Seed the permission vocabulary and least-privilege role/group defaults.
-- User accounts and user-to-group assignments are handled separately.
BEGIN;

INSERT INTO permissions (id, name, description, created_by, created_at)
SELECT gen_random_uuid(), source.name, source.description, 'rbac_baseline', now()::text
FROM (VALUES
  ('READ_ALL', 'Read application-wide records and reports'),
  ('BRANCH_CREATE', 'Create branches'),
  ('BRANCH_DEACTIVATE', 'Deactivate branches'),
  ('BRANCH_PASTOR_ADD', 'Assign pastors to branches'),
  ('BRANCH_PASTOR_REMOVE', 'Remove pastors from branches'),
  ('BRANCH_UPDATE', 'Update branches'),
  ('COMMITTEE_CREATE', 'Create committees'),
  ('COMMITTEE_DEACTIVATE', 'Deactivate committees'),
  ('COMMITTEE_MEMBER_ADD', 'Add committee members'),
  ('COMMITTEE_MEMBER_REMOVE', 'Remove committee members'),
  ('COMMITTEE_UPDATE', 'Update committees'),
  ('DEPARTMENT_CREATE', 'Create departments'),
  ('DEPARTMENT_DEACTIVATE', 'Deactivate departments'),
  ('DEPARTMENT_UPDATE', 'Update departments'),
  ('DEPT_MEMBER_ADD', 'Assign members to departments'),
  ('DEPT_MEMBER_REMOVE', 'Remove members from departments'),
  ('GROUP_ASSIGN_ROLES', 'Assign roles to groups'),
  ('GROUP_CREATE', 'Create groups'),
  ('GROUP_UPDATE', 'Update groups'),
  ('MEMBER_CREATE', 'Create members'),
  ('MEMBER_DELETE', 'Delete members'),
  ('MEMBER_UPDATE', 'Update members'),
  ('PERMISSION_VIEW', 'View permissions'),
  ('ROLE_VIEW', 'View roles'),
  ('SMS_SEND', 'Send SMS messages'),
  ('SMS_VIEW', 'View SMS records and templates'),
  ('USER_ASSIGN_GROUPS', 'Assign users to groups'),
  ('USER_CREATE', 'Create user accounts'),
  ('USER_DEACTIVATE', 'Deactivate user accounts'),
  ('USER_RESET_PASSWORD', 'Reset user passwords'),
  ('USER_UPDATE', 'Update user accounts')
) AS source(name, description)
WHERE NOT EXISTS (
  SELECT 1 FROM permissions existing
  WHERE lower(trim(existing.name)) = lower(source.name)
);

INSERT INTO roles (id, name, description, created_by, created_at)
SELECT gen_random_uuid(), source.name, source.description, 'rbac_baseline', now()::text
FROM (VALUES
  ('Super Admin', 'Full system administration'),
  ('Administrator', 'Church operations administration without account or RBAC delegation'),
  ('Ministry Leader', 'Department and committee leadership permissions')
) AS source(name, description)
WHERE NOT EXISTS (
  SELECT 1 FROM roles existing
  WHERE lower(trim(existing.name)) = lower(source.name)
);

INSERT INTO groups (id, name, description, created_by, created_at)
SELECT gen_random_uuid(), source.name, source.description, 'rbac_baseline', now()::text
FROM (VALUES
  ('Super Admins', 'System administrators with full access'),
  ('Administrators', 'Church operations administrators'),
  ('Leaders', 'Department and committee leaders')
) AS source(name, description)
WHERE NOT EXISTS (
  SELECT 1 FROM groups existing
  WHERE lower(trim(existing.name)) = lower(source.name)
);

INSERT INTO role_permissions (id, role_id, permission_id)
SELECT gen_random_uuid(), r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE lower(trim(r.name)) = 'super admin'
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (id, role_id, permission_id)
SELECT gen_random_uuid(), r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE lower(trim(r.name)) = 'administrator'
  AND p.name NOT IN (
    'GROUP_ASSIGN_ROLES', 'GROUP_CREATE', 'GROUP_UPDATE',
    'USER_ASSIGN_GROUPS', 'USER_CREATE', 'USER_DEACTIVATE',
    'USER_RESET_PASSWORD', 'USER_UPDATE'
  )
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (id, role_id, permission_id)
SELECT gen_random_uuid(), r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE lower(trim(r.name)) = 'ministry leader'
  AND p.name IN (
    'DEPARTMENT_UPDATE', 'DEPARTMENT_DEACTIVATE', 'DEPT_MEMBER_ADD',
    'DEPT_MEMBER_REMOVE', 'COMMITTEE_UPDATE', 'COMMITTEE_DEACTIVATE',
    'COMMITTEE_MEMBER_ADD', 'COMMITTEE_MEMBER_REMOVE', 'MEMBER_UPDATE',
    'SMS_SEND', 'SMS_VIEW'
  )
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO group_roles (id, group_id, role_id)
SELECT gen_random_uuid(), g.id, r.id
FROM groups g
JOIN roles r ON
  (lower(trim(g.name)) = 'super admins' AND lower(trim(r.name)) = 'super admin') OR
  (lower(trim(g.name)) = 'administrators' AND lower(trim(r.name)) = 'administrator') OR
  (lower(trim(g.name)) = 'leaders' AND lower(trim(r.name)) = 'ministry leader')
ON CONFLICT (group_id, role_id) DO NOTHING;

COMMIT;
