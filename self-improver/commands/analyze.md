---
name: analyze
description: Analyze conversation for inefficiencies and improvement opportunities
allowed-tools: ["Read", "Grep", "Glob", "Task"]
argument-hint: "[session-id or 'last']"
---

# Analyze Conversation for Improvements

You are running the self-improver analysis workflow.

**Process:**

1. **Identify Target Session**
   - If argument is "last" or empty, analyze the most recent completed session
   - If a session ID is provided, analyze that specific session
   - Look in `.claude/self-improver/logs/` for session data

2. **Run Screening Pass**
   - Launch the `conversation-screener` agent (Haiku) via Task tool
   - Wait for screening report with efficiency score and flagged issues

3. **Evaluate Escalation**
   - If screener recommends escalation (severity 7+):
     - Launch `prompt-investigator` agent (Opus) for deep analysis
   - If no escalation needed:
     - Report findings and exit

4. **Generate Recommendations**
   - Compile improvement suggestions from all agents
   - Save recommendations to `.claude/self-improver/suggestions/`

5. **Report to User**
   - Summarize findings
   - List actionable improvements with priority
   - Show estimated impact and cost

**Output Format:**
```markdown
## Analysis Report

**Session:** [ID]
**Efficiency Score:** X/10
**Issues Found:** N (N critical, N high, N medium)

### Key Findings
1. [Finding with evidence]
2. [Finding with evidence]

### Recommendations
| Priority | Improvement | Expected Impact |
|----------|-------------|-----------------|
| HIGH | [improvement] | [impact] |

### Next Steps
- [ ] Review recommendation #1
- [ ] Approve/reject improvements
- [ ] Run `/self-improver:status` to track

**Cost:** Haiku: $X.XX | Sonnet: $X.XX | Opus: $X.XX
```

**Cost Awareness:**
- Always start with Haiku screening
- Only use Opus if issues warrant deep investigation
- Report cost breakdown to user
