---
name: status
description: View improvement suggestions, metrics, and credit usage
allowed-tools: ["Read", "Grep", "Glob"]
---

# Self-Improver Status Dashboard

Display the current state of self-improvement tracking.

**Process:**

1. **Load Configuration**
   - Read `.claude/self-improver/config.json` for settings
   - Check credit limits and current usage

2. **Gather Metrics**
   - Count sessions analyzed
   - Count improvements suggested vs accepted
   - Calculate acceptance rate
   - Track efficiency trends

3. **List Pending Suggestions**
   - Read `.claude/self-improver/suggestions/` directory
   - Show pending improvements awaiting review
   - Display priority and expected impact

4. **Credit Usage Report**
   - Haiku calls today/limit
   - Sonnet calls today/limit
   - Opus calls this week/limit
   - Estimated remaining budget

5. **Display Dashboard**

**Output Format:**
```markdown
## Self-Improver Status

### Metrics (Last 30 Days)
| Metric | Value | Trend |
|--------|-------|-------|
| Sessions Analyzed | N | ↑↓→ |
| Issues Detected | N | ↑↓→ |
| Improvements Suggested | N | ↑↓→ |
| Improvements Accepted | N | ↑↓→ |
| Acceptance Rate | X% | ↑↓→ |

### Efficiency Improvement
- **Avg turns before:** X.X
- **Avg turns after:** X.X
- **Improvement:** X%

### Pending Suggestions
| ID | Priority | Summary | Impact |
|----|----------|---------|--------|
| 1 | HIGH | [summary] | +X% efficiency |

### Credit Usage
| Model | Today | Limit | Remaining |
|-------|-------|-------|-----------|
| Haiku | N | 100 | N |
| Sonnet | N | 20 | N |
| Opus | N/week | 5 | N |

**Budget Status:** [OK / Warning / At Limit]

### Quick Actions
- `/self-improver:analyze` - Run new analysis
- Review pending suggestion: [command]
```

**If No Data:**
Display setup instructions if self-improver hasn't collected data yet.
