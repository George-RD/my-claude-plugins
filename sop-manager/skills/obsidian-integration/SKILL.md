---
name: obsidian-integration
description: This skill should be used when the user asks about "Obsidian vault", "SOP organization", "linking SOPs", "SOP templates", "vault structure", or needs guidance on organizing SOPs within an Obsidian knowledge base.
---

# Obsidian Integration for SOPs

## Overview

SOPs stored in Obsidian benefit from linking, tagging, and graph visualization. This skill covers organization patterns.

## Vault Structure

### Recommended Layout

```
vault/
├── SOPs/
│   ├── Active/
│   │   ├── department-process-name.md
│   │   └── ...
│   ├── Draft/
│   │   └── wip-process-name.md
│   ├── Archive/
│   │   └── deprecated-process-name.md
│   └── Templates/
│       ├── sop-template.md
│       └── checklist-template.md
├── Projects/
│   └── [project-specific SOPs]
└── Resources/
    └── [reference materials]
```

### File Naming Convention

```
[department]-[process-name].md
```

Examples:
- `charting-navigation-chart-creation.md`
- `charting-client-deliverable-review.md`
- `survey-rov-pre-deployment.md`

## Obsidian Features for SOPs

### Internal Links

Link related SOPs:
```markdown
Related procedures:
- [[charting-quality-check]]
- [[survey-data-validation]]
```

### Tags

Use consistent tag hierarchy:
```yaml
tags:
  - sop/charting
  - sop/client-deliverable
  - status/active
  - review/q1-2024
```

### Dataview Queries

Track SOP status across vault:

```dataview
TABLE status, owner, next_review
FROM "SOPs/Active"
WHERE status = "active"
SORT next_review ASC
```

Find stale SOPs:
```dataview
TABLE title, last_reviewed,
  (date(today) - last_reviewed).days AS "Days Since Review"
FROM "SOPs"
WHERE status = "active"
  AND (date(today) - last_reviewed).days > 90
```

### Graph View

Use graph view to visualize SOP relationships:
- Clusters indicate related processes
- Orphan nodes may need linking
- Central nodes are critical dependencies

## Templates

### SOP Template (Obsidian format)

Create `Templates/sop-template.md`:

```markdown
---
title: "{{title}}"
version: "1.0.0"
status: draft
owner: ""
created: {{date}}
last_reviewed: {{date}}
next_review:
tags: [sop]
related_sops: []
---

## Purpose

[Why this procedure exists]

## Scope

**Applies to:** [contexts]
**Does not apply to:** [exclusions]

## Prerequisites

- [ ] [Prerequisite 1]
- [ ] [Prerequisite 2]

## Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| [Role] | [What they do] |

## Procedure

### Step 1: [Action]

1. [Specific instruction]
   - Detail: [specifics]
   - Verify: [how to confirm]

### Step 2: [Action]

[Continue pattern...]

## Verification

- [ ] [Verification item 1]
- [ ] [Verification item 2]

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| [Problem] | [Why] | [Fix] |

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | {{date}} | | Initial draft |
```

### Checklist Template

For quick-reference procedures:

```markdown
---
title: "{{title}} Checklist"
version: "1.0.0"
status: draft
parent_sop: "[[parent-sop]]"
tags: [checklist]
---

# {{title}} Checklist

**Parent SOP:** [[parent-sop]]

## Pre-Start
- [ ] Item 1
- [ ] Item 2

## Execution
- [ ] Item 1
- [ ] Item 2

## Completion
- [ ] Item 1
- [ ] Item 2

## Sign-Off
- **Completed by:**
- **Date:**
- **Notes:**
```

## Workflow Integration

### Creating New SOPs

1. Use template: `Ctrl/Cmd + T` → select sop-template
2. Fill frontmatter immediately
3. Draft in `SOPs/Draft/`
4. Link to related SOPs
5. Move to `SOPs/Active/` when approved

### Review Workflow

1. Use Dataview to find due SOPs
2. Open SOP and related links
3. Update content
4. Increment version
5. Update `last_reviewed` and `next_review`

### Archiving

1. Move to `SOPs/Archive/`
2. Change status to `archived`
3. Add note explaining deprecation
4. Update any linking SOPs
