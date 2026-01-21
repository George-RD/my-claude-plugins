---
name: prompt-patterns
description: This skill should be used when the user asks about "prompt optimization", "reducing prompt length", "avoiding prompt bloat", "effective prompts", "instruction budget", or needs guidance on writing clear, concise prompts that avoid common pitfalls.
---

# Prompt Optimization Patterns

## Overview

Effective prompts are concise, specific, and avoid common anti-patterns. This skill provides patterns for writing and improving prompts.

## Core Principles

### 1. Instruction Budget (~100 Instructions)

Keep total instructions under ~100 items. Beyond this, Claude may:
- Forget earlier instructions
- Conflate similar directives
- Miss edge cases

**Audit technique:** Count discrete instructions in CLAUDE.md and other config files.

### 2. Specificity Over Verbosity

**Bad:** "Make sure to handle errors appropriately and provide helpful feedback to users when something goes wrong."

**Good:** "On error: log to stderr, return error code, show user: 'Failed: {reason}'"

### 3. Eliminate Redundancy

Common redundancies to remove:
- "Please" and "kindly" (Claude will comply anyway)
- Restating the same instruction differently
- Obvious implications ("if X, do Y" when Y is already standard behavior)

## Anti-Patterns to Avoid

### Vague Qualifiers
- "regularly" → specify frequency
- "as needed" → specify conditions
- "when appropriate" → define criteria
- "properly" → define what proper means

### Instruction Creep
Each session shouldn't add new rules. Instead:
1. Review if issue was one-off
2. Check if existing instruction covers it
3. Consider if the fix generalizes

### Over-Specification
Don't instruct for obvious behavior:
- "Read files before editing" (Claude does this)
- "Use appropriate tools" (Claude selects tools)

## Compression Techniques

### Merge Similar Instructions

**Before:**
```
- Always use TypeScript
- Ensure type safety
- Add type annotations
- Use strict TypeScript mode
```

**After:**
```
- Use strict TypeScript with full type annotations
```

### Use Conditional Shorthand

**Before:**
```
If the file is a test file, run the test suite. If it's not a test file but is JavaScript, run the linter.
```

**After:**
```
Test files → run tests; JS files → lint
```

### Extract Patterns

If multiple instructions share logic, extract the pattern:

**Before:**
```
- For Python files, check PEP8
- For JavaScript files, check ESLint
- For TypeScript files, check ESLint
```

**After:**
```
- Run language-appropriate linter (Python: PEP8, JS/TS: ESLint)
```

## Measuring Prompt Effectiveness

### Clarity Score (1-10)
- Can someone unfamiliar understand it?
- Is there only one interpretation?
- Are success criteria clear?

### Density Score
- Instructions per 100 words
- Higher = more efficient
- Target: 3-5 instructions per 100 words

### Coverage Score
- Does it handle edge cases?
- Are failure modes addressed?
- Is scope clearly bounded?

## Quick Reference

| Pattern | Example |
|---------|---------|
| Specific trigger | "When X happens" not "if needed" |
| Measurable outcome | "Return JSON with {fields}" not "format nicely" |
| Bounded scope | "For .ts files in src/" not "for code" |
| Single responsibility | One instruction, one behavior |
| Fail-safe default | "Default to Y if unclear" |
