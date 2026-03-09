---
name: investigation
description: >
  MUST USE for any work on Fugro incident investigations (Sphera non-conformities, root cause
  analysis, evidence gathering, timeline reconstruction). Covers: investigation.db schema and
  conventions, evidence capture protocols, POET causal factor analysis, Kelvin TOP SET methodology,
  and sub-agent rules for structured investigation workflows. Trigger phrases: 'investigation',
  'F263551', 'Sphera', 'evidence', 'root cause', 'non-conformity', 'POET', 'TOP SET', 'timeline',
  'findings', 'deliverables outstanding', 'who was responsible', 'what happened'. Use this skill
  whenever working with investigation.db, investigation-data.js, or any investigation-*.html page.
---

# Fugro Investigation Toolkit

Structured incident investigation system for Fugro MEI projects. Manages evidence, timelines,
people, and causal analysis through a SQLite database, with HTML dashboards consuming a generated
JavaScript data file.

## Architecture

```
investigation.db                    ← Single source of truth (SQLite)
  ↓
generate_investigation_data.py      ← Queries DB, produces JS data file
  ↓
investigation-data.js               ← Shared data consumed by all views
  ↓
investigation-F263551.html          ← Investigation board (case file view)
investigation-topset.html           ← Kelvin TOP SET methodology view
investigation-connections.html      ← Force-directed relationship graph
```

**Pipeline rule**: All data changes go through `investigation.db`. Never edit
`investigation-data.js` directly — it is a generated artifact. After any DB change,
regenerate: `python3 generate_investigation_data.py`

## File Locations

| File | Path | Purpose |
|------|------|---------|
| `investigation.db` | `/Users/george/COWORK/investigation.db` | Investigation database |
| `investigation-data.js` | `/Users/george/COWORK/investigation-data.js` | Generated data file |
| `investigation-F263551.html` | `/Users/george/COWORK/investigation-F263551.html` | Case board |
| `investigation-topset.html` | `/Users/george/COWORK/investigation-topset.html` | TOP SET view |
| `investigation-connections.html` | `/Users/george/COWORK/investigation-connections.html` | Graph |
| `emails.db` | `/Users/george/COWORK/emails.db` | Source emails (read-only) |
| `projects.db` | `/Users/george/COWORK/projects.db` | Project data |
| Schema reference | Read `references/schema.sql` in this skill directory |

## Database Conventions

### Connection

```python
import sqlite3
conn = sqlite3.connect('/Users/george/COWORK/investigation.db')
conn.row_factory = sqlite3.Row
conn.execute("PRAGMA foreign_keys = ON")
conn.execute("PRAGMA busy_timeout = 15000")
```

### ID Formats

| Entity | Format | Examples |
|--------|--------|---------|
| Evidence (confirmed) | `E` + zero-padded 2-digit | `E01`, `E02`, `E20` |
| Assumption | `A` + zero-padded 2-digit | `A01`, `A09` |
| Question | `Q` + zero-padded 2-digit | `Q01`, `Q13` |
| Note | Auto-increment integer | `1`, `2`, `42` |
| Gap | `GAP` + number | `GAP1`, `GAP2` |
| Person | Slug from name | `george-reid-dowd`, `sameer-nilkund` |
| F-number | `F` + 6 digits | `F263551` |
| CRPO | `CRPO` + space + number | `CRPO 147` |

### SQL Patterns

- **Inserts**: `INSERT OR IGNORE` for idempotent operations
- **Parameterized**: Always use `?` placeholders, never f-strings in SQL
- **Timestamps**: `strftime('%Y-%m-%dT%H:%M:%fZ','now')` for ISO format
- **JSON arrays**: Store as JSON text (`'["E01","E05"]'`), parse in Python
- **Enum constraints**: Respect CHECK constraints — the DB will reject bad values

### Column Conventions

- `snake_case` for all columns
- `TEXT` for most fields (SQLite is flexible, but be explicit)
- `INTEGER DEFAULT 0` for boolean-like flags (0/1)
- `REAL` for scores/strengths (0.0-1.0)
- `created_at` / `updated_at` with ISO timestamp defaults on every table

## Evidence Capture Protocol

This is the most critical section. Every piece of information in the investigation
must be properly sourced and categorized.

### The Evidence Hierarchy

