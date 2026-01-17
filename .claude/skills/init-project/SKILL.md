---
name: init-project
description: Initialize project structure for context management. Creates .claude/ directory with SESSION.md, PLAN.md and sessions/ folder. Use when starting work on a new project or when /save-session fails due to missing directories.
allowed-tools: Bash, Write, Read
---

# Init Project

Initialize the context management structure for a new project.

## Instructions

When invoked, perform these steps:

### 1. Check if already initialized

```bash
ls -la .claude/ 2>/dev/null
```

If `.claude/SESSION.md` exists, ask user if they want to reinitialize (will overwrite).

### 2. Create directory structure

```bash
mkdir -p .claude/sessions
```

### 3. Create SESSION.md

Write `.claude/SESSION.md`:

```markdown
# Session State — YYYY-MM-DD

## Current Task
[Describe the current task or goal]

## Completed
- [List completed items]

## In Progress
- [List items currently being worked on]

## Key Files
- [List important files in the project]

## Architecture Decisions
- [Document important decisions made]

## Next Steps
1. [First next step]
2. [Second next step]
```

### 4. Create PLAN.md

Write `.claude/PLAN.md`:

```markdown
# Project Plan

## Goal
[Main objective of the project]

## Tasks

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 3
- [ ] Task 4

## Questions
- [Open questions to resolve]

## Notes
- [Important notes and context]
```

### 5. Add to .gitignore (optional)

Check if `.gitignore` exists and if `.claude/sessions/` should be ignored:

```bash
if [ -f .gitignore ]; then
  grep -q ".claude/sessions/" .gitignore || echo ".claude/sessions/" >> .gitignore
fi
```

Sessions contain conversation history — usually shouldn't be committed.

### 6. Confirm to user

Report:
```
Project initialized:
├── .claude/
│   ├── SESSION.md   ← current session state
│   ├── PLAN.md      ← project plan
│   └── sessions/    ← saved sessions (in .gitignore)

Ready to use:
- /save-session — save current context
- /load-session — restore previous context
```

## Arguments

- `$ARGUMENTS` can include project name or description to pre-fill templates
