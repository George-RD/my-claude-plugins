---
name: improve
description: Improve an existing SOP based on feedback or analysis
allowed-tools: ["Read", "Write", "Grep", "Glob", "Task", "AskUserQuestion"]
argument-hint: "[SOP path or title]"
---

# Improve Existing SOP

Enhance an SOP based on feedback, usage data, or identified issues.

**Process:**

1. **Locate SOP**
   - If path provided, read directly
   - If title provided, search vault for matching SOP
   - If no argument, ask user which SOP to improve

2. **Understand Current State**
   - Read the existing SOP
   - Check version history
   - Note any existing issues flagged

3. **Gather Improvement Input**
   Ask user for improvement context:
   - What prompted this improvement?
   - Specific sections to focus on?
   - Feedback from users?
   - Issues encountered?

4. **Analyze Current SOP**
   - Run `sop-challenger` to identify existing gaps
   - Run `sop-validator` to check compliance
   - Note areas needing improvement

5. **Generate Improvements**
   - Use `sop-drafter` to rewrite problem sections
   - Maintain what works well
   - Address specific feedback

6. **Version Management**
   - Increment version number appropriately:
     - Patch (0.0.X): Minor fixes, typos
     - Minor (0.X.0): Section improvements, clarifications
     - Major (X.0.0): Significant process changes
   - Update version history with change summary
   - Keep previous version in Archive if major change

7. **Validate Changes**
   - Re-run `sop-validator`
   - Have `sop-challenger` review changes
   - Confirm no regressions

8. **Save Updated SOP**
   - Update file in place (or Archive old, create new for major)
   - Update related SOPs if needed
   - Report changes made

**Output:**
```markdown
## SOP Improvement Report

**SOP:** [Title]
**Previous Version:** X.Y.Z
**New Version:** X.Y.Z

### Changes Made
1. [Change 1 - section affected]
2. [Change 2 - section affected]

### Validation
- Challenger: [PASS/issues found]
- Validator: [PASS/issues found]

### Impact
- Related SOPs that may need updates: [list]

### Next Steps
- [ ] Review changes
- [ ] Update related SOPs if needed
- [ ] Mark as active when approved
```
