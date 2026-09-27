#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/tmp/church-pgdata}"
LOG_FILE="${LOG_FILE:-/tmp/church-pg.log}"
PG_BIN_DIR="${PG_BIN_DIR:-/usr/lib/postgresql/18/bin}"
PG_CTL="${PG_CTL:-$PG_BIN_DIR/pg_ctl}"
PG_INITDB="${PG_INITDB:-$PG_BIN_DIR/initdb}"
PG_ISREADY="${PG_ISREADY:-$PG_BIN_DIR/pg_isready}"
PG_PORT="${PG_PORT:-5433}"

if [ ! -d "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR"
  "$PG_INITDB" -D "$DATA_DIR" -U postgres --auth-local=trust --auth-host=trust --encoding=UTF8 >/dev/null
fi

if "$PG_ISREADY" -h 127.0.0.1 -p "$PG_PORT" >/dev/null 2>&1; then
  echo "Postgres is already running on 127.0.0.1:$PG_PORT"
  exit 0
fi

if [ -f "$DATA_DIR/postmaster.pid" ]; then
  rm -f "$DATA_DIR/postmaster.pid"
fi

"$PG_CTL" -D "$DATA_DIR" -l "$LOG_FILE" -o "-c listen_addresses=127.0.0.1 -c unix_socket_directories='' -p $PG_PORT" start

"$PG_ISREADY" -h 127.0.0.1 -p "$PG_PORT"
echo "Postgres started on 127.0.0.1:$PG_PORT"
