---
name: save-session
description: Save current session state to .claude/sessions/ for context preservation. Use when user says /save-session, before clearing context, or when context is running low.
allowed-tools: Read, Write, Bash, Glob, AskUserQuestion
---

# Save Session

Save the current session state to preserve context across session boundaries.

## Instructions

When invoked, perform these steps:

### 1. Determine project directory

**Priority order:**

1. **Argument is a path** — if `$ARGUMENTS` looks like a path (contains `/`), use it as project directory
2. **Current directory has `.claude/` or `CLAUDE.md`** — use current directory
3. **Search for projects** — find all directories with `.claude/` and let user choose

**For option 3, search in these locations:**
```bash
find ~/Work* ~/Projects ~/Dev ~/Code -maxdepth 3 -type d -name ".claude" 2>/dev/null | while read d; do
  echo "$(dirname "$d")"
done
```

If multiple projects found, use AskUserQuestion to let user select which project to save to.

### 2. Ensure directory exists

```bash
mkdir -p "$PROJECT_DIR/.claude/sessions"
```

### 3. Determine next session number

```bash
ls -1 "$PROJECT_DIR/.claude/sessions/session-"*.md 2>/dev/null | sort -V | tail -1
```

If no files exist, start with `session-001.md`. Otherwise increment the highest number.

### 4. Create session file

Write to `$PROJECT_DIR/.claude/sessions/session-XXX.md` with this format:

```markdown
# Session — YYYY-MM-DD HH:MM

## Summary
Brief description of what was accomplished in this session.

## Completed Tasks
- Task 1 — what was done
- Task 2 — what was done

## In Progress
- Current task being worked on
- Any blockers or issues

## Key Decisions
- Important architectural or design decisions made
- Reasons for those decisions

## Modified Files
- `path/to/file.py` — what changed
- `path/to/other.html` — what changed

## Next Steps
1. First thing to do next
2. Second thing to do next

## Context for Continuation
Any important context needed to continue work in a new session.
```

### 5. Rotate old sessions (keep max 5)

If there are more than 5 session files:
```bash
cd "$PROJECT_DIR/.claude/sessions" && ls -1 session-*.md | sort -V | head -n -5 | xargs rm -f
```

### 6. Update SESSION.md

Update `$PROJECT_DIR/.claude/SESSION.md` to reflect the saved state.

### 7. Confirm to user

Report:
- Project: `$PROJECT_DIR`
- Session saved to: `.claude/sessions/session-XXX.md`
- Total sessions: N
- Oldest session removed (if rotation happened)

## Arguments

- No arguments: Auto-detect project or show selection
- Path (e.g., `/path/to/project`): Save to specific project

## Important

- Gather information from the CURRENT conversation, not from files
- Include specific file paths and line numbers where relevant
- Be concise but complete
- Focus on information needed to continue work seamlessly
