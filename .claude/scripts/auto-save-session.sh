#!/bin/bash
# WibeBackUp — Auto-save session before compaction
# Called by PreCompact hook
# Copies transcript.jsonl entirely for reliable backup

PROJECT_DIR="${PWD}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Ensure sessions directory exists
mkdir -p "${PROJECT_DIR}/.claude/sessions"

# Find next session number
LAST_SESSION=$(ls -1 "${PROJECT_DIR}/.claude/sessions/session-"*.md 2>/dev/null | sort -V | tail -1)

if [ -z "$LAST_SESSION" ]; then
    NEXT_NUM="001"
else
    LAST_NUM=$(basename "$LAST_SESSION" | sed 's/session-\([0-9]*\)\.md/\1/')
    NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
fi

SESSION_FILE="${PROJECT_DIR}/.claude/sessions/session-${NEXT_NUM}.md"
TRANSCRIPT_BACKUP="${PROJECT_DIR}/.claude/sessions/transcript-${NEXT_NUM}.jsonl"

# Try to find transcript file
TRANSCRIPT_PATH=""
if [ -n "$CLAUDE_TRANSCRIPT_PATH" ]; then
    TRANSCRIPT_PATH="$CLAUDE_TRANSCRIPT_PATH"
fi

# Also check common locations
for path in \
    "${PROJECT_DIR}/.claude/transcript.jsonl" \
    "${HOME}/.claude/transcript.jsonl" \
    "${PROJECT_DIR}/transcript.jsonl"; do
    if [ -f "$path" ]; then
        TRANSCRIPT_PATH="$path"
        break
    fi
done

# Copy transcript if found
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    cp "$TRANSCRIPT_PATH" "$TRANSCRIPT_BACKUP"
    TRANSCRIPT_STATUS="Saved: transcript-${NEXT_NUM}.jsonl ($(du -h "$TRANSCRIPT_BACKUP" | cut -f1))"
else
    TRANSCRIPT_STATUS="Not found"
fi

# Create session marker file
cat > "$SESSION_FILE" << EOF
# Session — ${TIMESTAMP} (auto-saved before compact)

## Transcript
${TRANSCRIPT_STATUS}

## To restore
Run \`/load-session\` or read transcript-${NEXT_NUM}.jsonl

## Searched paths
- \$CLAUDE_TRANSCRIPT_PATH: ${CLAUDE_TRANSCRIPT_PATH:-"not set"}
- ${PROJECT_DIR}/.claude/transcript.jsonl
- ${HOME}/.claude/transcript.jsonl

---
*Auto-saved by WibeBackUp PreCompact hook*
EOF

# Rotate old sessions (keep max 5 of each type)
cd "${PROJECT_DIR}/.claude/sessions" 2>/dev/null
ls -1 session-*.md 2>/dev/null | sort -V | head -n -5 | xargs rm -f 2>/dev/null
ls -1 transcript-*.jsonl 2>/dev/null | sort -V | head -n -5 | xargs rm -f 2>/dev/null

echo "WibeBackUp: Auto-saved to ${SESSION_FILE}"
[ -f "$TRANSCRIPT_BACKUP" ] && echo "WibeBackUp: Transcript saved to ${TRANSCRIPT_BACKUP}"
