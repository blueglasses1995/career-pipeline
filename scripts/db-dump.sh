#!/usr/bin/env bash
set -euo pipefail

# Export career.db to SQL text dump for git tracking

DATA_DIR="${CAREER_PIPELINE_DATA_DIR:-$HOME/.career-pipeline}"
DB_PATH="${DATA_DIR}/career.db"
DUMP_PATH="${DATA_DIR}/dumps/career.sql"

if [ ! -f "${DB_PATH}" ]; then
  echo "Error: Database not found at ${DB_PATH}" >&2
  exit 1
fi

mkdir -p "${DATA_DIR}/dumps"
sqlite3 "${DB_PATH}" .dump > "${DUMP_PATH}"
echo "Exported to ${DUMP_PATH}"
