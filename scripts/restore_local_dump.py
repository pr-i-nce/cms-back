#!/usr/bin/env python3
"""Restore the local church database from a data-only SQL dump.

The bundled dump was produced from an older schema where several tables used
an audit-first column order. The current Prisma schema stores the same data but
in a different order, so a raw `psql -f` import fails. This script rewrites the
INSERT statements into the current column layout, recreates the local database,
and then loads the transformed data.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import urlparse, urlunparse


BACKEND_DIR = Path(__file__).resolve().parent.parent
DEFAULT_DUMP = Path("/home/pc/Downloads/local_data.sql")

TARGET_COLUMNS: dict[str, list[str]] = {
    "activities": ["id", "action", "details", "time", "type"],
    "branches": [
        "id",
        "name",
        "location",
        "address",
        "phone",
        "email",
        "status",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "branch_pastors": ["id", "branch_id", "member_id", "role"],
    "committee_members": ["id", "committee_id", "member_id", "role"],
    "committees": [
        "id",
        "name",
        "description",
        "status",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "department_members": ["id", "department_id", "member_id", "role"],
    "departments": [
        "id",
        "name",
        "description",
        "leader",
        "members_count",
        "status",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "group_roles": ["id", "group_id", "role_id"],
    "groups": [
        "id",
        "name",
        "description",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "latency_logs": [
        "id",
        "source",
        "method",
        "path",
        "status",
        "duration_ms",
        "timestamp",
    ],
    "members": [
        "id",
        "name",
        "phone",
        "email",
        "gender",
        "department",
        "role",
        "status",
        "date_joined",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "permissions": [
        "id",
        "name",
        "description",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "refresh_tokens": [
        "id",
        "user_id",
        "token_hash",
        "created_at",
        "expires_at",
        "revoked_at",
        "replaced_by",
        "last_used_at",
    ],
    "role_permissions": ["id", "role_id", "permission_id"],
    "roles": [
        "id",
        "name",
        "description",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "sms_records": [
        "id",
        "message",
        "recipients",
        "recipient_count",
        "date",
        "status",
        "recipient_type",
        "provider_status",
        "provider_code",
        "provider_message",
        "provider_response",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
    "user_groups": ["id", "user_id", "group_id"],
    "users": [
        "id",
        "name",
        "email",
        "phone",
        "role",
        "status",
        "password_hash",
        "created_by",
        "created_at",
        "last_edited_by",
        "last_edited_at",
        "sent_by",
    ],
}

# Tables whose legacy dump order differs from the current layout.
SOURCE_COLUMNS: dict[str, list[str]] = {
    "activities": TARGET_COLUMNS["activities"],
    "branches": TARGET_COLUMNS["branches"],
    "branch_pastors": TARGET_COLUMNS["branch_pastors"],
    "committee_members": TARGET_COLUMNS["committee_members"],
    "department_members": TARGET_COLUMNS["department_members"],
    "group_roles": TARGET_COLUMNS["group_roles"],
    "latency_logs": TARGET_COLUMNS["latency_logs"],
    "role_permissions": TARGET_COLUMNS["role_permissions"],
    "user_groups": TARGET_COLUMNS["user_groups"],
    "committees": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "description",
        "name",
        "status",
    ],
    "departments": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "description",
        "leader",
        "members_count",
        "name",
        "status",
    ],
    "groups": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "description",
        "name",
    ],
    "members": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "date_joined",
        "department",
        "email",
        "gender",
        "name",
        "phone",
        "role",
        "status",
    ],
    "permissions": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "description",
        "name",
    ],
    "refresh_tokens": [
        "id",
        "user_id",
        "token_hash",
        "created_at",
        "expires_at",
        "revoked_at",
        "replaced_by",
        "last_used_at",
    ],
    "roles": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "description",
        "name",
    ],
    "sms_records": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "date",
        "message",
        "recipient_count",
        "recipient_type",
        "recipients",
        "provider_status",
        "provider_code",
        "provider_message",
        "provider_response",
        "status",
    ],
    "users": [
        "id",
        "created_at",
        "created_by",
        "last_edited_at",
        "last_edited_by",
        "sent_by",
        "email",
        "name",
        "password_hash",
        "role",
        "status",
        "phone",
    ],
}


def load_database_url() -> str:
    env_url = os.environ.get("DATABASE_URL")
    if env_url:
        return env_url

    env_file = BACKEND_DIR / ".env"
    if not env_file.exists():
        raise SystemExit(f"Missing env file: {env_file}")

    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("DATABASE_URL="):
            return line.split("=", 1)[1].strip()
    raise SystemExit(f"DATABASE_URL not found in {env_file}")


def strip_query(database_url: str) -> str:
    parsed = urlparse(database_url)
    return urlunparse(parsed._replace(query="", fragment=""))


def run(cmd: list[str], *, cwd: Path | None = None) -> None:
    subprocess.run(cmd, cwd=str(cwd) if cwd else None, check=True)


def run_capture(cmd: list[str], *, cwd: Path | None = None) -> str:
    return subprocess.check_output(cmd, cwd=str(cwd) if cwd else None, text=True).strip()


def create_refresh_tokens_table(database_url: str) -> None:
    ddl = """
    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id uuid PRIMARY KEY,
      user_id uuid NOT NULL,
      token_hash text NOT NULL UNIQUE,
      created_at text NOT NULL,
      expires_at text NOT NULL,
      revoked_at text NULL,
      replaced_by text NULL,
      last_used_at text NULL
    );
    CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON refresh_tokens(user_id);
    """
    run(["psql", strip_query(database_url), "-v", "ON_ERROR_STOP=1", "-c", ddl])


def drop_and_recreate_database(database_url: str) -> None:
    database_url = strip_query(database_url)
    parsed = urlparse(database_url)
    if not parsed.path or parsed.path == "/":
        raise SystemExit(f"Invalid DATABASE_URL, missing database name: {database_url}")

    db_name = parsed.path.lstrip("/")
    admin_url = urlunparse(parsed._replace(path="/postgres", query="", fragment=""))
    run(["psql", admin_url, "-v", "ON_ERROR_STOP=1", "-c", f"DROP DATABASE IF EXISTS {db_name} WITH (FORCE);"])
    run(["psql", admin_url, "-v", "ON_ERROR_STOP=1", "-c", f"CREATE DATABASE {db_name};"])


def split_values(values_block: str) -> list[str]:
    values: list[str] = []
    token: list[str] = []
    in_quote = False
    i = 0
    while i < len(values_block):
        ch = values_block[i]
        if ch == "'":
            token.append(ch)
            if in_quote and i + 1 < len(values_block) and values_block[i + 1] == "'":
                token.append("'")
                i += 2
                continue
            in_quote = not in_quote
            i += 1
            continue
        if ch == "," and not in_quote:
            values.append("".join(token).strip())
            token = []
            i += 1
            continue
        token.append(ch)
        i += 1
    if token:
        values.append("".join(token).strip())
    return values


def find_statement_end(text: str, start: int) -> int:
    in_quote = False
    i = start
    while i < len(text):
        ch = text[i]
        if ch == "'":
            if in_quote and i + 1 < len(text) and text[i + 1] == "'":
                i += 2
                continue
            in_quote = not in_quote
            i += 1
            continue
        if ch == ";" and not in_quote:
            return i
        i += 1
    raise ValueError("Missing statement terminator")


def transform_dump(dump_path: Path, output_path: Path) -> tuple[int, int]:
    text = dump_path.read_text()
    insert_re = re.compile(r"INSERT INTO public\.([a-z_]+) VALUES\s*\(", re.IGNORECASE | re.DOTALL)

    rows = 0
    tables = set()
    with output_path.open("w", encoding="utf-8") as out:
        out.write(
            """-- Transformed from a data-only PostgreSQL dump.\n"""
            """-- The source file used an older column order for several tables.\n\n"""
        )
        out.write(
            """CREATE TABLE IF NOT EXISTS refresh_tokens (\n"""
            """  id uuid PRIMARY KEY,\n"""
            """  user_id uuid NOT NULL,\n"""
            """  token_hash text NOT NULL UNIQUE,\n"""
            """  created_at text NOT NULL,\n"""
            """  expires_at text NOT NULL,\n"""
            """  revoked_at text NULL,\n"""
            """  replaced_by text NULL,\n"""
            """  last_used_at text NULL\n"""
            """);\n"""
            """CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON refresh_tokens(user_id);\n\n"""
        )

        pos = 0
        while True:
            match = insert_re.search(text, pos)
            if not match:
                break
            table = match.group(1)
            if table not in TARGET_COLUMNS:
                raise SystemExit(f"Unsupported table in dump: {table}")
            values_start = match.end()
            statement_end = find_statement_end(text, values_start)
            raw_values = text[values_start:statement_end].strip()
            if not raw_values.endswith(")"):
                raise SystemExit(f"Unexpected VALUES block for {table}")
            values_block = raw_values[:-1].strip()
            values = split_values(values_block)

            source_cols = SOURCE_COLUMNS.get(table, TARGET_COLUMNS[table])
            target_cols = TARGET_COLUMNS[table]
            if len(values) != len(source_cols):
                raise SystemExit(
                    f"Column mismatch for {table}: found {len(values)} values, expected {len(source_cols)}"
                )
            row_map = dict(zip(source_cols, values))
            ordered = [row_map[col] for col in target_cols]
            out.write(f"INSERT INTO public.{table} ({', '.join(target_cols)}) VALUES ({', '.join(ordered)});\n")
            rows += 1
            tables.add(table)
            pos = statement_end + 1

    return rows, len(tables)


def ensure_prisma_schema() -> None:
    run(["npx", "prisma", "db", "push"], cwd=BACKEND_DIR)


def main() -> int:
    dump_arg = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_DUMP
    if not dump_arg.exists():
        raise SystemExit(f"Dump file not found: {dump_arg}")

    database_url = load_database_url()
    drop_and_recreate_database(database_url)
    ensure_prisma_schema()

    with tempfile.NamedTemporaryFile(prefix="church-restore-", suffix=".sql", delete=False) as tmp:
        transformed_path = Path(tmp.name)

    try:
        rows, tables = transform_dump(dump_arg, transformed_path)
        create_refresh_tokens_table(database_url)
        run(["psql", strip_query(database_url), "-v", "ON_ERROR_STOP=1", "-f", str(transformed_path)])

        counts = {}
        for table in ["users", "groups", "roles", "permissions", "members", "departments", "committees", "sms_records", "refresh_tokens"]:
            counts[table] = run_capture(["psql", strip_query(database_url), "-Atc", f"select count(*) from {table};"])

        print(f"Restored {rows} rows across {tables} tables from {dump_arg}")
        for table, count in counts.items():
            print(f"{table}: {count}")
        return 0
    finally:
        try:
            transformed_path.unlink(missing_ok=True)
        except Exception:
            pass


if __name__ == "__main__":
    raise SystemExit(main())
