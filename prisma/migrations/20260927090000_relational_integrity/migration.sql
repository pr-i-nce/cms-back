-- Apply after taking a backup. This migration deliberately aborts on dirty links
-- instead of discarding duplicate or orphaned member and permission records.
BEGIN;
DO $$
DECLARE bad_count bigint;
BEGIN
  SELECT count(*) INTO bad_count FROM (
    SELECT lower(trim(d.name))
    FROM departments d
    JOIN members m ON lower(trim(m.department)) = lower(trim(d.name))
    WHERE coalesce(trim(m.department), '') <> ''
    GROUP BY lower(trim(d.name)) HAVING count(DISTINCT d.id) > 1
  ) ambiguous;
  IF bad_count > 0 THEN RAISE EXCEPTION '% department names are ambiguous for legacy member.department values; resolve names before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM members m
    WHERE coalesce(trim(m.department), '') <> ''
      AND NOT EXISTS (SELECT 1 FROM departments d WHERE lower(trim(d.name)) = lower(trim(m.department)));
  IF bad_count > 0 THEN RAISE EXCEPTION '% members reference a department name that does not exist; reconcile those department values before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM (
    SELECT d.id FROM departments d
    JOIN members m ON lower(trim(m.name)) = lower(trim(d.leader))
    WHERE coalesce(trim(d.leader), '') <> ''
    GROUP BY d.id HAVING count(DISTINCT m.id) > 1
  ) ambiguous;
  IF bad_count > 0 THEN RAISE EXCEPTION '% department leader names match multiple members; resolve those records before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM departments d
    WHERE coalesce(trim(d.leader), '') <> ''
      AND NOT EXISTS (SELECT 1 FROM members m WHERE lower(trim(m.name)) = lower(trim(d.leader)));
  IF bad_count > 0 THEN RAISE EXCEPTION '% departments have a leader name that does not match a member; link the leader member before migrating', bad_count; END IF;
END $$;

ALTER TABLE department_members ADD COLUMN is_primary boolean NOT NULL DEFAULT false;

-- Promote legacy home-department values into the authoritative assignment table.
INSERT INTO department_members (id, department_id, member_id, role, is_primary)
SELECT gen_random_uuid(), d.id::text, m.id::text, m.role, true
FROM members m
JOIN departments d ON lower(trim(d.name)) = lower(trim(m.department))
WHERE coalesce(trim(m.department), '') <> ''
  AND NOT EXISTS (
    SELECT 1 FROM department_members dm
    WHERE dm.department_id::text = d.id::text AND dm.member_id::text = m.id::text
  );

UPDATE department_members dm SET is_primary = true
FROM departments d, members m
WHERE dm.department_id::text = d.id::text
  AND dm.member_id::text = m.id::text
  AND coalesce(trim(m.department), '') <> ''
  AND lower(trim(m.department)) = lower(trim(d.name));

UPDATE department_members dm SET role = 'Leader'
FROM departments d, members m
WHERE dm.department_id::text = d.id::text
  AND dm.member_id::text = m.id::text
  AND coalesce(trim(d.leader), '') <> ''
  AND lower(trim(m.name)) = lower(trim(d.leader));

INSERT INTO department_members (id, department_id, member_id, role, is_primary)
SELECT gen_random_uuid(), d.id::text, m.id::text, 'Leader', false
FROM departments d
JOIN members m ON lower(trim(m.name)) = lower(trim(d.leader))
WHERE coalesce(trim(d.leader), '') <> ''
  AND NOT EXISTS (
    SELECT 1 FROM department_members dm
    WHERE dm.department_id::text = d.id::text AND dm.member_id::text = m.id::text
  );

