# arch-patterns

A plugin for thinking about code architecture - not to add complexity, but to find simplicity.

## Philosophy

> *"I try very hard to write the cleanest, most direct solution to the problem. The kind of code where after you read it, you understand exactly what it does and can't imagine any other possible solution."*
>
> — Robert Nystrom, Game Programming Patterns

This plugin embodies the wisdom from the [Game Programming Patterns](https://gameprogrammingpatterns.com/) introduction: good architecture minimizes how much you need to hold in your head to make a change.

**It's not about patterns. It's about simplicity.**

Patterns are tools for specific problems - not goals in themselves. This plugin helps you:
- Reflect on whether your code is genuinely easy to work with
- Find the simplest solution before reaching for abstractions
- Learn patterns when you actually need them

## How It Works

### Progressive Context

The plugin doesn't dump 20 patterns into your context. Instead:

1. **Philosophy skill** (~400 words) - Always relevant. Asks the right questions.
2. **Pattern index** (~200 words) - Lightweight lookup. Symptom → pattern name.
3. **Individual patterns** (~300 words each) - Load on demand when you need details.

### Gentle Guidance

A lightweight hook after code changes that asks (silently, unless something stands out):
- Did this make things simpler or more complex?
- If abstraction was added, is it earning its keep?

It stays quiet when things look good.

## Agents

| Agent | Purpose | Tone |
|-------|---------|------|
| **Architecture Reflection** | Explore how code feels to work with | Thinking partner, not critic |
| **Simplicity Guide** | Evaluate whether to add complexity | Skeptical of abstraction |
| **Architecture Notes** | Capture insights for the team | Practical, not formal |

## Usage

### Ask About Architecture
```
"Is this code well-architected?"
"This feels hard to change - what's going on?"
"Should I add an abstraction here?"
```

### Look Up a Pattern
```
"Tell me about the Command pattern"
"When would I use Observer?"
"Show me the State pattern in TypeScript"
```

### Reflect After Changes
The hook quietly considers each code change. It only speaks up if something seems worth reflecting on.

## What This Plugin Won't Do

- Tell you your code is bad
- Suggest patterns you don't need
- Generate formal documentation
- Make you feel inadequate for not knowing 20 patterns

## The Core Questions

These matter more than any pattern:

1. **How much do I need to hold in my head to make this change?**
2. **Could this be simpler?**
3. **Am I solving today's problem or guessing about tomorrow's?**

## Structure

```
skills/                           # Auto-loads as context (~811 lines total)
  philosophy/SKILL.md             # Core thinking (92 lines) - always relevant
  pattern-index/SKILL.md          # Symptom → pattern lookup (70 lines)
  patterns/
    command/SKILL.md              # On-demand (~100 lines each)
    observer/SKILL.md
    component/SKILL.md
    state/SKILL.md
    dirty-flag/SKILL.md

references/                       # NOT auto-loaded - explicit Read only
  full-catalog/                   # Complete pattern implementations (2,268 lines)
    SKILL.md                      # All 20 patterns
    references/                   # Detailed TypeScript examples

agents/                           # Trigger naturally through conversation
  pattern-analyzer.md             # → Architecture Reflection
  pattern-recommender.md          # → Simplicity Guide
  report-generator.md             # → Architecture Notes

hooks/
  hooks.json                      # Gentle post-edit guidance
```

**No explicit commands.** The plugin works through natural conversation and gentle hooks - not audits you have to remember to run.

### Context Management

| Scenario | Context Loaded |
|----------|----------------|
| Normal coding | Philosophy only (~92 lines) |
| Ask about patterns | + Pattern index (~70 lines) |
| Need specific pattern | + One pattern skill (~100 lines) |
| Deep implementation dive | Explicit Read from references/ |

**Maximum active context: ~312 lines** (vs 2,268 if everything loaded)

## Credits

Pattern knowledge from [Game Programming Patterns](https://gameprogrammingpatterns.com/) by Robert Nystrom.

The introduction chapter is required reading - it's more valuable than any individual pattern.

## License

MIT
