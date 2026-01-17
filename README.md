# VibeBackUp

Context preservation system for Claude Code. Never lose your conversation history again.

## What It Does

VibeBackUp provides three skills for Claude Code that help you maintain context across sessions:

- **`/save-session`** — Manually save current session state
- **`/load-session`** — Restore context from a previous session
- **`/init-project`** — Initialize context management for a new project

Plus an automatic backup system that saves your conversation before context compaction.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Code Session                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Context fills up → PreCompact hook triggers            │
│                           ↓                              │
│              auto-save-session.sh runs                   │
│                           ↓                              │
│         transcript.jsonl copied to backup                │
│                           ↓                              │
│              Auto-compaction proceeds                    │
│                                                          │
├─────────────────────────────────────────────────────────┤
│                    New Session                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  User: /load-session                                     │
│                           ↓                              │
│  Claude reads transcript backup as extended memory       │
│                           ↓                              │
│  Full context available for continuation                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Features

- **Auto-backup before compaction** — Never lose context unexpectedly
- **Full transcript preservation** — 100% of conversation history saved
- **Session rotation** — Keeps last 5 sessions, auto-deletes older ones
- **Per-project storage** — Each project maintains its own session history
- **Extended memory** — Claude can reference transcripts without displaying them
- **Smart project detection** — Works from any directory, auto-finds your projects
- **Multi-project support** — Choose which project to load/save when multiple found

## Installation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

### Quick Start

```bash
# 1. Clone or copy to your Claude projects directory
cp -r VibeBackUp/.claude/skills/* ~/.claude/skills/
cp -r VibeBackUp/.claude/scripts ~/.claude/
cp VibeBackUp/.claude/settings.json ~/.claude/

# 2. Make script executable
chmod +x ~/.claude/scripts/auto-save-session.sh

# 3. Restart Claude Code

# 4. Initialize your project
cd your-project
/init-project
```

## Usage

### Starting a New Project

```
/init-project
```

Creates `.claude/` directory with:
- `SESSION.md` — Current session state template
- `PLAN.md` — Project plan template
- `sessions/` — Directory for saved sessions

### Saving Session Manually

```
/save-session
```

Use before:
- Taking a long break
- Switching to another project
- When you want a checkpoint

Save to specific project (when not in project directory):
```
/save-session /path/to/project
```

### Loading Previous Session

```
/load-session
```

Use when:
- Starting a new session after context was compacted
- Returning to a project after a break
- Need to recall what was discussed

**Smart project detection:**
- If in project directory → loads from that project
- If not → searches `~/Work*`, `~/Projects`, `~/Dev`, `~/Code`
- If multiple projects found → prompts you to choose

Load from specific project:
```
/load-session /path/to/project
```

Load a specific session:
```
/load-session 003
```

Load specific session from specific project:
```
/load-session /path/to/project 003
```

## Project Structure

```
your-project/
└── .claude/
    ├── SESSION.md          # Current session state
    ├── PLAN.md             # Project plan
    └── sessions/
        ├── session-001.md  # Session metadata
        ├── transcript-001.jsonl  # Full conversation backup
        ├── session-002.md
        └── transcript-002.jsonl
```

## How Auto-Backup Works

1. Claude Code's context fills up
2. Before auto-compaction, the `PreCompact` hook triggers
3. `auto-save-session.sh` copies `transcript.jsonl` to `.claude/sessions/`
4. Auto-compaction proceeds normally (creates summary)
5. You now have: summary in context + full backup in file

## Best Practices

1. **Use `/save-session` before breaks** — Don't rely only on auto-backup
2. **Run `/load-session` at session start** — Gives Claude access to history
3. **Keep SESSION.md updated** — Good for quick context, even without transcript
4. **Don't commit sessions/** — Add to `.gitignore` (contains conversation history)

## Limitations

- Auto-backup saves raw transcript, not structured summary
- Loading large transcripts uses context space
- Claude must know what to search for in transcript
- Works alongside (not replaces) built-in auto-compaction

## License

MIT — Use freely, modify as needed.

## Contributing

Issues and PRs welcome. This is a community tool for Claude Code users.