DO $$
DECLARE bad_count bigint;
BEGIN
  SELECT count(*) INTO bad_count FROM department_members d
    LEFT JOIN departments p ON p.id::text = d.department_id::text
    LEFT JOIN members m ON m.id::text = d.member_id::text
    WHERE p.id IS NULL OR m.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'department_members has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM committee_members d
    LEFT JOIN committees p ON p.id::text = d.committee_id::text
    LEFT JOIN members m ON m.id::text = d.member_id::text
    WHERE p.id IS NULL OR m.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'committee_members has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM branch_pastors d
    LEFT JOIN branches p ON p.id::text = d.branch_id::text
    LEFT JOIN members m ON m.id::text = d.member_id::text
    WHERE p.id IS NULL OR m.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'branch_pastors has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM user_groups d
    LEFT JOIN users u ON u.id::text = d.user_id::text
    LEFT JOIN groups g ON g.id::text = d.group_id::text
    WHERE u.id IS NULL OR g.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'user_groups has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM group_roles d
    LEFT JOIN groups g ON g.id::text = d.group_id::text
    LEFT JOIN roles r ON r.id::text = d.role_id::text
    WHERE g.id IS NULL OR r.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'group_roles has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM role_permissions d
    LEFT JOIN roles r ON r.id::text = d.role_id::text
    LEFT JOIN permissions p ON p.id::text = d.permission_id::text
    WHERE r.id IS NULL OR p.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'role_permissions has % orphaned links; repair these rows before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM refresh_tokens d
    LEFT JOIN users u ON u.id::text = d.user_id::text
    WHERE u.id IS NULL;
  IF bad_count > 0 THEN RAISE EXCEPTION 'refresh_tokens has % orphaned links; repair these rows before migrating', bad_count; END IF;

  IF EXISTS (SELECT 1 FROM department_members GROUP BY department_id, member_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'department_members contains duplicate member assignments'; END IF;
  IF EXISTS (SELECT 1 FROM committee_members GROUP BY committee_id, member_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'committee_members contains duplicate member assignments'; END IF;
  IF EXISTS (SELECT 1 FROM branch_pastors GROUP BY branch_id, member_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'branch_pastors contains duplicate pastor assignments'; END IF;
  IF EXISTS (SELECT 1 FROM user_groups GROUP BY user_id, group_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'user_groups contains duplicate user/group assignments'; END IF;
  IF EXISTS (SELECT 1 FROM group_roles GROUP BY group_id, role_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'group_roles contains duplicate group/role assignments'; END IF;
  IF EXISTS (SELECT 1 FROM role_permissions GROUP BY role_id, permission_id HAVING count(*) > 1)
    THEN RAISE EXCEPTION 'role_permissions contains duplicate role/permission assignments'; END IF;
END $$;

CREATE OR REPLACE FUNCTION church_normalize_phone(value text) RETURNS text
LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$
  SELECT CASE
    WHEN digits = '' THEN NULL
    WHEN digits ~ '^254[17][0-9]{8}$' THEN digits
    WHEN digits ~ '^0[17][0-9]{8}$' THEN '254' || substring(digits FROM 2)
    WHEN digits ~ '^[17][0-9]{8}$' THEN '254' || digits
    ELSE digits
  END
  FROM (SELECT regexp_replace(coalesce(value, ''), '[^0-9]', '', 'g') AS digits) normalized
$$;

DO $$
DECLARE bad_count bigint;
BEGIN
  SELECT count(*) INTO bad_count FROM (
    SELECT church_normalize_phone(phone) FROM members
    WHERE church_normalize_phone(phone) IS NOT NULL
    GROUP BY church_normalize_phone(phone) HAVING count(*) > 1
  ) duplicated;
  IF bad_count > 0 THEN RAISE EXCEPTION '% duplicate member phone numbers after normalization; resolve duplicates before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM (
    SELECT lower(trim(email)) FROM members
    WHERE coalesce(trim(email), '') <> ''
    GROUP BY lower(trim(email)) HAVING count(*) > 1
  ) duplicated;
  IF bad_count > 0 THEN RAISE EXCEPTION '% duplicate member email addresses; resolve duplicates before migrating', bad_count; END IF;
  SELECT count(*) INTO bad_count FROM (
    SELECT lower(trim(email)) FROM users
    WHERE coalesce(trim(email), '') <> ''
    GROUP BY lower(trim(email)) HAVING count(*) > 1
  ) duplicated;
  IF bad_count > 0 THEN RAISE EXCEPTION '% duplicate user email addresses; resolve duplicates before migrating', bad_count; END IF;
END $$;

ALTER TABLE department_members
  ALTER COLUMN department_id TYPE uuid USING department_id::uuid,
  ALTER COLUMN member_id TYPE uuid USING member_id::uuid;
ALTER TABLE committee_members
  ALTER COLUMN committee_id TYPE uuid USING committee_id::uuid,
  ALTER COLUMN member_id TYPE uuid USING member_id::uuid;
ALTER TABLE branch_pastors
  ALTER COLUMN branch_id TYPE uuid USING branch_id::uuid,
  ALTER COLUMN member_id TYPE uuid USING member_id::uuid;
ALTER TABLE user_groups
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid,
  ALTER COLUMN group_id TYPE uuid USING group_id::uuid;
ALTER TABLE group_roles
  ALTER COLUMN group_id TYPE uuid USING group_id::uuid,
  ALTER COLUMN role_id TYPE uuid USING role_id::uuid;
ALTER TABLE role_permissions
  ALTER COLUMN role_id TYPE uuid USING role_id::uuid,
  ALTER COLUMN permission_id TYPE uuid USING permission_id::uuid;
ALTER TABLE refresh_tokens
  ALTER COLUMN user_id TYPE uuid USING user_id::uuid;

ALTER TABLE users ADD COLUMN member_id uuid;
UPDATE users u SET member_id = u.id
  FROM members m
  WHERE u.id = m.id AND lower(coalesce(u.role, '')) = 'leader';

ALTER TABLE users ADD CONSTRAINT users_member_id_fkey
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE SET NULL;
ALTER TABLE refresh_tokens ADD CONSTRAINT refresh_tokens_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE department_members ADD CONSTRAINT department_members_department_id_fkey
  FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE;
ALTER TABLE department_members ADD CONSTRAINT department_members_member_id_fkey
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;
ALTER TABLE committee_members ADD CONSTRAINT committee_members_committee_id_fkey
  FOREIGN KEY (committee_id) REFERENCES committees(id) ON DELETE CASCADE;
ALTER TABLE committee_members ADD CONSTRAINT committee_members_member_id_fkey
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;
ALTER TABLE branch_pastors ADD CONSTRAINT branch_pastors_branch_id_fkey
  FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;
ALTER TABLE branch_pastors ADD CONSTRAINT branch_pastors_member_id_fkey
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;
ALTER TABLE user_groups ADD CONSTRAINT user_groups_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_groups ADD CONSTRAINT user_groups_group_id_fkey
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;
ALTER TABLE group_roles ADD CONSTRAINT group_roles_group_id_fkey
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;
ALTER TABLE group_roles ADD CONSTRAINT group_roles_role_id_fkey
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;
ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_role_id_fkey
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;
ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_permission_id_fkey
  FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE;

ALTER TABLE department_members ADD CONSTRAINT department_members_department_member_key UNIQUE (department_id, member_id);
ALTER TABLE committee_members ADD CONSTRAINT committee_members_committee_member_key UNIQUE (committee_id, member_id);
ALTER TABLE branch_pastors ADD CONSTRAINT branch_pastors_branch_member_key UNIQUE (branch_id, member_id);
ALTER TABLE user_groups ADD CONSTRAINT user_groups_user_group_key UNIQUE (user_id, group_id);
ALTER TABLE group_roles ADD CONSTRAINT group_roles_group_role_key UNIQUE (group_id, role_id);
ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_role_permission_key UNIQUE (role_id, permission_id);
CREATE UNIQUE INDEX users_member_id_key ON users(member_id) WHERE member_id IS NOT NULL;
CREATE UNIQUE INDEX department_members_one_primary_per_member ON department_members(member_id) WHERE is_primary;
CREATE UNIQUE INDEX members_phone_normalized_key ON members(church_normalize_phone(phone)) WHERE church_normalize_phone(phone) IS NOT NULL;
CREATE UNIQUE INDEX members_email_normalized_key ON members(lower(trim(email))) WHERE coalesce(trim(email), '') <> '';
CREATE UNIQUE INDEX users_email_normalized_key ON users(lower(trim(email))) WHERE coalesce(trim(email), '') <> '';
COMMIT;
