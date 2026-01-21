---
name: review
description: Audit and review an SOP or the entire vault
allowed-tools: ["Read", "Grep", "Glob", "Task"]
argument-hint: "[SOP path, title, or 'all']"
---

# Review SOPs

Audit SOPs for quality, staleness, and compliance.

**Process:**

1. **Determine Scope**
   - Single SOP: path or title provided
   - All SOPs: argument is "all" or empty
   - By status: "active", "draft", "stale"

2. **For Single SOP Review:**
   - Run `sop-validator` for structural compliance
   - Run `sop-challenger` for content quality
   - Check staleness (days since review date)
   - Generate detailed report

3. **For Vault-Wide Review:**
   - Scan SOP directories for all .md files with SOP frontmatter
   - Run `sop-validator` on each (batch mode)
   - Identify stale SOPs (>90 days since review)
   - Identify SOPs with validation errors
   - Generate summary report

4. **Staleness Analysis:**
   | Days Past Review | Status |
   |-----------------|--------|
   | 0-30 | Current |
   | 31-90 | Due Soon |
   | 91-180 | Stale |
   | >180 | Critical |

5. **Generate Report**

**Single SOP Output:**
```markdown
## SOP Review: [Title]

### Compliance Check
| Check | Status | Details |
|-------|--------|---------|
| Frontmatter | ✅/❌ | [issues] |
| Required Sections | ✅/❌ | [issues] |
| Banned Terms | ✅/❌ | [terms found] |
| Formatting | ✅/❌ | [issues] |

### Quality Assessment (Challenger)
**Score:** X/10
**Critical Issues:** N
**Gaps Identified:** [list]

### Staleness
- **Last Review:** YYYY-MM-DD
- **Days Overdue:** N
- **Status:** [Current/Due/Stale/Critical]

### Recommendations
1. [Priority action]
2. [Secondary action]
```

**Vault-Wide Output:**
```markdown
## SOP Vault Review

**Total SOPs:** N
**Active:** N | **Draft:** N | **Archived:** N

### Health Summary
| Status | Count | % |
|--------|-------|---|
| Healthy | N | X% |
| Needs Attention | N | X% |
| Critical | N | X% |

### Stale SOPs (Action Required)
| SOP | Days Overdue | Owner |
|-----|--------------|-------|
| [title] | N | [owner] |

### Validation Failures
| SOP | Issue | Severity |
|-----|-------|----------|
| [title] | [issue] | HIGH/MED |

### Recommended Actions
1. [Highest priority action]
2. [Next priority]
```
