---
name: create
description: Create a new SOP from description or notes
allowed-tools: ["Read", "Write", "Grep", "Glob", "Task", "Skill", "AskUserQuestion"]
argument-hint: "[title or topic]"
---

# Create New SOP

You are running the SOP creation workflow for navigation charting operations.

**Process:**

1. **Gather Requirements**
   - If argument provided, use as topic/title
   - If no argument, ask user what process to document
   - Ask clarifying questions:
     - What triggers this process?
     - Who is involved?
     - What's the deliverable?

2. **Check for Research Needs**
   - If domain knowledge is needed beyond charting expertise:
     - Suggest running `/research-framework:research` first
     - Or proceed with available context

3. **Determine SOP Type**
   Ask user or recommend based on process:
   - Checklist: Routine tasks with known steps
   - Step-by-step: Linear sequential process
   - Hierarchical: Multi-level decision process
   - Flowchart: Branching decisions, troubleshooting
   - Hybrid: Complex processes

4. **Draft SOP**
   - Launch `sop-drafter` agent via Task tool
   - Provide all gathered context
   - Wait for draft output

5. **Challenge Draft**
   - Launch `sop-challenger` agent to review
   - Collect gaps and edge cases
   - Present issues to user

6. **Refine Based on Feedback**
   - Incorporate challenger feedback
   - Update draft as needed
   - Re-challenge if major changes

7. **Validate Structure**
   - Run `sop-validator` agent
   - Ensure all required fields present
   - Fix any formatting issues

8. **Save SOP**
   - Determine vault path from config or ask user
   - Save to `[vault]/SOPs/Draft/[filename].md`
   - Report success with next steps

**Vault Structure:**
```
[vault-root]/
└── SOPs/
    ├── Active/      # Approved, in-use SOPs
    ├── Draft/       # Work in progress
    ├── Archive/     # Superseded versions
    └── Templates/   # SOP templates
```

**Output:**
- Created SOP file path
- Summary of content
- Challenger findings summary
- Next steps (review, approve, activate)

**Charting Context:**
You're creating SOPs for navigation chart production including:
- Client request handling
- Chart creation workflows
- Quality control procedures
- Delivery processes
- Geophysical/ROV survey chart specifics
