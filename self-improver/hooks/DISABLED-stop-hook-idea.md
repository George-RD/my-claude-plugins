# Stop Hook Idea - DISABLED

The concept was right but implementation was wrong. This was running on every message end, not session end, causing pollution.

## Original Intent
Evaluate session efficiency at the END of a full Claude Code session.

## Original Prompt
```
A Claude Code session has ended. Briefly assess if this session had any notable inefficiencies (repeated clarifications, excessive iterations, or confusion). If the session was smooth and efficient, respond with just 'PASS'. If issues were detected, respond with a brief JSON: {"flag": true, "severity": 1-10, "issue": "brief description"}. Be selective - only flag sessions with real problems, not minor friction.
```

## Problem
The "Stop" hook event fires on every conversation turn end, not actual session termination. This caused:
1. Hook running hundreds of times per session
2. Memory pollution from repeated evaluations
3. Wasted API calls

## Future Fix
Need to investigate when "Stop" actually fires and if there's a true "SessionEnd" event, or if this needs to be triggered differently (e.g., PreCompact which fires on context compaction).
