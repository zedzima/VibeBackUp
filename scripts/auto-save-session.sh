#!/bin/bash
# VibeBackUp — Auto-save clean conversation before compaction
# Called by PreCompact hook
# Extracts only user questions and assistant text responses

set -euo pipefail

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
DEBUG_LOG="/tmp/vibebackup-debug.log"

# Log for debugging
exec > >(tee -a "$DEBUG_LOG") 2>&1
echo "=== VibeBackUp $(date) ==="

# Check stdin
STDIN_DATA=""
if [ ! -t 0 ]; then
    STDIN_DATA=$(cat)
    echo "Stdin: $STDIN_DATA"
fi

# Try to get session ID from stdin
SESSION_ID=$(echo "$STDIN_DATA" | jq -r '.sessionId // empty' 2>/dev/null || true)

# Find transcript
TRANSCRIPT_PATH=""
if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ] && [ "$SESSION_ID" != "" ]; then
    TRANSCRIPT_PATH=$(find "$CLAUDE_PROJECTS_DIR" -name "${SESSION_ID}.jsonl" -type f 2>/dev/null | head -1)
    echo "By session ID: $TRANSCRIPT_PATH"
fi

# Fallback: most recent transcript
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    if [ -d "$CLAUDE_PROJECTS_DIR" ]; then
        TRANSCRIPT_PATH=$(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -type f -exec stat -f '%m %N' {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    fi
fi

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    echo "No transcript found"
    exit 0
fi

echo "Transcript: $TRANSCRIPT_PATH"

# Extract project directory - most frequent non-home cwd
# Handle paths with spaces correctly
HOME_LOWER=$(echo "$HOME" | tr '[:upper:]' '[:lower:]')
PROJECT_DIR=$(jq -r 'if .cwd then .cwd else empty end' "$TRANSCRIPT_PATH" 2>/dev/null | while read -r line; do
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    if [ "$line_lower" != "$HOME_LOWER" ] && [ -n "$line" ]; then
        echo "$line"
    fi
done | sort | uniq -c | sort -rn | head -1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')

# Fallback to last cwd
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR=$(jq -r 'if .cwd then .cwd else empty end' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1)
fi

# Fallback to PWD
if [ -z "$PROJECT_DIR" ] || [ "$PROJECT_DIR" = "null" ]; then
    PROJECT_DIR="${PWD}"
fi

echo "Project: $PROJECT_DIR"

# Ensure sessions directory exists
mkdir -p "${PROJECT_DIR}/.claude/sessions"

# Find next session number
LAST_SESSION=$(ls -1 "${PROJECT_DIR}/.claude/sessions/conversation-"*.md 2>/dev/null | sort -V | tail -1 || true)

if [ -z "$LAST_SESSION" ]; then
    NEXT_NUM="001"
else
    LAST_NUM=$(basename "$LAST_SESSION" | sed 's/conversation-\([0-9]*\)\.md/\1/')
    NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
fi

SESSION_FILE="${PROJECT_DIR}/.claude/sessions/conversation-${NEXT_NUM}.md"

# Extract clean conversation
{
    echo "# Session Conversation — ${TIMESTAMP}"
    echo ""
    echo "## Messages"
    echo ""

    while IFS= read -r line; do
        msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
        user_type=$(echo "$line" | jq -r '.userType // empty' 2>/dev/null)

        if [ "$msg_type" = "user" ] && [ "$user_type" = "external" ]; then
            msg_content=$(echo "$line" | jq -r '
                if (.message | type) == "string" then
                    .message
                elif (.message.content | type) == "string" then
                    .message.content
                elif (.message.content | type) == "array" then
                    if (.message.content[0].type // "") == "tool_result" then
                        ""
                    else
                        .message.content | map(select(type == "string") // .text // "") | join("\n")
                    end
                else
                    ""
                end
            ' 2>/dev/null)

            if [ -n "$msg_content" ] && [ "$msg_content" != "null" ]; then
                echo "**User:**"
                echo "$msg_content"
                echo ""
                echo "---"
                echo ""
            fi
        elif [ "$msg_type" = "assistant" ]; then
            text_content=$(echo "$line" | jq -r '
                if .message.content then
                    [.message.content[] | select(.type == "text") | .text] | join("\n\n")
                else
                    ""
                end
            ' 2>/dev/null)

            if [ -n "$text_content" ]; then
                echo "**Assistant:**"
                echo "$text_content"
                echo ""
                echo "---"
                echo ""
            fi
        fi
    done < "$TRANSCRIPT_PATH"

    echo ""
    echo "---"
    echo "*Auto-saved by VibeBackUp PreCompact hook*"
    echo "*Source: $(basename "$TRANSCRIPT_PATH")*"

} > "$SESSION_FILE"

LINE_COUNT=$(wc -l < "$SESSION_FILE" | tr -d ' ')
echo "Saved $LINE_COUNT lines to $SESSION_FILE"

# Rotate (keep max 5)
cd "${PROJECT_DIR}/.claude/sessions" 2>/dev/null || exit 0
TOTAL=$(ls -1 conversation-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL" -gt 5 ]; then
    TO_DELETE=$((TOTAL - 5))
    ls -1 conversation-*.md 2>/dev/null | sort -V | head -n "$TO_DELETE" | xargs rm -f 2>/dev/null || true
fi

echo "VibeBackUp: Done"
