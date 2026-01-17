# Installation Guide

## Prerequisites

- Claude Code CLI installed and working
- macOS or Linux (Windows WSL should work but untested)

## Installation Options

### Option A: Global Installation (Recommended)

Install skills globally so they're available in all projects.

```bash
# 1. Create directories if they don't exist
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/scripts

# 2. Copy skills
cp -r WibeBackUp/.claude/skills/* ~/.claude/skills/

# 3. Copy auto-save script
cp WibeBackUp/.claude/scripts/auto-save-session.sh ~/.claude/scripts/

# 4. Make script executable
chmod +x ~/.claude/scripts/auto-save-session.sh

# 5. Add hook configuration
# If you don't have ~/.claude/settings.json, copy the template:
cp WibeBackUp/.claude/settings.json ~/.claude/settings.json

# If you already have settings.json, merge the hooks section manually
```

### Option B: Per-Project Installation

Install only for a specific project.

```bash
cd your-project

# 1. Create directories
mkdir -p .claude/skills
mkdir -p .claude/scripts

# 2. Copy skills
cp -r /path/to/WibeBackUp/.claude/skills/* .claude/skills/

# 3. Copy script and settings
cp /path/to/WibeBackUp/.claude/scripts/auto-save-session.sh .claude/scripts/
cp /path/to/WibeBackUp/.claude/settings.json .claude/

# 4. Make executable
chmod +x .claude/scripts/auto-save-session.sh
```

## Configuration

### settings.json

The `settings.json` file configures the PreCompact hook:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/auto-save-session.sh"
          }
        ]
      }
    ]
  }
}
```

**Important:** Update the path to match your installation:

- Global: `~/.claude/scripts/auto-save-session.sh`
- Per-project: `.claude/scripts/auto-save-session.sh`

### Merging with Existing Settings

If you already have a `settings.json`, add the PreCompact hook to your existing hooks:

```json
{
  "hooks": {
    "YourExistingHook": [...],
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/auto-save-session.sh"
          }
        ]
      }
    ]
  }
}
```

## Verification

After installation, restart Claude Code and verify:

```bash
# 1. Start Claude Code
claude

# 2. Check skills are available
/init-project
```

If skills aren't recognized, ensure:
- Skills are in correct directory (`~/.claude/skills/` or `.claude/skills/`)
- Each skill has proper structure: `skill-name/SKILL.md`
- Claude Code was restarted after installation

## Gitignore

Add to your project's `.gitignore`:

```
# WibeBackUp session files (contain conversation history)
.claude/sessions/
```

## Troubleshooting

### Skills not found

```
Unknown skill: save-session
```

- Verify skill directory structure
- Restart Claude Code
- Check skill is in correct location

### Auto-save not working

Test the script manually:

```bash
cd your-project
~/.claude/scripts/auto-save-session.sh
```

Check:
- Script is executable (`chmod +x`)
- Path in settings.json is correct
- Hook configuration is valid JSON

### Transcript not found

The auto-save script looks for transcript in several locations:
- `$CLAUDE_TRANSCRIPT_PATH` (set by hook)
- `.claude/transcript.jsonl`
- `~/. claude/transcript.jsonl`

If none found, only a marker file is created.

## Uninstallation

```bash
# Global
rm -rf ~/.claude/skills/save-session
rm -rf ~/.claude/skills/load-session
rm -rf ~/.claude/skills/init-project
rm ~/.claude/scripts/auto-save-session.sh
# Remove PreCompact hook from ~/.claude/settings.json

# Per-project
rm -rf .claude/skills
rm -rf .claude/scripts
rm .claude/settings.json
```
