# AutoMem Helper Plugin

Automatic memory context loading and usage guidance for AutoMem MCP.

## What It Does

1. **SessionStart Hook** - Automatically recalls relevant memories at the start of every Claude Code session:
   - Project-specific memories (based on current directory)
   - Session handoffs from previous work

2. **Usage Skill** - Provides guidance on how to effectively use AutoMem:
   - When to store vs recall
   - Tagging conventions
   - Importance scores
   - Memory format best practices

## Prerequisites

- AutoMem MCP server configured and running
- AutoMem tools permitted in Claude Code settings

## Installation

This plugin is in your local marketplace. Enable it in Claude Code settings:

```json
{
  "enabledPlugins": {
    "automem-helper@my_local_plugins": true
  }
}
```

## After Enabling

You can remove the AutoMem instructions from your global `~/.claude/CLAUDE.md` - this plugin handles it.

Also remove the manual SessionStart hook from `~/.claude/settings.json` if you have one:
```json
{
  "hooks": {
    "SessionStart": [...]  // Remove this section
  }
}
```

## Components

- `hooks/hooks.json` - SessionStart hook configuration
- `hooks/scripts/session-start.sh` - Memory recall prompt script
- `skills/automem-usage/SKILL.md` - Usage guidance skill