```
CONFIRMED EVIDENCE (E-series)
  ├── Must have at least one verifiable source
  ├── Source = email ID, document, or direct observation
  └── Confidence: implicit 100% — it's confirmed or it's not here

ASSUMPTIONS (A-series)
  ├── Reasonable inferences from evidence
  ├── Must state confidence: LOW / MED / HIGH
  ├── Must list supporting sources (even if indirect)
  └── Can be promoted to Evidence or dismissed

OPEN QUESTIONS (Q-series)
  ├── Things we don't know yet
  ├── Priority: CRITICAL / HIGH / MEDIUM / LOW
  ├── Status: open / investigating / answered / closed
  └── When answered, record the answer and update status

NOTES (auto-increment)
  ├── Freeform findings, thoughts, investigation angles
  ├── Type: finding / thought / angle / interview_note / correction
  ├── Status: pending / verified / dismissed / incorporated
  └── Link to related evidence/assumptions/questions via JSON arrays
```

### Adding New Evidence

```python
# CORRECT — sourced, categorized, POET-tagged
conn.execute("""
    INSERT INTO evidence (id, text, sources, poet)
    VALUES (?, ?, ?, ?)
""", ('E21', 'Rizalino confirmed he was never formally requested for F263551 after Oct',
      '["#15813"]', 'Organisation'))

# WRONG — no source, no POET
conn.execute("INSERT INTO evidence (id, text) VALUES ('E21', 'Someone said something')")
```

### Adding Investigation Notes

Notes are the "working memory" of the investigation — thoughts, angles, corrections.
They don't need the rigour of evidence but must be trackable.

```python
conn.execute("""
    INSERT INTO note (type, content, related_evidence, source, status)
    VALUES (?, ?, ?, ?, ?)
""", ('angle', 'Check if Ibtesam had any delegated authority docs before leaving',
      '["E12","Q06"]', 'analysis', 'pending'))
```

### POET Categorization

Every evidence item, assumption, question, and causal factor must be tagged with
one POET category:

| Category | Meaning | Examples |
|----------|---------|---------|
| **People** | Individual actions, decisions, competence | George's leave, Rizalino's availability |
| **Organisation** | Processes, systems, management, structure | No handover process, PM tracking gap |
| **Environment** | Context, workload, external pressures | Vessel schedules, client timelines |
| **Technology** | Tools, systems, data | Teams recording deleted, SharePoint access |

If an item spans categories, pick the **primary** driver. A person failing because
of a process gap is **Organisation**, not People.

### Source References

Sources are stored as JSON arrays of string references:

| Source type | Format | Example |
|------------|--------|---------|
| Email from emails.db | `#` + email ID | `"#865"`, `"#15813"` |
| Document | Description string | `"Sphera #26490627"` |
| Interview | `interview:` + person | `"interview:george"` |
| Analysis | `analysis` | `"analysis"` |
| Omega memory | `omega:` + query | `"omega:F263551 charting"` |

## Kelvin TOP SET Framework

The investigation follows the 6-step Kelvin TOP SET methodology:

1. **Understand what happened** — Gather facts, reconstruct timeline
2. **Find the causes** — Identify POET causal factors using storyboard
3. **Determine root causes** — Trace contributing → underlying → root causes
4. **Develop recommendations** — Address root causes, not symptoms
5. **Implement changes** — Assign actions, track completion
6. **Review effectiveness** — Verify changes prevent recurrence

### POET Storyboard

The storyboard visualizes causal factors as "post-it notes" organized by POET
category and classified by type:

| Factor Type | Meaning | Color Signal |
|------------|---------|-------------|
| `contributing` | Directly caused or enabled the incident | Primary accent |
| `systemic` | Structural/organizational weakness | Critical/red |
| `mitigating` | Reduced the impact or could have prevented it | Positive/green |
| `disputed` | Conflicting accounts — needs resolution | Caution/amber |
| `context` | Background information, not causal | Info/blue |

## Working with Connections

Connections represent relationships between people in the investigation.

```python
conn.execute("""
    INSERT INTO connection (from_person, to_person, type, label, strength, email_ids)
    VALUES (?, ?, ?, ?, ?, ?)
""", ('George Reid-Dowd', 'Sameer Nilkund', 'escalation',
      'Processor requests Oct-Feb', 0.9, '["#865","#844","#522"]'))
```

**Connection types**: `reporting`, `escalation`, `handover`, `collaboration`,
`supervision`, `disputed`, `cc_chain`

**Strength**: 0.0-1.0 where 1.0 = direct, frequent, critical interaction

## UI/UX & State Management

All investigation HTML views must adhere to the `INVESTIGATION_WORKFLOW.md` paradigm:
1. **Zero Hardcoded Data**: HTML files only consume `investigation-data.js`.
2. **Progressive Disclosure**: High-level summaries first. Use collapsible sections (`.expanded`/`.collapsed`) for deep dives into timeline events and full evidence logs.
3. **Emotional Design**: Use targeted colors (e.g., Neon Red for critical/missing, Amber for assumptions, muted for context) to guide the investigator's eye.

When updating the UI, you must maintain this stateless architecture and ensure any new data requirements are first modeled in `investigation.db` and exported via `generate_investigation_data.py`.

