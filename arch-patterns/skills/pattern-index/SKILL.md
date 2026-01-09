---
name: pattern-index
description: Lightweight reference for recognizing when a design pattern might help solve a specific problem
---

# Pattern Index

A lightweight reference for recognizing when a pattern *might* help. Don't reach for these proactively - use them when you feel specific pain.

## When to Use This Index

- You have a specific problem and wonder if there's a known solution
- You want to name something you're already doing
- You're considering a pattern and want to sanity-check if it fits

## Quick Lookup: What Pain Are You Feeling?

### "I need to undo/redo actions"
→ **Command** - Reify actions as objects. Store history. Replay or reverse.

### "I have thousands of similar objects eating memory"
→ **Flyweight** - Share the parts that are identical. Keep instance-specific data separate.

### "Changes in one place should notify other places"
→ **Observer** - Let objects subscribe to events. Sender doesn't know receivers.

### "My if/else chains for state are getting tangled"
→ **State** - Each state becomes an object with its own behavior. Clean transitions.

### "This class does too many unrelated things"
→ **Component** - Split into focused pieces. Compose entities from parts.

### "I keep recalculating things that haven't changed"
→ **Dirty Flag** - Mark when source data changes. Only recalculate when needed.

### "Creating/destroying objects is hurting performance"
→ **Object Pool** - Reuse objects instead of allocating new ones.

### "I need global access but Singletons feel wrong"
→ **Service Locator** - Central registry with abstract interfaces. Swappable.

### "Events are blocking when they should be async"
→ **Event Queue** - Decouple when events are sent from when they're processed.

### "Many subclasses need similar capabilities"
→ **Subclass Sandbox** - Base class provides safe primitives. Subclasses compose them.

### "I need many variations without class explosion"
→ **Type Object** - Data-driven types. Load variations from config.

### "Finding nearby objects is O(n²) slow"
→ **Spatial Partition** - Organize by location. Query only relevant areas.

## Before You Apply Any Pattern

Ask yourself:

1. **Do I feel this pain right now, or am I guessing I might?**
2. **Would the pattern make the code simpler to understand?**
3. **What's the simplest thing that could work instead?**

If you're not sure, try the simple thing first. You can always add the pattern later when the need is clear.

## Getting Pattern Details

**Available as focused skills** (ask by name):
- Command, Observer, State, Component, Dirty Flag

**Available in deep reference** (for other patterns):
- Flyweight, Object Pool, Service Locator, Event Queue, Subclass Sandbox, Type Object, Spatial Partition
- Read from `references/full-catalog/` when needed

---

*Remember: patterns are tools for specific problems, not goals in themselves.*
