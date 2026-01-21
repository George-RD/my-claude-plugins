---
name: automem-usage
description: Use this skill when the user asks about memory, how to store memories, when to recall, memory tagging conventions, or how AutoMem works. Also use when you need guidance on using the AutoMem MCP tools effectively.
---

# Using AutoMem Memory System

You have access to persistent memory via AutoMem MCP tools. This skill explains when and how to use them effectively.

## Core Tools

- `store_memory` - Save important information for future recall
- `recall_memory` - Search and retrieve relevant memories
- `associate_memories` - Create relationships between memories
- `update_memory` - Modify existing memories
- `delete_memory` - Remove memories

## When to Store Memories

**Do store (importance 0.7-0.9):**
- Architectural decisions and rationale
- Bug fixes with root cause analysis
- User preferences learned during conversation
- Patterns discovered in codebase
- Feature implementations and approach taken

**Do NOT store:**
- Temporary debug output
- Credentials or secrets
- Large code blocks (store the pattern/decision instead)
- Duplicate information (recall first to check)

## When to Recall Mid-Conversation

Proactively recall when the user:
- Asks about past decisions ("how did we handle X before?")
- References previous work ("that auth system we built")
- Starts work that might have related context
- Mentions topics that span multiple projects

Example mid-conversation recall:
```
recall_memory({
  query: "authentication implementation patterns",
  limit: 5
})
```

## Memory Format

Keep content concise: **150-300 characters ideal**, max 500.

Format: "Brief title. Context and details. Impact/outcome."

## Tagging Conventions

Always include relevant tags for better recall:

| Tag Pattern | Purpose |
|-------------|---------|
| `repo:<name>` | Project-specific memories |
| `decision` | Architectural/design decisions |
| `bugfix` | Bug fixes with root cause |
| `preference` | User preferences |
| `pattern` | Recurring approaches |
| `code-style` | Coding conventions |

Example:
```
store_memory({
  content: "Chose PostgreSQL over MongoDB for user service. Need ACID for transactions, team has PostgreSQL expertise.",
  tags: ["repo:myproject", "decision", "database"],
  importance: 0.9
})
```

## Importance Scores

- **0.9+** - Critical decisions, major architectural choices
- **0.7-0.8** - Important patterns, significant bug fixes
- **0.5-0.6** - Standard context, minor preferences

## Session Handoffs

When ending a session with unfinished work, store a handoff:
```
store_memory({
  content: "Session handoff: Working on X feature. Next steps: 1) ... 2) ... Current blocker: ...",
  tags: ["session-handoff", "repo:current-project"],
  importance: 0.8
})
```

These are automatically recalled at the start of the next session.

## Relationship Types

Use `associate_memories` to link related memories:
- `RELATES_TO` - General relationship
- `LEADS_TO` - Causal (A caused B)
- `EVOLVED_INTO` - Updated version of concept
- `CONTRADICTS` - Conflicting information
- `REINFORCES` - Strengthens validity

## Best Practices

1. **Recall before storing** - Check for duplicates first
2. **Be specific** - "Fixed auth timeout with retry" not "fixed bug"
3. **Include rationale** - Why, not just what
4. **Tag consistently** - Use established patterns
5. **Don't over-store** - Quality over quantity
