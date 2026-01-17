---
name: save-session
description: Save current session state to .claude/sessions/ for context preservation. Use when user says /save-session, before clearing context, or when context is running low.
allowed-tools: Read, Write, Bash, Glob
---

# Save Session

Save the current session state to preserve context across session boundaries.

## Instructions

When invoked, perform these steps:

### 1. Ensure directory exists

```bash
mkdir -p .claude/sessions
```

### 2. Determine next session number

```bash
ls -1 .claude/sessions/session-*.md 2>/dev/null | sort -V | tail -1
```

If no files exist, start with `session-001.md`. Otherwise increment the highest number.

### 3. Create session file

Write to `.claude/sessions/session-XXX.md` with this format:

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

### 4. Rotate old sessions (keep max 5)

If there are more than 5 session files:
```bash
cd .claude/sessions && ls -1 session-*.md | sort -V | head -n -5 | xargs rm -f
```

### 5. Update SESSION.md

Update `.claude/SESSION.md` to reflect the saved state.

### 6. Confirm to user

Report:
- Session saved to: `.claude/sessions/session-XXX.md`
- Total sessions: N
- Oldest session removed (if rotation happened)

## Important

- Gather information from the CURRENT conversation, not from files
- Include specific file paths and line numbers where relevant
- Be concise but complete
- Focus on information needed to continue work seamlessly
