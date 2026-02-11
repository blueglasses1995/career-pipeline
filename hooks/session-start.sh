#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: Initialize DB and run migrations
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
"${PLUGIN_ROOT}/scripts/db-init.sh" 2>&1 | while read -r line; do
  echo "$line" >&2
done

# Output success message for Claude context
DATA_DIR="${CAREER_PIPELINE_DATA_DIR:-$HOME/.career-pipeline}"
DB_PATH="${DATA_DIR}/career.db"
SETTINGS_PATH="${DATA_DIR}/settings.json"

if [ -f "${SETTINGS_PATH}" ]; then
  LANG_SETTING=$(python3 -c "import json; print(json.load(open('${SETTINGS_PATH}'))['language'])" 2>/dev/null || echo "en")
else
  LANG_SETTING="en"
fi

TASK_COUNT=$(sqlite3 "${DB_PATH}" "SELECT COUNT(*) FROM tasks;" 2>/dev/null || echo "0")
PROJECT_COUNT=$(sqlite3 "${DB_PATH}" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "0")

echo "Career Pipeline: ${PROJECT_COUNT} projects, ${TASK_COUNT} tasks (lang: ${LANG_SETTING})"

# Check if current working directory is a known project
CWD="$(pwd)"
if [ -f "${SETTINGS_PATH}" ]; then
  PROJECT_STATUS=$(python3 -c "
import json, sys, os
settings = json.load(open('${SETTINGS_PATH}'))
known = settings.get('known_projects', {})
cwd = os.path.realpath('${CWD}')
for project_path, val in known.items():
    real_path = os.path.realpath(project_path)
    if cwd == real_path or cwd.startswith(real_path + '/'):
        if val == False:
            print('ignored')
        elif val in ('work', 'personal', 'oss'):
            print('tracked:' + val)
        elif val == True:
            print('tracked:work')
        else:
            print('ignored')
        sys.exit(0)
print('unknown')
" 2>/dev/null || echo "unknown")
else
  PROJECT_STATUS="unknown"
fi

if [ "${PROJECT_STATUS}" = "unknown" ]; then
  echo "[CAREER-PIPELINE-PROMPT] New project detected: ${CWD}. Ask the user: 'Track this project for career-pipeline?' Options: (1) Work project (2) Personal/OSS project (3) Don't track. Save to ~/.career-pipeline/settings.json known_projects: work='work', personal='personal', don't track=false."
elif [[ "${PROJECT_STATUS}" == tracked:* ]]; then
  PROJECT_TYPE="${PROJECT_STATUS#tracked:}"
  echo "[CAREER-PIPELINE] Project tracked (${PROJECT_TYPE}): auto-capture enabled for ${CWD}"
fi
