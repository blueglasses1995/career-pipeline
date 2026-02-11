#!/usr/bin/env bash
set -euo pipefail

# Career Pipeline DB initialization script
# Creates the database and runs pending migrations

DATA_DIR="${CAREER_PIPELINE_DATA_DIR:-$HOME/.career-pipeline}"
DB_PATH="${DATA_DIR}/career.db"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMA_PATH="${SCRIPT_DIR}/schema.sql"

# Create data directory
mkdir -p "${DATA_DIR}"
mkdir -p "${DATA_DIR}/backups"
mkdir -p "${DATA_DIR}/dumps"

# Initialize DB with pragmas
if [ ! -f "${DB_PATH}" ]; then
  echo "Creating new database at ${DB_PATH}"
  sqlite3 "${DB_PATH}" "PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL; PRAGMA foreign_keys = ON;"
fi

# Check current schema version
CURRENT_VERSION=$(sqlite3 "${DB_PATH}" "SELECT COALESCE(MAX(version), 0) FROM schema_versions;" 2>/dev/null || echo "0")

# Apply migrations incrementally
if [ "${CURRENT_VERSION}" -lt 1 ]; then
  echo "Applying schema v1..."
  sqlite3 "${DB_PATH}" < "${SCHEMA_PATH}"
  echo "Schema v1 applied."
fi

if [ "${CURRENT_VERSION}" -lt 2 ]; then
  echo "Applying schema v2 (project_type, content_ideas, career_goals)..."
  sqlite3 "${DB_PATH}" < "${SCRIPT_DIR}/schema-v2.sql"
  echo "Schema v2 applied."
fi

FINAL_VERSION=$(sqlite3 "${DB_PATH}" "SELECT MAX(version) FROM schema_versions;" 2>/dev/null || echo "0")
if [ "${CURRENT_VERSION}" -eq "${FINAL_VERSION}" ] && [ "${CURRENT_VERSION}" -gt 0 ]; then
  echo "Database already at schema v${CURRENT_VERSION}."
fi

# Ensure pragmas are set
sqlite3 "${DB_PATH}" "PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL; PRAGMA foreign_keys = ON;"

# Initialize settings if not exist
SETTINGS_PATH="${DATA_DIR}/settings.json"
if [ ! -f "${SETTINGS_PATH}" ]; then
  cat > "${SETTINGS_PATH}" << 'SETTINGS_EOF'
{
  "language": "en",
  "auto_capture": true,
  "known_projects": {}
}
SETTINGS_EOF
  echo "Created default settings at ${SETTINGS_PATH}"
fi

echo "Career Pipeline DB ready at ${DB_PATH} (schema v$(sqlite3 "${DB_PATH}" "SELECT MAX(version) FROM schema_versions;"))"
