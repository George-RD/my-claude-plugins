---
name: sop-best-practices
description: This skill should be used when the user asks about "SOP format", "SOP structure", "writing SOPs", "SOP frontmatter", "SOP versioning", "SOP review cycles", or needs guidance on creating effective Standard Operating Procedures.
---

# SOP Best Practices

## Overview

Standard Operating Procedures (SOPs) document repeatable processes. Effective SOPs are clear, actionable, and maintainable.

## Required Structure

### Frontmatter (YAML)

```yaml
---
title: "Process Name SOP"
version: "1.0.0"
status: draft | active | archived
owner: "Role or Name"
last_reviewed: YYYY-MM-DD
next_review: YYYY-MM-DD
tags: [category, department, workflow]
related_sops: [sop-filename-1, sop-filename-2]
---
```

### Required Sections

1. **Purpose** - Why this SOP exists (1-2 sentences)
2. **Scope** - What it covers and doesn't cover
3. **Prerequisites** - Required before starting
4. **Roles & Responsibilities** - Who does what
5. **Procedure** - Step-by-step instructions
6. **Verification** - How to confirm success
7. **Troubleshooting** - Common issues and fixes
8. **Version History** - Change log

## Writing Guidelines

### Procedure Steps

**Good step:**
```
3. Open the project file
   - Navigate to: Projects > Active > [Project Name]
   - File format: .prj
   - Verify: Header shows "Project loaded" status
```

**Bad step:**
```
3. Open the appropriate project file as needed
```

### Specificity Requirements

| Vague | Specific |
|-------|----------|
| "regularly" | "every Monday at 09:00" |
| "as needed" | "when X exceeds threshold Y" |
| "appropriate" | "matching criteria: [list]" |
| "quickly" | "within 30 seconds" |
| "properly" | "per specification [ref]" |

### Action Verbs

Use clear, unambiguous verbs:
- **Do:** Click, Select, Enter, Verify, Confirm, Navigate, Export
- **Avoid:** Ensure, Handle, Process, Manage (too vague)

## Versioning

### Semantic Versioning (X.Y.Z)

- **Major (X):** Process fundamentally changes
- **Minor (Y):** Steps added/removed, significant clarification
- **Patch (Z):** Typos, minor wording fixes

### Version History Format

```markdown
## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.1.0 | 2024-01-15 | J.Smith | Added verification step 5.3 |
| 1.0.1 | 2024-01-10 | J.Smith | Fixed typo in step 3 |
| 1.0.0 | 2024-01-01 | J.Smith | Initial release |
```

## Review Cycles

### Staleness Thresholds

| Days Since Review | Status |
|-------------------|--------|
| 0-30 | Current |
| 31-90 | Due Soon |
| 91-180 | Stale |
| >180 | Critical |

### Review Checklist

- [ ] All steps still accurate?
- [ ] Screenshots/references current?
- [ ] Tools/systems unchanged?
- [ ] Roles still valid?
- [ ] Any reported issues addressed?
- [ ] Edge cases documented?

## PDCA Integration

### Plan
- Identify improvement from feedback
- Define success criteria

### Do
- Update SOP with changes
- Test with actual workflow

### Check
- Gather user feedback
- Measure effectiveness

### Act
- Finalize changes
- Schedule next review

## Quality Checklist

Before marking SOP as active:

- [ ] Frontmatter complete (all required fields)
- [ ] No vague terms (regularly, as needed, etc.)
- [ ] Every step has verification criteria
- [ ] Troubleshooting covers common failures
- [ ] Roles clearly assigned
- [ ] Prerequisites testable
- [ ] Version history started
- [ ] Review date set
