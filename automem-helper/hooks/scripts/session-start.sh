#!/bin/bash
# AutoMem SessionStart hook - prompts memory recall for current project context

PROJECT=$(basename "$PWD")

# Output JSON with additionalContext for Claude to see
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<automem-recall>At the START of this session, recall relevant memories using AutoMem MCP:\\n\\n1. Project context: recall_memory({ query: \\"$PROJECT project context\\", tags: [\\"repo:$PROJECT\\"], limit: 5, time_query: \\"last 7 days\\" })\\n2. Session handoff: recall_memory({ query: \\"session handoff\\", tags: [\\"session-handoff\\"], limit: 1, time_query: \\"last 24 hours\\" })\\n\\nDo this BEFORE responding to the user. If no results, continue silently.</automem-recall>"
  }
}
EOF

exit 0
