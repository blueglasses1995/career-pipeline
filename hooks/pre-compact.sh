#!/usr/bin/env bash
set -euo pipefail

# PreCompact hook: Auto-capture decisions/challenges from conversation
# Only runs if auto_capture is enabled in settings

DATA_DIR="${CAREER_PIPELINE_DATA_DIR:-$HOME/.career-pipeline}"
SETTINGS_PATH="${DATA_DIR}/settings.json"
DB_PATH="${DATA_DIR}/career.db"

# Check if auto_capture is globally enabled AND this project is tracked
CWD="$(pwd)"
if [ -f "${SETTINGS_PATH}" ]; then
  IS_TRACKED=$(python3 -c "
import json, sys, os
settings = json.load(open('${SETTINGS_PATH}'))
if not settings.get('auto_capture', True):
    print('false')
    sys.exit(0)
known = settings.get('known_projects', {})
cwd = os.path.realpath('${CWD}')
for project_path, val in known.items():
    real_path = os.path.realpath(project_path)
    if cwd == real_path or cwd.startswith(real_path + '/'):
        # Track if value is 'work', 'personal', 'oss', or True (legacy)
        print('true' if val and val != False else 'false')
        sys.exit(0)
print('false')
" 2>/dev/null || echo "false")
else
  IS_TRACKED="false"
fi

if [ "${IS_TRACKED}" != "true" ]; then
  exit 0
fi

# Read conversation from stdin (Claude passes it)
CONVERSATION=$(cat)

# Only proceed if conversation has substance
CHAR_COUNT=${#CONVERSATION}
if [ "${CHAR_COUNT}" -lt 500 ]; then
  exit 0
fi

# Save as raw auto-capture note for later review via /update-task
ESCAPED_CONTENT=$(echo "${CONVERSATION}" | head -c 10000 | python3 -c "
import sys, json
content = sys.stdin.read()
# Truncate and add marker
note = '[AUTO-CAPTURE] Conversation snapshot before compact.\n\n' + content[:8000]
print(json.dumps(note))
" 2>/dev/null || echo '""')

if [ "${ESCAPED_CONTENT}" != '""' ]; then
  sqlite3 "${DB_PATH}" "INSERT INTO raw_notes (content, note_type) VALUES (${ESCAPED_CONTENT}, 'auto_capture');" 2>/dev/null || true
  echo "Career Pipeline: Auto-captured conversation snapshot to raw_notes" >&2
fi
