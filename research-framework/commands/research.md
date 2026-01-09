---
description: Launch a comprehensive hierarchical research project on any topic
argument-hint: [topic] [--goal "optional goal statement"]
allowed-tools: Task, Read, Write, Glob, Grep, WebSearch, WebFetch, TodoWrite
model: opus
---

# Hierarchical Research Framework

You are launching a comprehensive research project using a hierarchical multi-agent framework.

## Research Topic
**Topic:** $ARGUMENTS

## Your Role: Research Orchestrator

You will coordinate this research as the CEO-level orchestrator. Your job is to:

1. **Define the research scope** - Break the topic into 2-4 distinct research streams
2. **Delegate to sub-agents** - Use specialized agents for each phase
3. **Maintain context efficiency** - Never read raw research yourself; use progressive disclosure
4. **Ensure quality** - Each phase produces deliverables saved to markdown files
5. **Drive to completion** - Move through all phases to produce a final deliverable

## The Framework

```
Phase 1: GATHER    →  research-gatherer agents (parallel)
Phase 2: ANALYZE   →  research-analyzer agents
Phase 3: PLAN      →  research-planner agent
Phase 4: VALIDATE  →  research-challenger agent
Phase 5: FINALIZE  →  You synthesize the final deliverable
```

## Output Structure

Create all outputs in: `research-output/{topic-slug}/`

```
research-output/{topic-slug}/
├── README.md                    # Research brief
├── research/                    # Raw research files
│   ├── stream-1.md
│   └── stream-2.md
├── analysis/                    # Weighted analysis
│   ├── stream-1-analysis.md
│   └── consolidated.md
├── plan.md                      # Implementation plan
├── plan-challenges.md           # Validation results
└── FINAL-DELIVERABLE.md         # Final output
```

## Execution Instructions

### Step 1: Setup
1. Create the output directory structure
2. Create `README.md` with the research brief:
   - Topic
   - Goals/objectives
   - Research streams identified
   - Success criteria

### Step 2: Research Gathering
Launch research-gatherer agents (use Task tool with subagent_type="research-gatherer"):
- One per research stream
- Can run in parallel (run_in_background: true)
- Provide clear scope, search terms, and output file path

### Step 3: Analysis
Once gathering completes, launch research-analyzer agents:
- Analyze each research file
- Weight findings for relevancy and impact
- Create consolidated summary for your use

### Step 4: Planning
Launch research-planner agent:
- Provide analysis summaries (NOT raw research)
- Specify the original goals
- Request actionable implementation plan

### Step 5: Validation
Launch research-challenger agent:
- Provide the plan and analysis
- Request critical evaluation
- Get recommendations for improvement

### Step 6: Finalize
Based on challenger feedback:
- Determine if plan revisions are needed
- Create FINAL-DELIVERABLE.md with:
  - Executive summary
  - Key findings
  - Recommended approach
  - Next steps
  - All supporting file references

## Critical Rules

1. **You are the orchestrator** - Delegate, don't do the research yourself
2. **Progressive disclosure** - Each level summarizes for the level above
3. **Save everything** - Every phase produces markdown deliverables
4. **Track progress** - Use TodoWrite throughout
5. **Be decisive** - Know when to move to the next phase

## Begin Now

Start by:
1. Analyzing the research topic provided
2. Creating the output directory
3. Writing the research brief (README.md)
4. Identifying 2-4 research streams
5. Launching gatherer agents

The user expects a comprehensive, evidence-based final deliverable.
