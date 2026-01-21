# AutoMem Helper - Proposed Improvements

## Context

Discussion from 2026-01-21 about improving the automem-helper plugin.

## Current State

- **SKILL.md** has good guidance on when to store/recall memories
- **SessionStart hook** recalls project context and session handoffs
- **Global CLAUDE.md** duplicates some guidance (could consolidate)
- **No PreCompact hook** exists

## Proposed Changes

### 1. PreCompact Hook for Saving Key Memories

Add a `PreCompact` hook that prompts Claude to review the session and save important context BEFORE compaction loses it.

**Should save:**
- Decisions with rationale
- Bug root causes discovered
- User preferences learned
- Patterns worth remembering

**Should NOT save:**
- Ephemeral discussion ("we talked about X")
- Session continuation info (that's separate — see handoffs)
- Temporary debug output
- Duplicates of existing memories

**Key principle**: Curated quality memories, not a dump of everything.

### 2. Session Handoff Consumption

**Problem**: Session handoffs are stored with `["session-handoff"]` tag and recalled at session start, but never marked as consumed. This could cause repeated handoffs.

**Proposed solution**: Use metadata to track consumption state.

```javascript
// When storing handoff:
store_memory({
  content: "Session handoff: Working on X...",
  tags: ["session-handoff", "repo:myproject"],
  importance: 0.8,
  metadata: { consumed: false }
})

// After successful recall in new session:
update_memory({
  memory_id: "<id>",
  metadata: { consumed: true, consumed_at: "2026-01-21T..." }
})
```

**Alternative approaches considered:**

| Approach | Pros | Cons |
|----------|------|------|
| Delete after recall | Clean, simple | Loses history |
| Metadata `consumed: true` | Preserves history, queryable | Requires logic change |
| Importance decay | Auto-fades | Less explicit |
| Rename tag | Clear state | Manual step |

### 3. Consolidate Guidance

Make the plugin's SKILL.md the single source of truth for AutoMem usage, rather than duplicating in global CLAUDE.md.

## Implementation Plan

1. Add `PreCompact` hook to `hooks/hooks.json`
2. Create `hooks/scripts/pre-compact.sh` with prompt for memory review
3. Update `hooks/scripts/session-start.sh` to mark handoffs as consumed
4. Update SKILL.md with handoff consumption guidance
5. Optionally: Simplify global CLAUDE.md to reference the plugin

## Status

**Not yet implemented** — saved for future work.
