#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="${BACKEND_DIR:-$SCRIPT_DIR}"
ENV_FILE="${ENV_FILE:-$BACKEND_DIR/.env.prod}"
BACKEND_URL="${BACKEND_URL:-http://localhost:8081}"

NAME="Prince mumo"
PHONE="0728241740"
EMAIL="princegrcic@gmail.com"
ROLE="Super Admin"
STATUS="Active"
PASSWORD="${PASSWORD:-Prince123!}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi

DATABASE_URL=$(python3 - <<'PY'
import os
import re
path=os.environ.get('ENV_FILE')
with open(path,'r') as f:
    for line in f:
        line=line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith('DATABASE_URL='):
            print(line.split('=',1)[1])
            break
PY
)

if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL not found in $ENV_FILE" >&2
  exit 1
fi

PASSWORD_HASH=$(cd "$BACKEND_DIR" && node - <<'NODE'
const bcrypt = require('bcryptjs');
const password = process.env.PASSWORD || 'Prince123!';
bcrypt.hash(password, 10).then(hash => {
  console.log(hash);
}).catch(err => {
  console.error(err);
  process.exit(1);
});
NODE
)

PERMISSIONS=(
  READ_ALL
  BRANCH_CREATE
  BRANCH_DEACTIVATE
  BRANCH_PASTOR_ADD
  BRANCH_PASTOR_REMOVE
  BRANCH_UPDATE
  COMMITTEE_CREATE
  COMMITTEE_DEACTIVATE
  COMMITTEE_MEMBER_ADD
  COMMITTEE_MEMBER_REMOVE
  COMMITTEE_UPDATE
  DEPARTMENT_CREATE
  DEPARTMENT_DEACTIVATE
  DEPARTMENT_UPDATE
  DEPT_MEMBER_ADD
  DEPT_MEMBER_REMOVE
  GROUP_ASSIGN_ROLES
  GROUP_CREATE
  GROUP_UPDATE
  MEMBER_CREATE
  MEMBER_DELETE
  MEMBER_UPDATE
  PERMISSION_VIEW
  ROLE_VIEW
  SMS_SEND
  SMS_VIEW
  USER_ASSIGN_GROUPS
  USER_CREATE
  USER_DEACTIVATE
  USER_RESET_PASSWORD
  USER_UPDATE
)

gen_uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen
    return
  fi
  python3 - <<'PY'
import uuid
print(uuid.uuid4())
PY
}

GROUP_ID=$(psql "$DATABASE_URL" -Atc "select id from groups where lower(name)=lower('Super Admins') limit 1;")
if [ -z "$GROUP_ID" ]; then
  GROUP_ID=$(gen_uuid)
fi

USER_ID=$(psql "$DATABASE_URL" -Atc "select id from users where lower(email)=lower('princegrcic@gmail.com') limit 1;")
if [ -z "$USER_ID" ]; then
  USER_ID=$(gen_uuid)
fi

USER_GROUP_ID=$(gen_uuid)

SQL=$(mktemp)
cat > "$SQL" <<'SQL'
DO $$
DECLARE
  v_perm text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM groups WHERE id = '__GROUP_ID__') THEN
    INSERT INTO groups (id, name, description, created_at)
    VALUES ('__GROUP_ID__', 'Super Admins', 'All permissions', now()::text);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE id = '__USER_ID__') THEN
    INSERT INTO users (id, name, email, phone, role, status, password_hash, created_at, last_edited_at)
    VALUES ('__USER_ID__', 'Prince mumo', 'princegrcic@gmail.com', '0728241740', 'Super Admin', 'Active', '__PASSWORD_HASH__', now()::text, now()::text);
  END IF;

  DELETE FROM user_groups WHERE user_id = '__USER_ID__' AND group_id = '__GROUP_ID__';
  INSERT INTO user_groups (id, user_id, group_id)
  VALUES ('__USER_GROUP_ID__', '__USER_ID__', '__GROUP_ID__');

END $$;
SQL

sed -i "s/__PASSWORD_HASH__/${PASSWORD_HASH//\//\\/}/" "$SQL"
sed -i "s/__GROUP_ID__/$GROUP_ID/" "$SQL"
sed -i "s/__USER_ID__/$USER_ID/" "$SQL"
sed -i "s/__USER_GROUP_ID__/$USER_GROUP_ID/" "$SQL"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SQL"
rm -f "$SQL"

for perm in "${PERMISSIONS[@]}"; do
  perm_id=$(gen_uuid)
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "insert into permissions (id, name, created_at) select '$perm_id', '$perm', now()::text where not exists (select 1 from permissions where name = '$perm');"
done

echo "Super Admin created/ensured: $EMAIL"
echo "Password: $PASSWORD"

echo "\nTesting login against $BACKEND_URL ..."
curl -sS -i "$BACKEND_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | sed -n '1,20p'