## Sub-Agent Protocol

When delegated investigation tasks, sub-agents MUST follow these rules:

### MUST DO

1. **Connect to investigation.db** using the connection pattern above
2. **Source everything** — no evidence without a verifiable source reference
3. **Use correct ID formats** — check max existing ID before inserting new ones
4. **POET-tag** every evidence item, assumption, and question
5. **Run `generate_investigation_data.py`** after any DB changes
6. **Query emails.db read-only** — `sqlite3.connect("file:emails.db?mode=ro", uri=True)`
7. **Log what you did** — insert a note with type `finding` for any new discovery

### MUST NOT DO

1. **Never edit investigation-data.js directly** — it's generated
2. **Never add evidence without sources** — use assumptions or notes instead
3. **Never delete evidence** — mark assumptions as `resolved` or questions as `closed`
4. **Never modify emails.db** — it's read-only source material
5. **Never speculate without marking it** — unverified claims go in assumptions with LOW confidence
6. **Never suppress POET categorization** — every item needs one

### Querying for New Evidence

When searching for new evidence in emails.db:

```python
import sqlite3
edb = sqlite3.connect("file:/Users/george/COWORK/emails.db?mode=ro", uri=True)
edb.row_factory = sqlite3.Row

# Search by subject keyword
rows = edb.execute("""
    SELECT id, subject, sender, date_received, body
    FROM emails
    WHERE subject LIKE '%F263551%' OR body LIKE '%F263551%'
    ORDER BY date_received
""").fetchall()

# Search by sender in date range
rows = edb.execute("""
    SELECT id, subject, sender, date_received
    FROM emails
    WHERE sender LIKE '%sameer%'
      AND date_received BETWEEN '2025-10-01' AND '2025-12-31'
    ORDER BY date_received
""").fetchall()
```

### Verification Queries

After making changes, verify:

```bash
# Evidence counts
sqlite3 investigation.db "SELECT COUNT(*) as n, 'evidence' as t FROM evidence
UNION ALL SELECT COUNT(*), 'assumption' FROM assumption
UNION ALL SELECT COUNT(*), 'question' FROM question
UNION ALL SELECT COUNT(*), 'note' FROM note"

# Recent notes
sqlite3 investigation.db "SELECT id, type, substr(content,1,80), status, created_at
FROM note ORDER BY created_at DESC LIMIT 10"

# Unsourced evidence (should return 0 rows)
sqlite3 investigation.db "SELECT id, text FROM evidence WHERE sources IS NULL OR sources = '[]'"
```

## Active Investigation: F263551

### Case Summary

- **Project**: F263551 — QE LNG ROV (Qatar Energy, via Fugro Peninsular)
- **Vessel**: Casa Subathu
- **Sphera**: #26490627 (internal non-conformity)
- **Issue**: 10 ROV report volumes missing Appendix C (charts) since Sep 2025
- **Root cause**: No processor assigned for 5+ months; supervision vacuum after
  Ibtesam Hasan left Fugro Nov 28, 2025

### Key Email IDs (in emails.db)

| Email # | Date | Significance |
|---------|------|-------------|
| #865 | Oct 1 | George's original CAD/Proc request for Rizalino |
| #844, #842 | Oct 8 | Sameer redirects Rizalino to Mamola Melody |
| #834 | Oct 9 | George follows up |
| #740 | Nov 19 | George requests Danilo — UNANSWERED |
| #334 | Nov 28 | Ibtesam's farewell email — leaving Fugro |
| #2829 | Dec 5 | Ibtesam auto-reply (confirms departure) |
| #2870, #2869 | Nov 22 | Teams recording auto-deleted |
| #2314 | Feb 10 | Tony Farn's investigation discovery |
| #2313 | Feb 10 | Ace confirms GP sent, ROV pending |
| #2264 | Feb 10 | Yessy's statement ("several times") |
| #15813 | Feb 19 | Sameer's rebuttal disputing Yessy |
| #15823 | Feb 20 | Edgar's 3-processor assessment |
| #15816 | Feb 23 | Gisha's Sphera non-conformity |
| #15821 | Feb 20 | Tony: client requesting changes |

### Communication Gaps

- **GAP1**: Oct 10 – Nov 18 (40 days) — George on leave, Ibtesam still at Fugro
- **GAP2**: Nov 20 – Feb 9 (82 days) — Post-Ibtesam, George's Nov 19 email unanswered

### Investigation Phases

1. **Evidence Gathering** — mostly complete (43+ emails, 19 people, 33 events)
2. **Extended Search** — not started (Archive/All Mail, Teams, Copilot)
3. **Interviews** — not started (George, Dirk, Yessy, Sameer, Ace)
4. **Resolution** — not started (Sphera entry, root cause, processor assignment)
