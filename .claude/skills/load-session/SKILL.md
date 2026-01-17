---
name: load-session
description: Load previous session context from .claude/sessions/. Use at the start of a new session to continue previous work, or when context was compacted.
allowed-tools: Read, Glob, Bash
---

# Load Session

Restore context from a previously saved session.

## Instructions

### 1. Find available sessions

```bash
ls -la .claude/sessions/
```

### 2. Identify latest session

Find the highest numbered `session-XXX.md` and corresponding `transcript-XXX.jsonl`.

### 3. Read session marker

Read `session-XXX.md` for metadata (timestamp, notes).

### 4. Reference transcript for context

**IMPORTANT:** The transcript is YOUR memory, not output for the user.

- Note the path to `transcript-XXX.jsonl`
- When you need context about previous work — READ the transcript
- Use it to remember what was discussed, decisions made, current state

The transcript is JSONL format, each line is a JSON object with conversation turns.

### 5. Read state files

Read if they exist:
- `.claude/SESSION.md` — current session state
- `.claude/PLAN.md` — current plan
- `CLAUDE.md` — project instructions

### 6. Brief confirmation to user

Tell the user briefly:
```
Context loaded from session-XXX (YYYY-MM-DD).
I have access to previous conversation history.
Ready to continue — what would you like to work on?
```

Do NOT dump the transcript contents. Just confirm you have access.

## Key Principle

The transcript is YOUR extended memory:
- Remember what was discussed
- Recall decisions made
- Understand current state of work
- Continue tasks seamlessly

When user asks about something from previous session — read relevant parts of transcript to answer.

## Arguments

- No arguments: Load most recent session
- `$ARGUMENTS` can specify number: `/load-session 003` loads session-003
