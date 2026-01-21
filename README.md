# My Claude Plugins

A collection of custom plugins for [Claude Code](https://github.com/anthropics/claude-code).

## Plugins

### arch-patterns
Architecture analysis plugin using 20 proven design patterns from Game Programming Patterns. Analyzes codebases, identifies anti-patterns, and provides recommendations for TypeScript/JavaScript projects.

### automem-helper
Automatic memory context loading and usage guidance for AutoMem MCP integration. Includes SessionStart hook for repo-specific recall.

### research-framework
Hierarchical research framework using sub-agents for gathering, analyzing, planning, and validating research on any topic.

### self-improver
Analyzes conversations to detect inefficiencies and suggest prompt improvements. Uses tiered model routing with credit safeguards.

### sop-manager
Creates, maintains, and iterates on SOPs (Standard Operating Procedures) using multi-agent workflows. Integrates with Obsidian vaults.

## Installation

### As a Marketplace (recommended)

1. Clone to your marketplaces directory:
   ```bash
   git clone https://github.com/George-RD/my-claude-plugins.git ~/.claude/plugins/marketplaces/my-claude-plugins
   ```

2. Restart Claude Code - plugins will be available for installation via the plugin manager.

### Manual Installation

1. Clone this repo:
   ```bash
   git clone https://github.com/George-RD/my-claude-plugins.git
   ```

2. Symlink individual plugins:
   ```bash
   ln -s /path/to/my-claude-plugins/arch-patterns ~/.claude/plugins/arch-patterns
   ```

3. Restart Claude Code.

## License

MIT
