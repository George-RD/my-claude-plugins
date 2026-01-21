---
name: iterate
description: Iterate on SOP based on real-world usage feedback
allowed-tools: ["Read", "Write", "Grep", "Glob", "Task", "AskUserQuestion"]
argument-hint: "[SOP path or title]"
---

# Iterate SOP Based on Feedback

Apply the PDCA (Plan-Do-Check-Act) cycle to improve an SOP based on actual usage.

**Process:**

1. **Locate SOP**
   - Find the SOP to iterate
   - Read current version

2. **Gather Usage Feedback (CHECK phase)**
   Ask user about real-world usage:
   - What worked well?
   - What caused confusion?
   - What steps were skipped or modified?
   - Any edge cases encountered?
   - Time/effort observations?

3. **Analyze Feedback (PLAN phase)**
   - Categorize feedback by type:
     - Process gaps
     - Clarity issues
     - Unnecessary steps
     - Missing edge cases
     - Role/responsibility confusion
   - Prioritize by impact

4. **Generate Iteration (DO phase)**
   - Apply specific improvements for each feedback item
   - Use `sop-drafter` for significant rewrites
   - Preserve what's working
   - Document rationale for changes

5. **Validate Changes (ACT phase)**
   - Run `sop-challenger` on updated version
   - Run `sop-validator` for compliance
   - Compare before/after
   - Update version and history

6. **Plan Next Iteration**
   - Set new review date
   - Note remaining improvements for future
   - Identify metrics to track

**PDCA Integration:**
```
┌─────────────────────────────────────────┐
│                 PLAN                     │
│  Analyze feedback, identify improvements │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│                  DO                      │
│  Implement specific changes              │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│                CHECK                     │
│  Validate changes, gather new feedback   │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│                 ACT                      │
│  Persist improvements, plan next cycle   │
└─────────────────────────────────────────┘
```

**Output:**
```markdown
## Iteration Report: [SOP Title]

### Feedback Analyzed
| Category | Feedback | Priority |
|----------|----------|----------|
| [type] | [feedback] | HIGH/MED/LOW |

### Changes Applied
| Section | Before | After | Rationale |
|---------|--------|-------|-----------|
| [section] | [old] | [new] | [why] |

### Version Update
- **From:** X.Y.Z
- **To:** X.Y.Z
- **Change Type:** [Major/Minor/Patch]

### Validation Results
- Challenger: [findings]
- Validator: [pass/issues]

### Next Iteration
- **Review Date:** YYYY-MM-DD
- **Metrics to Track:** [list]
- **Deferred Improvements:** [list]
```

**Kaizen Principle:**
Small, incremental improvements compound over time. Don't try to fix everything at once - prioritize highest-impact changes and iterate again later.
