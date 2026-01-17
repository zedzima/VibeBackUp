---
name: load-session
description: Load previous session context from .claude/sessions/. Use at the start of a new session to continue previous work, or when context was compacted.
allowed-tools: Read, Glob, Bash, AskUserQuestion
---

# Load Session

Restore context from a previously saved session.

## Instructions

### 1. Determine project directory

**Priority order:**

1. **Argument is a path** — if `$ARGUMENTS` looks like a path (contains `/`), use it as project directory
2. **Current directory has `.claude/sessions/`** — use current directory
3. **Search for projects** — find all directories with `.claude/sessions/` and let user choose

**For option 3, search in these locations:**
```bash
find ~/Work* ~/Projects ~/Dev ~/Code -maxdepth 3 -type d -name ".claude" 2>/dev/null | while read d; do
  if [ -d "$d/sessions" ]; then
    echo "$(dirname "$d")"
  fi
done
```

If multiple projects found, use AskUserQuestion to let user select which project to load.

### 2. Find available sessions

Once project directory is determined (`$PROJECT_DIR`):

```bash
ls -la "$PROJECT_DIR/.claude/sessions/"
```

### 3. Identify latest session

- If `$ARGUMENTS` is a number (e.g., `003`), load that specific session
- Otherwise, find the highest numbered `session-XXX.md`

### 4. Read session marker

Read `session-XXX.md` for metadata (timestamp, notes).

### 5. Reference transcript for context

**IMPORTANT:** The transcript is YOUR memory, not output for the user.

- Note the path to `transcript-XXX.jsonl` if it exists
- When you need context about previous work — READ the transcript
- Use it to remember what was discussed, decisions made, current state

The transcript is JSONL format, each line is a JSON object with conversation turns.

### 6. Read state files

Read if they exist in `$PROJECT_DIR`:
- `.claude/SESSION.md` — current session state
- `.claude/PLAN.md` — current plan
- `CLAUDE.md` — project instructions

### 7. Brief confirmation to user

Tell the user briefly:
```
Context loaded from session-XXX (YYYY-MM-DD) in [project-name].
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

- No arguments: Auto-detect project or show selection
- Path (e.g., `/path/to/project`): Load from specific project
- Number (e.g., `003`): Load specific session number from detected project
- Both (e.g., `/path/to/project 003`): Load specific session from specific project
